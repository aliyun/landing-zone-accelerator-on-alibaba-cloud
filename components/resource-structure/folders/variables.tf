variable "folder_structure" {
  description = "List of folder configurations to create in the resource directory. Folders will be created in hierarchical order based on level and parent_folder_name."
  type = list(object({
    folder_name        = string
    parent_folder_name = optional(string, null) # null means root level
    level              = number
    tags               = optional(map(string), {}) # Tags for the folder
  }))
  default = []

  validation {
    condition = alltrue([
      for folder in var.folder_structure :
      folder.level >= 1 && folder.level <= 5
    ])
    error_message = "Folder level must be between 1 and 5."
  }

  validation {
    condition = alltrue([
      for folder in var.folder_structure :
      can(regex("^[\u4e00-\u9fa5a-zA-Z0-9_.-]{1,24}$", folder.folder_name))
    ])
    error_message = "Folder name must be 1-24 characters and can only contain Chinese characters, English letters, numbers, underscores (_), periods (.), and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for folder in var.folder_structure :
      folder.parent_folder_name == null || (folder.parent_folder_name != null && can(regex("^[\u4e00-\u9fa5a-zA-Z0-9_.-]{1,24}$", folder.parent_folder_name)))
    ])
    error_message = "Parent folder name must be 1-24 characters and can only contain Chinese characters, English letters, numbers, underscores (_), periods (.), and hyphens (-)."
  }

  validation {
    condition = length([
      for folder in var.folder_structure :
      folder if folder.level == 1 && folder.parent_folder_name != null
    ]) == 0
    error_message = "Level 1 folders must not have a parent_folder_name (they are root level)."
  }

  validation {
    condition = length([
      for folder in var.folder_structure :
      folder if folder.level > 1 && folder.parent_folder_name == null
    ]) == 0
    error_message = "Level 2-5 folders must have a parent_folder_name."
  }

  validation {
    condition = length(distinct([
      for folder in var.folder_structure :
      "${folder.level}-${folder.folder_name}"
    ])) == length(var.folder_structure)
    error_message = "Folder names must be unique within the same level."
  }
}

variable "folder_structure_file_path" {
  description = "Path to a JSON or YAML file that defines folder_structure. When provided, it overrides folder_structure input. Supports .json, .yaml, .yml."
  type        = string
  default     = null
}

