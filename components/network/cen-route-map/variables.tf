variable "cen_id" {
  description = "The ID of the CEN instance."
  type        = string
}

variable "tr_region_id" {
  description = "Transit Router region ID."
  type        = string
}

variable "transit_router_route_table_id" {
  description = "Route table ID. If null, uses the default system route table."
  type        = string
  default     = null
}

variable "route_policies" {
  description = <<-EOT
    List of route policies to apply.
    You can specify policies directly, or load them from files/directories.
  EOT
  type = list(object({
    transmit_direction                     = string # RegionIn or RegionOut
    priority                               = number # 1-100
    map_result                             = string # Permit or Deny
    description                            = optional(string)
    next_priority                          = optional(number)
    cidr_match_mode                        = optional(string) # Include or Complete
    as_path_match_mode                     = optional(string) # Include or Complete
    community_match_mode                   = optional(string) # Include or Complete
    community_operate_mode                 = optional(string) # Additive or Replace
    match_asns                             = optional(list(string))
    match_community_set                    = optional(list(string))
    route_types                            = optional(list(string))
    source_instance_ids                    = optional(list(string))
    source_instance_ids_reverse_match      = optional(bool)
    source_route_table_ids                 = optional(list(string))
    source_region_ids                      = optional(list(string))
    source_child_instance_types            = optional(list(string))
    destination_instance_ids               = optional(list(string))
    destination_instance_ids_reverse_match = optional(bool)
    destination_route_table_ids            = optional(list(string))
    destination_child_instance_types       = optional(list(string))
    destination_cidr_blocks                = optional(list(string))
    prepend_as_path                        = optional(list(string))
    preference                             = optional(number)
    operate_community_set                  = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for p in var.route_policies : can(contains(["RegionIn", "RegionOut"], p.transmit_direction))
    ])
    error_message = "transmit_direction must be 'RegionIn' or 'RegionOut'."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies : p.priority >= 1 && p.priority <= 100
    ])
    error_message = "priority must be between 1 and 100."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies : can(contains(["Permit", "Deny"], p.map_result))
    ])
    error_message = "map_result must be 'Permit' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.cidr_match_mode == null || can(contains(["Include", "Complete"], p.cidr_match_mode))
    ])
    error_message = "cidr_match_mode must be 'Include' or 'Complete'."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.as_path_match_mode == null || can(contains(["Include", "Complete"], p.as_path_match_mode))
    ])
    error_message = "as_path_match_mode must be 'Include' or 'Complete'."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.community_match_mode == null || can(contains(["Include", "Complete"], p.community_match_mode))
    ])
    error_message = "community_match_mode must be 'Include' or 'Complete'."
  }

  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.community_operate_mode == null || can(contains(["Additive", "Replace"], p.community_operate_mode))
    ])
    error_message = "community_operate_mode must be 'Additive' or 'Replace'."
  }

  validation {
    condition = length([
      for p in var.route_policies : "${p.transmit_direction}-${p.priority}"
      ]) == length(distinct([
        for p in var.route_policies : "${p.transmit_direction}-${p.priority}"
    ]))
    error_message = "Each policy must have a unique combination of transmit_direction and priority."
  }

  # Preference validation: 1~100, default is 50, smaller value means higher priority
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.preference == null || try(p.preference >= 1 && p.preference <= 100, false)
    ])
    error_message = "preference must be between 1 and 100 (default is 50, smaller value means higher priority)."
  }

  # Description validation: can be empty or 1~256 characters, cannot start with http:// or https://
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.description == null || p.description == "" || try(
        length(p.description) >= 1 && length(p.description) <= 256 &&
        !startswith(p.description, "http://") && !startswith(p.description, "https://"),
        false
      )
    ])
    error_message = "description can be empty or 1~256 characters, and cannot start with 'http://' or 'https://'."
  }

  # match_asns validation: maximum 32 AS numbers
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.match_asns == null || try(length(p.match_asns), 0) <= 32
    ])
    error_message = "match_asns supports a maximum of 32 AS numbers."
  }

  # match_community_set validation: maximum 32 Communities
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.match_community_set == null || try(length(p.match_community_set), 0) <= 32
    ])
    error_message = "match_community_set supports a maximum of 32 Communities."
  }

  # operate_community_set validation: maximum 32 Communities
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.operate_community_set == null || try(length(p.operate_community_set), 0) <= 32
    ])
    error_message = "operate_community_set supports a maximum of 32 Communities."
  }

  # source_region_ids validation: maximum 32 region IDs
  validation {
    condition = alltrue([
      for p in var.route_policies :
      p.source_region_ids == null || try(length(p.source_region_ids), 0) <= 32
    ])
    error_message = "source_region_ids supports a maximum of 32 region IDs."
  }
}

variable "policy_file_paths" {
  description = "List of route policy file paths (YAML/JSON). Each element should be a file path. Files must contain an array of policy objects."
  type        = list(string)
  default     = []
}

variable "policy_dir_paths" {
  description = "List of directory paths containing route policy files (YAML/JSON). Files in these directories will be loaded and combined with route_policies and policy_file_paths. Files must contain an array of policy objects."
  type        = list(string)
  default     = []
}
