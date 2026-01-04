output "resource_directory_id" {
  description = "The ID of the resource directory."
  value       = data.alicloud_resource_manager_resource_directories.default.directories[0].id
}

output "root_folder_id" {
  description = "The ID of the root folder."
  value       = data.alicloud_resource_manager_resource_directories.default.directories[0].root_folder_id
}

output "folder_structure" {
  description = "The folder structure as a list derived from all created folders, with IDs."
  value = [
    for folder_name, folder in local.all_folders : {
      id                 = folder.id
      folder_name        = folder.folder_name
      parent_folder_id   = folder.parent_folder_id
      level              = local.folder_config_map[folder_name].level
      parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
    }
  ]
}

output "folders_by_level" {
  description = "Folders grouped by level for easy reference."
  value = {
    level1 = {
      for folder_name, folder in alicloud_resource_manager_folder.level1 :
      folder_name => {
        id                 = folder.id
        folder_name        = folder.folder_name
        parent_folder_id   = folder.parent_folder_id
        level              = local.folder_config_map[folder_name].level
        parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
      }
    }
    level2 = {
      for folder_name, folder in alicloud_resource_manager_folder.level2 :
      folder_name => {
        id                 = folder.id
        folder_name        = folder.folder_name
        parent_folder_id   = folder.parent_folder_id
        level              = local.folder_config_map[folder_name].level
        parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
      }
    }
    level3 = {
      for folder_name, folder in alicloud_resource_manager_folder.level3 :
      folder_name => {
        id                 = folder.id
        folder_name        = folder.folder_name
        parent_folder_id   = folder.parent_folder_id
        level              = local.folder_config_map[folder_name].level
        parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
      }
    }
    level4 = {
      for folder_name, folder in alicloud_resource_manager_folder.level4 :
      folder_name => {
        id                 = folder.id
        folder_name        = folder.folder_name
        parent_folder_id   = folder.parent_folder_id
        level              = local.folder_config_map[folder_name].level
        parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
      }
    }
    level5 = {
      for folder_name, folder in alicloud_resource_manager_folder.level5 :
      folder_name => {
        id                 = folder.id
        folder_name        = folder.folder_name
        parent_folder_id   = folder.parent_folder_id
        level              = local.folder_config_map[folder_name].level
        parent_folder_name = local.folder_config_map[folder_name].parent_folder_name
      }
    }
  }
}

