# Get current account information
data "alicloud_account" "current" {}

# Create Resource Directory (only if not using existing)
resource "alicloud_resource_manager_resource_directory" "default" {
  count  = var.use_existing_resource_directory ? 0 : 1
  status = "Enabled"
}

# Get Resource Directory information
data "alicloud_resource_manager_resource_directories" "default" {
  depends_on = [alicloud_resource_manager_resource_directory.default]
}

# Parse folder structure from file or variable
# Supports JSON and YAML file formats
locals {
  folder_structure_from_file_raw = var.folder_structure_file_path != null ? (
    endswith(var.folder_structure_file_path, ".json") ? jsondecode(file(var.folder_structure_file_path)) : (
    endswith(var.folder_structure_file_path, ".yaml") || endswith(var.folder_structure_file_path, ".yml") ? yamldecode(file(var.folder_structure_file_path)) : null)
  ) : null

  folder_structure_from_file = local.folder_structure_from_file_raw != null ? [
    for item in local.folder_structure_from_file_raw : {
      folder_name        = item.folder_name
      parent_folder_name = try(item.parent_folder_name, null)
      level              = item.level
      tags               = try(item.tags, {})
    }
  ] : null

  effective_folder_structure = local.folder_structure_from_file != null ? local.folder_structure_from_file : var.folder_structure

  folder_config_map = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
  }

  folders_by_level = {
    for level in range(1, 6) :
    level => [
      for folder in local.effective_folder_structure :
      folder if folder.level == level
    ]
  }
}

# Level 1 folders
resource "alicloud_resource_manager_folder" "level1" {
  for_each = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
    if folder.level == 1
  }

  folder_name      = each.value.folder_name
  parent_folder_id = data.alicloud_resource_manager_resource_directories.default.directories[0].root_folder_id
  tags             = each.value.tags

  depends_on = [
    alicloud_resource_manager_resource_directory.default,
  ]
}

# Level 2 folders
resource "alicloud_resource_manager_folder" "level2" {
  for_each = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
    if folder.level == 2
  }

  folder_name      = each.value.folder_name
  parent_folder_id = alicloud_resource_manager_folder.level1[each.value.parent_folder_name].id
  tags             = each.value.tags

  depends_on = [alicloud_resource_manager_folder.level1]
}

# Level 3 folders
resource "alicloud_resource_manager_folder" "level3" {
  for_each = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
    if folder.level == 3
  }

  folder_name      = each.value.folder_name
  parent_folder_id = alicloud_resource_manager_folder.level2[each.value.parent_folder_name].id
  tags             = each.value.tags

  depends_on = [alicloud_resource_manager_folder.level2]
}

# Level 4 folders
resource "alicloud_resource_manager_folder" "level4" {
  for_each = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
    if folder.level == 4
  }

  folder_name      = each.value.folder_name
  parent_folder_id = alicloud_resource_manager_folder.level3[each.value.parent_folder_name].id
  tags             = each.value.tags

  depends_on = [alicloud_resource_manager_folder.level3]
}

# Level 5 folders
resource "alicloud_resource_manager_folder" "level5" {
  for_each = {
    for folder in local.effective_folder_structure :
    folder.folder_name => folder
    if folder.level == 5
  }

  folder_name      = each.value.folder_name
  parent_folder_id = alicloud_resource_manager_folder.level4[each.value.parent_folder_name].id
  tags             = each.value.tags

  depends_on = [alicloud_resource_manager_folder.level4]
}

# Merge all folders from all levels into a single map
locals {
  all_folders = merge(
    alicloud_resource_manager_folder.level1,
    alicloud_resource_manager_folder.level2,
    alicloud_resource_manager_folder.level3,
    alicloud_resource_manager_folder.level4,
    alicloud_resource_manager_folder.level5
  )
}

