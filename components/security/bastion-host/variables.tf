# Required variables
variable "create_bastion_host_slr" {
  description = "Controls if Bastion Host instance should be created"
  type        = bool
  default     = true
}

# Required variables
variable "create_bastion_host" {
  description = "Controls if Bastion Host instance should be created"
  type        = bool
  default     = true
}

variable "existing_bastionhost_instance_id" {
  description = "ID of the existing Bastion Host instance"
  type        = string
  default     = null
}

# Bastion Host instance configuration variables
variable "bastionhost_description" {
  description = "Description of the Bastion Host instance"
  type        = string
  default     = null

  validation {
    condition     = var.bastionhost_description == null || (try(length(var.bastionhost_description), 0) >= 1 && try(length(var.bastionhost_description), 0) <= 63)
    error_message = "description must be between 1 and 63 characters in length."
  }
}

variable "bastionhost_license_code" {
  description = "License code for the Bastion Host instance"
  type        = string
  default     = null

  validation {
    condition     = var.bastionhost_license_code == null || can(regex("^bhah_ent_.*_asset$", var.bastionhost_license_code))
    error_message = "license_code must match the pattern 'bhah_ent_xxx_asset'."
  }
}

variable "bastionhost_plan_code" {
  description = "Plan code for the Bastion Host instance"
  type        = string
  default     = null

  validation {
    condition     = var.bastionhost_plan_code == null || (var.bastionhost_plan_code == "cloudbastion" || var.bastionhost_plan_code == "cloudbastion_ha")
    error_message = "plan_code must be 'cloudbastion' or 'cloudbastion_ha'."
  }
}

variable "bastionhost_storage" {
  description = "Storage size for the Bastion Host instance (GB)"
  type        = number
  default     = null

  validation {
    condition     = var.bastionhost_storage == null || try((var.bastionhost_storage >= 0 && var.bastionhost_storage <= 500), false)
    error_message = "storage must be a number between 0 and 500."
  }
}

variable "bastionhost_bandwidth" {
  description = "Bandwidth for the Bastion Host instance (Mbps)"
  type        = number
  default     = null

  validation {
    condition     = var.bastionhost_bandwidth == null || try((var.bastionhost_bandwidth >= 0 && var.bastionhost_bandwidth <= 150 && var.bastionhost_bandwidth % 5 == 0), false)
    error_message = "bandwidth must be a number between 0 and 150, and must be a multiple of 5."
  }
}

variable "bastionhost_period" {
  description = "Period for the Bastion Host instance subscription"
  type        = number
  default     = null

  validation {
    condition     = var.bastionhost_period == null || try(((var.bastionhost_period >= 1 && var.bastionhost_period <= 9) || var.bastionhost_period == 12 || var.bastionhost_period == 24 || var.bastionhost_period == 36), false)
    error_message = "period must be one of: 1-9, 12, 24, or 36."
  }
}

variable "bastionhost_vswitch_id" {
  description = "VSwitch ID for the Bastion Host instance"
  type        = string
  default     = null
}

variable "bastionhost_security_group_ids" {
  description = "Security group IDs for the Bastion Host instance"
  type        = set(string)
  default     = []
}

variable "bastionhost_slave_vswitch_id" {
  description = "Slave VSwitch ID for the Bastion Host instance (for HA mode)"
  type        = string
  default     = null
}

variable "bastionhost_tags" {
  description = "Tags for the Bastion Host instance"
  type        = map(string)
  default     = null
}

variable "bastionhost_resource_group_id" {
  description = "Resource group ID for the Bastion Host instance"
  type        = string
  default     = null
}

variable "bastionhost_enable_public_access" {
  description = "Enable public access for the Bastion Host instance"
  type        = bool
  default     = null
}

variable "bastionhost_ad_auth_server" {
  description = "AD auth server for the Bastion Host instance"
  type        = list(object({
    account         = string
    base_dn         = string
    domain          = string
    email_mapping   = optional(string)
    filter          = optional(string)
    is_ssl          = bool
    mobile_mapping  = optional(string)
    name_mapping    = optional(string)
    password        = optional(string)
    port            = optional(number)
    server          = string
    standby_server  = optional(string)
  }))
  default     = null
  nullable    = true
}

variable "bastionhost_ldap_auth_server" {
  description = "LDAP auth server for the Bastion Host instance"
  type        = list(object({
    account             = string
    base_dn             = string
    email_mapping       = optional(string)
    filter              = optional(string)
    is_ssl              = optional(bool)
    login_name_mapping  = optional(string)
    mobile_mapping      = optional(string)
    name_mapping        = optional(string)
    password            = optional(string)
    port                = number
    server              = string
    standby_server      = optional(string)
  }))
  default     = null
  nullable    = true
}

variable "bastionhost_renew_period" {
  description = "Renewal period for the Bastion Host instance"
  type        = number
  default     = null

  validation {
    condition     = var.bastionhost_renew_period == null || try(((var.bastionhost_renew_period >= 1 && var.bastionhost_renew_period <= 9) || var.bastionhost_renew_period == 12 || var.bastionhost_renew_period == 24 || var.bastionhost_renew_period == 36), false)
    error_message = "renew_period must be one of: 1-9, 12, 24, or 36."
  }
}

variable "bastionhost_renewal_status" {
  description = "Renewal status for the Bastion Host instance"
  type        = string
  default     = null

  validation {
    condition     = var.bastionhost_renewal_status == null || try(contains(["AutoRenewal", "ManualRenewal", "NotRenewal"], var.bastionhost_renewal_status), false)
    error_message = "renewal_status must be one of: AutoRenewal, ManualRenewal, NotRenewal."
  }
}

variable "bastionhost_renewal_period_unit" {
  description = "Renewal period unit for the Bastion Host instance (M or Y)"
  type        = string
  default     = null

  validation {
    condition     = var.bastionhost_renewal_period_unit == null || try(contains(["M", "Y"], var.bastionhost_renewal_period_unit), false)
    error_message = "renewal_period_unit must be one of: M, Y."
  }
}

variable "bastionhost_public_white_list" {
  description = "Public white list IP addresses for the Bastion Host instance"
  type        = list(string)
  default     = []
}

variable "bastionhost_host_groups" {
  description = "List of Bastion Host group configurations. Each element contains host group configuration details."
  type        = list(object({
    host_group_name             = string
    comment                     = optional(string)
  }))
  default = []
}

variable "bastionhost_hosts" {
  description = <<-EOT
    List of Bastionhost Host configurations.
    You can specify policies directly, or load them from files/directories.
  EOT
  type        = list(object({
    existing_host_id      = optional(string, null)
    host_config           = optional(object({
      active_address_type   = string
      comment               = optional(string)
      host_name             = optional(string)
      host_private_address  = optional(string)
      host_public_address   = optional(string)
      instance_region_id    = optional(string)
      os_type               = string
      source                = string
      source_instance_id    = optional(string)
    }), null)
    host_group_names      = optional(list(string), [])
    host_accounts         = optional(list(object({
      host_account_name       = string
      pass_phrase             = optional(string)
      password                = optional(string)
      private_key             = optional(string)
      protocol_name           = string
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config != null || host.existing_host_id != null
    ])
    error_message = "Each bastionhost_hosts.host_config or bastionhost_hosts.existing_host_id must be provided."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try(contains(["Public", "Private"], host.host_config.active_address_type), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.active_address_type must be either 'Public' or 'Private'."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try((host.host_config.comment == null ||
      (length(host.host_config.comment) >= 1 && length(host.host_config.comment) <= 500)), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.comment must be 1 to 500 characters in length."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || (
        try(length(host.host_config.host_name), 0) >= 1 && try(length(host.host_config.host_name), 0) <= 128
      )
    ])
    error_message = "Each bastionhost_hosts.host_config.host_name must be 1 to 128 characters in length."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try((host.host_config.active_address_type != "Private" || host.host_config.host_private_address != null), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.host_private_address is required when active_address_type is 'Private'."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try(contains(["Linux", "Windows"], host.host_config.os_type), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.os_type must be either 'Linux' or 'Windows'."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try(contains(["Local", "Ecs", "Rds"], host.host_config.source), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.source must be one of: 'Local', 'Ecs', 'Rds'."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_config == null || try((host.host_config.source == "Local" || host.host_config.source_instance_id != null), false)
    ])
    error_message = "Each bastionhost_hosts.host_config.source_instance_id is required when source is 'Ecs' or 'Rds'."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_accounts == null || alltrue([
        for account in host.host_accounts : (
          try(length(account.host_account_name), 0) >= 1 &&
          try(length(account.host_account_name), 0) <= 128
        )
      ])
    ])
    error_message = "Each bastionhost_hosts.host_accounts[].host_account_name must be 1 to 128 characters in length."
  }

  validation {
    condition = alltrue([
      for host in var.bastionhost_hosts : host.host_accounts == null || alltrue([
        for account in host.host_accounts : try(contains(["SSH", "RDP"], account.protocol_name), false)
      ])
    ])
    error_message = "Each bastionhost_hosts.host_accounts[].protocol_name must be either 'SSH' or 'RDP'."
  }
}

variable "host_file_paths" {
  description = "List of bastionhost hosts file paths (YAML/JSON). Each element should be a file path. Files must contain an array of policy objects."
  type        = list(string)
  default     = []
}

variable "host_dir_paths" {
  description = "List of directory paths containing bastionhost hosts files (YAML/JSON). Files in these directories will be loaded and combined with bastionhost_hosts and host_file_paths. Files must contain an array of bastionhost host objects."
  type        = list(string)
  default     = []
}