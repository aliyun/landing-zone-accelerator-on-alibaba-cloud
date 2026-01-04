# Get master account information
data "alicloud_account" "master" {
  provider = alicloud.master
}

# Get IAM account information
data "alicloud_account" "iam" {
  provider = alicloud.iam
}

# Enable CloudSSO service
data "alicloud_cloud_sso_service" "enable" {
  provider = alicloud.master
  enable   = "On"
}

# Generate random suffix for directory name
resource "random_string" "directory_suffix" {
  count   = var.append_random_suffix ? 1 : 0
  length  = var.random_suffix_length
  upper   = false
  lower   = true
  numeric = true
  special = false
}

# Process directory name and access configurations
locals {
  # Calculate directory name with optional random suffix
  directory_base_name = var.directory_name != null ? var.directory_name : "CloudSSO-${data.alicloud_account.master.id}"
  directory_final_name = var.append_random_suffix ? (
    var.random_suffix_separator != "" ? "${local.directory_base_name}${var.random_suffix_separator}${random_string.directory_suffix[0].result}" : "${local.directory_base_name}${random_string.directory_suffix[0].result}"
  ) : local.directory_base_name

  # Load access configurations from directory files
  config_files = var.access_configurations_dir != null ? fileset(var.access_configurations_dir, "*.{json,yaml,yml}") : []
  file_configs = [
    for file in local.config_files :
    endswith(file, ".json") ? jsondecode(file("${var.access_configurations_dir}/${file}")) :
    yamldecode(file("${var.access_configurations_dir}/${file}"))
  ]

  # Process file configs: convert inline custom policy document to JSON string
  processed_file_configs = [
    for config in local.file_configs :
    try(config.inline_custom_policy, null) != null ? merge(config, {
      inline_custom_policy = merge(config.inline_custom_policy, {
        policy_document = jsonencode(config.inline_custom_policy.policy_document)
      })
      }) : merge(config, {
      inline_custom_policy = null
    })
  ]

  # Merge file and inline access configurations (file configs take precedence)
  access_configurations = concat(
    local.processed_file_configs,
    [
      for inline_cfg in var.access_configurations :
      inline_cfg if !contains([for cfg in local.file_configs : cfg.name], inline_cfg.name)
    ]
  )
}

# Create CloudSSO directory (instance)
resource "alicloud_cloud_sso_directory" "this" {
  provider       = alicloud.master
  directory_name = local.directory_final_name

  # Configure login preferences
  dynamic "login_preference" {
    for_each = var.login_preference != null ? [var.login_preference] : []
    content {
      allow_user_to_get_credentials = login_preference.value.allow_user_to_get_credentials
      login_network_masks           = login_preference.value.login_network_masks
    }
  }

  # Configure MFA authentication settings
  dynamic "mfa_authentication_setting_info" {
    for_each = var.mfa_authentication_setting_info != null ? [var.mfa_authentication_setting_info] : []
    content {
      mfa_authentication_advance_settings = mfa_authentication_setting_info.value.mfa_authentication_advance_settings
      operation_for_risk_login            = mfa_authentication_setting_info.value.operation_for_risk_login
    }
  }

  # Configure password policy
  dynamic "password_policy" {
    for_each = var.password_policy != null ? [var.password_policy] : []
    content {
      max_login_attempts            = password_policy.value.max_login_attempts
      max_password_age              = password_policy.value.max_password_age
      min_password_different_chars  = password_policy.value.min_password_different_chars
      min_password_length           = password_policy.value.min_password_length
      password_not_contain_username = password_policy.value.password_not_contain_username
      password_reuse_prevention     = password_policy.value.password_reuse_prevention
    }
  }

  depends_on = [data.alicloud_cloud_sso_service.enable]
}

# Delegate account when IAM account differs from master account
resource "alicloud_cloud_sso_delegate_account" "this" {
  count      = data.alicloud_account.iam.id != data.alicloud_account.master.id ? 1 : 0
  provider   = alicloud.master
  account_id = data.alicloud_account.iam.id

  depends_on = [
    alicloud_cloud_sso_directory.this
  ]
}

# Create access configurations
resource "alicloud_cloud_sso_access_configuration" "this" {
  provider = alicloud.iam
  for_each = {
    for config in local.access_configurations : config.name => config
  }
  directory_id              = alicloud_cloud_sso_directory.this.id
  access_configuration_name = each.value.name
  description               = try(each.value.description, null)
  relay_state               = try(each.value.relay_state, "https://home.console.aliyun.com/")
  session_duration          = try(each.value.session_duration, 3600)

  # Configure permission policies (system and inline custom policies)
  dynamic "permission_policies" {
    for_each = concat(
      [
        for policy in try(each.value.managed_system_policies, []) : {
          type     = "System"
          name     = policy
          document = null
        }
      ],
      try(each.value.inline_custom_policy, null) != null ? [
        {
          type     = "Inline"
          name     = try(each.value.inline_custom_policy.policy_name, "InlinePolicy")
          document = each.value.inline_custom_policy.policy_document
        }
      ] : []
    )
    content {
      permission_policy_type     = permission_policies.value.type
      permission_policy_name     = permission_policies.value.name
      permission_policy_document = permission_policies.value.document
    }
  }

  timeouts {
    delete = "2m"
  }

  depends_on = [
    alicloud_cloud_sso_delegate_account.this
  ]
}

# Create CloudSSO users and groups
module "users_and_groups" {
  count  = length(var.users) > 0 || length(var.groups) > 0 ? 1 : 0
  source = "../../../modules/cloudsso-users-and-groups"
  providers = {
    alicloud = alicloud.iam
  }

  directory_id = alicloud_cloud_sso_directory.this.id
  users        = var.users
  groups       = var.groups

  depends_on = [
    alicloud_cloud_sso_delegate_account.this
  ]
}

# Get resource directory accounts for access assignment
data "alicloud_resource_manager_accounts" "accounts" {
  count    = length(flatten([for assignment in var.access_assignments : try(assignment.account_names, [])])) > 0 ? 1 : 0
  provider = alicloud.master
}

# Build access assignment mappings
locals {
  # Map account display names to account IDs
  account_id_map = length(data.alicloud_resource_manager_accounts.accounts) > 0 ? {
    for account in data.alicloud_resource_manager_accounts.accounts[0].accounts :
    account.display_name => account.id
  } : {}

  # Flatten member account access assignments
  member_account_assignments_flat = flatten([
    for assignment in var.access_assignments : [
      for account_name in try(assignment.account_names, []) : [
        for config_name in assignment.access_configuration_names : {
          key                       = "${assignment.principal_name}-${assignment.principal_type}-${account_name}-${config_name}"
          principal_name            = assignment.principal_name
          principal_type            = assignment.principal_type
          account_name              = account_name
          access_configuration_name = config_name
        }
      ]
    ]
  ])

  # Flatten master account access assignments
  master_account_assignments_flat = flatten([
    for assignment in var.access_assignments : [
      for config_name in assignment.access_configuration_names : {
        key                       = "${assignment.principal_name}-${assignment.principal_type}-<RD Management Account>-${config_name}"
        principal_name            = assignment.principal_name
        principal_type            = assignment.principal_type
        access_configuration_name = config_name
      }
      if try(assignment.include_master_account, false)
    ]
  ])
}

# Assign access configurations to member accounts
resource "alicloud_cloud_sso_access_assignment" "member_accounts" {
  for_each = {
    for item in local.member_account_assignments_flat :
    item.key => item
  }

  provider                = alicloud.iam
  directory_id            = alicloud_cloud_sso_directory.this.id
  principal_id            = each.value.principal_type == "User" ? (length(module.users_and_groups) > 0 ? module.users_and_groups[0].users[each.value.principal_name].user_id : null) : (length(module.users_and_groups) > 0 ? module.users_and_groups[0].groups[each.value.principal_name].group_id : null)
  principal_type          = each.value.principal_type
  target_id               = local.account_id_map[each.value.account_name]
  access_configuration_id = alicloud_cloud_sso_access_configuration.this[each.value.access_configuration_name].access_configuration_id
  target_type             = "RD-Account"

  depends_on = [
    alicloud_cloud_sso_access_configuration.this,
    alicloud_cloud_sso_delegate_account.this,
    module.users_and_groups
  ]
}

# Assign access configurations to master account
resource "alicloud_cloud_sso_access_assignment" "master_account" {
  for_each = {
    for item in local.master_account_assignments_flat :
    item.key => item
  }

  provider                = alicloud.master
  directory_id            = alicloud_cloud_sso_directory.this.id
  principal_id            = each.value.principal_type == "User" ? (length(module.users_and_groups) > 0 ? module.users_and_groups[0].users[each.value.principal_name].user_id : null) : (length(module.users_and_groups) > 0 ? module.users_and_groups[0].groups[each.value.principal_name].group_id : null)
  principal_type          = each.value.principal_type
  target_id               = data.alicloud_account.master.id
  access_configuration_id = alicloud_cloud_sso_access_configuration.this[each.value.access_configuration_name].access_configuration_id
  target_type             = "RD-Account"

  depends_on = [
    alicloud_cloud_sso_access_configuration.this,
    alicloud_cloud_sso_delegate_account.this,
    module.users_and_groups
  ]
}
