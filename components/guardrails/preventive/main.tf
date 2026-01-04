# Merge directory and inline configurations
# Directory configurations take precedence over inline configurations
locals {
  config_files = var.control_policies_dir != null ? fileset(var.control_policies_dir, "*.{json,yaml,yml}") : []
  file_configs = [
    for file in local.config_files :
    endswith(file, ".json") ? jsondecode(file("${var.control_policies_dir}/${file}")) :
    yamldecode(file("${var.control_policies_dir}/${file}"))
  ]

  processed_file_configs = [
    for config in local.file_configs :
    merge(config, {
      policy_document = jsonencode(config.policy_document)
    })
  ]

  all_control_policies = concat(
    local.processed_file_configs,
    [
      for policy in var.control_policies :
      policy
      if !contains([for file_config in local.processed_file_configs : file_config.name], policy.name)
    ]
  )

  folder_names = distinct(flatten([
    for policy in local.all_control_policies : try(policy.target_folder_names, [])
  ]))

  folder_name_regexes = distinct(flatten([
    for policy in local.all_control_policies : try(policy.target_folder_name_regexes, [])
  ]))

  account_display_names = distinct(flatten([
    for policy in local.all_control_policies : try(policy.target_account_display_names, [])
  ]))
}

# Get resource directory information (if any policy attaches to root)
data "alicloud_resource_manager_resource_directories" "default" {
  count = length([for p in local.all_control_policies : p if try(p.attach_to_root, false)]) > 0 ? 1 : 0
}

# Query level 1 folders (under root)
data "alicloud_resource_manager_folders" "level1" {
  count = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? 1 : 0
}

# Query level 2 folders
data "alicloud_resource_manager_folders" "level2" {
  for_each = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? {
    for folder in data.alicloud_resource_manager_folders.level1[0].folders :
    folder.id => folder.id
  } : {}

  parent_folder_id = each.value
}

# Query level 3 folders
data "alicloud_resource_manager_folders" "level3" {
  for_each = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? {
    for folder in flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level2 :
      folders_data.folders
    ]) :
    folder.id => folder.id
  } : {}

  parent_folder_id = each.value
}

# Query level 4 folders
data "alicloud_resource_manager_folders" "level4" {
  for_each = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? {
    for folder in flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level3 :
      folders_data.folders
    ]) :
    folder.id => folder.id
  } : {}

  parent_folder_id = each.value
}

# Query level 5 folders
data "alicloud_resource_manager_folders" "level5" {
  for_each = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? {
    for folder in flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level4 :
      folders_data.folders
    ]) :
    folder.id => folder.id
  } : {}

  parent_folder_id = each.value
}

# Query all accounts
data "alicloud_resource_manager_accounts" "all" {
  count = length(local.account_display_names) > 0 ? 1 : 0
}

# Create Resource Manager control policies
resource "alicloud_resource_manager_control_policy" "default" {
  for_each = {
    for policy in local.all_control_policies : policy.name => policy
  }

  control_policy_name = each.value.name
  description         = try(each.value.description, null)
  policy_document     = each.value.policy_document
  effect_scope        = "RAM"
  tags                = try(each.value.tags, {})
}

# Build policy attachment mappings
locals {
  # Collect all folders from all levels (1-5)
  all_folders = length(local.folder_names) > 0 || length(local.folder_name_regexes) > 0 ? concat(
    data.alicloud_resource_manager_folders.level1[0].folders,
    flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level2 :
      folders_data.folders
    ]),
    flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level3 :
      folders_data.folders
    ]),
    flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level4 :
      folders_data.folders
    ]),
    flatten([
      for parent_id, folders_data in data.alicloud_resource_manager_folders.level5 :
      folders_data.folders
    ])
  ) : []

  # Build folder_name to folder_ids map (one name may match multiple folders at different levels)
  folder_name_to_ids_map = {
    for folder_name in local.folder_names :
    folder_name => [
      for folder in local.all_folders :
      folder.id if folder.folder_name == folder_name
    ]
  }

  # Build regex to folder_ids map (one regex may match multiple folders)
  regex_to_folder_ids_map = {
    for regex in local.folder_name_regexes :
    regex => distinct([
      for folder in local.all_folders :
      folder.id if can(regex(regex, folder.folder_name))
    ])
  }

  # Build account display name to account ID map
  account_id_map = length(local.account_display_names) > 0 ? {
    for account in data.alicloud_resource_manager_accounts.all[0].accounts :
    account.display_name => account.id
    if contains(local.account_display_names, account.display_name)
  } : {}

  # Build policy attachment list (policy -> target mappings)
  # Supports root folder, folders (by name/regex), and accounts (by display name)
  policy_attachments = flatten([
    for policy in local.all_control_policies : [
      for target_id in(
        try(policy.attach_to_root, false) ?
        [data.alicloud_resource_manager_resource_directories.default[0].directories[0].root_folder_id] :
        distinct(concat(
          try(policy.target_ids, []),
          # Match folders by exact name (from pre-built map)
          flatten([
            for folder_name in try(policy.target_folder_names, []) :
            try(local.folder_name_to_ids_map[folder_name], [])
          ]),
          # Match folders by regex (from pre-built map)
          flatten([
            for regex in try(policy.target_folder_name_regexes, []) :
            try(local.regex_to_folder_ids_map[regex], [])
          ]),
          compact([
            for account_display_name in try(policy.target_account_display_names, []) :
            contains(keys(local.account_id_map), account_display_name) ? local.account_id_map[account_display_name] : null
          ])
        ))
        ) : {
        policy_name = policy.name
        policy_id   = try(alicloud_resource_manager_control_policy.default[policy.name].id, null)
        target_id   = target_id
      }
    ]
    if contains(keys(alicloud_resource_manager_control_policy.default), policy.name)
  ])
}

# Attach control policies to targets (folders/accounts)
resource "alicloud_resource_manager_control_policy_attachment" "default" {
  for_each = {
    for attachment in local.policy_attachments :
    "${attachment.policy_name}-${attachment.target_id}" => attachment
  }

  policy_id = each.value.policy_id
  target_id = each.value.target_id

  depends_on = [
    alicloud_resource_manager_control_policy.default,
    data.alicloud_resource_manager_resource_directories.default,
    data.alicloud_resource_manager_folders.level1,
    data.alicloud_resource_manager_folders.level2,
    data.alicloud_resource_manager_folders.level3,
    data.alicloud_resource_manager_folders.level4,
    data.alicloud_resource_manager_folders.level5,
    data.alicloud_resource_manager_accounts.all
  ]
}
