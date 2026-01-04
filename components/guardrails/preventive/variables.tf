variable "control_policies" {
  description = <<-EOT
    A list of control policies to create and their attachments.
    
    Note on target_folder_names: Folders can have the same name at different levels. If there are duplicate folder names, all matching folders will be bound to the control policy. For precise control, it is recommended to use target_ids to specify folder IDs instead.
  EOT
  type = list(object({
    name                         = string
    description                  = optional(string)
    policy_document              = string
    tags                         = optional(map(string), {})
    target_ids                   = optional(list(string), [])
    target_account_display_names = optional(list(string), [])
    target_folder_names          = optional(list(string), [])
    target_folder_name_regexes   = optional(list(string), [])
    attach_to_root               = optional(bool, false)
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.control_policies :
      length(policy.name) >= 1 && length(policy.name) <= 128
    ])
    error_message = "Policy name must be between 1 and 128 characters."
  }


  validation {
    condition = alltrue([
      for policy in var.control_policies :
      can(jsondecode(policy.policy_document))
    ])
    error_message = "Policy document must be valid JSON."
  }
}

variable "control_policies_dir" {
  description = "Directory path containing control policy configuration files (JSON/YAML). Files in this directory will be loaded and combined with control_policies, with file configurations taking priority over inline configurations for matching names."
  type        = string
  default     = null
}
