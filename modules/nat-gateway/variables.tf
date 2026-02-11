variable "vpc_id" {
  description = "VPC ID for NAT gateway."
  type        = string
  default     = ""
}

variable "vswitch_id" {
  description = "VSwitch ID for NAT gateway."
  type        = string
}

variable "nat_gateway_name" {
  description = "Name of the nat gateway."
  type        = string
  default     = null

  validation {
    condition = var.nat_gateway_name == null || (
      try(length(var.nat_gateway_name), 0) >= 2 &&
      try(length(var.nat_gateway_name), 0) <= 128 &&
      can(regex("^[a-zA-Z0-9._-]+$", var.nat_gateway_name)) &&
      !can(regex("^-", var.nat_gateway_name)) &&
      !can(regex("-$", var.nat_gateway_name)) &&
      !can(regex("^https?://", var.nat_gateway_name))
    )
    error_message = "NAT Gateway name must be null or a string of 2 to 128 characters, contain only alphanumeric characters or hyphens (.-_), not begin or end with a hyphen, and not begin with http:// or https://."
  }
}

variable "description" {
  description = "Description of the NAT gateway."
  type        = string
  default     = null

  validation {
    condition = var.description == null || (
      try(length(var.description), 0) >= 2 &&
      try(length(var.description), 0) <= 256 &&
      !can(regex("^https?://", var.description))
    )
    error_message = "description must be null or 2-256 characters and must not start with http:// or https://."
  }
}

variable "force" {
  description = "Specifies whether to forcefully delete the NAT gateway."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tag for NAT Gateway"
  type        = map(string)
  default     = null
}

variable "association_eip_ids" {
  type        = list(string)
  description = "EIP instance ID associated with NAT gateway."
  default     = []
}

variable "network_type" {
  description = "Indicates the type of the created NAT gateway.Valid values internet and intranet. internet: Internet NAT Gateway. intranet: VPC NAT Gateway."
  type        = string
  default     = "internet"

  validation {
    condition     = contains(["internet", "intranet"], var.network_type)
    error_message = "Network type must be either 'internet' or 'intranet'."
  }
}

variable "deletion_protection" {
  description = "Whether to enable deletion protection for the NAT gateway."
  type        = bool
  default     = false
}

variable "eip_bind_mode" {
  description = "The EIP binding mode of the NAT gateway."
  type        = string
  default     = "MULTI_BINDED"

  validation {
    condition     = contains(["MULTI_BINDED", "NAT"], var.eip_bind_mode)
    error_message = "eip_bind_mode must be either 'MULTI_BINDED' or 'NAT'."
  }
}

variable "icmp_reply_enabled" {
  description = "Specifies whether to enable ICMP reply on the NAT gateway."
  type        = bool
  default     = true
}

variable "private_link_enabled" {
  description = "Specifies whether to enable PrivateLink on the NAT gateway."
  type        = bool
  default     = false
}

variable "access_mode" {
  description = "Access mode configuration for reverse access to the VPC NAT gateway."
  type = set(object({
    mode_value  = string
    tunnel_type = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for m in var.access_mode :
      contains(["route", "tunnel"], m.mode_value)
    ])
    error_message = "Each access_mode.mode_value must be 'route' or 'tunnel'."
  }

  validation {
    condition = alltrue([
      for m in var.access_mode :
      m.mode_value != "tunnel" || m.tunnel_type == null || m.tunnel_type == "geneve"
    ])
    error_message = "If access_mode.mode_value is 'tunnel' and tunnel_type is set, it must be 'geneve'."
  }
}

variable "snat_entries" {
  description = "List of SNAT entries to create."
  type = list(object({
    source_cidr             = optional(string)
    source_vswitch_id       = optional(string)
    snat_ips                = optional(list(string), [])
    use_all_associated_eips = optional(bool, false)
    snat_entry_name         = optional(string)
    eip_affinity            = optional(number, 0)
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      (entry.source_cidr != null && entry.source_vswitch_id == null) ||
      (entry.source_cidr == null && entry.source_vswitch_id != null)
    ])
    error_message = "Each SNAT entry must have either source_cidr or source_vswitch_id (but not both)."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.source_cidr == null || can(cidrhost(entry.source_cidr, 0))
    ])
    error_message = "Each SNAT entry.source_cidr must be a valid IPv4 CIDR block."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.use_all_associated_eips == true || length(entry.snat_ips) > 0
    ])
    error_message = "When use_all_associated_eips is false, snat_ips must be provided and non-empty."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.use_all_associated_eips == true || alltrue([
        for ip in entry.snat_ips :
        can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
      ])
    ])
    error_message = "Each SNAT entry.snat_ips must contain valid IPv4 addresses."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.snat_entry_name == null || try(length(entry.snat_entry_name), 0) >= 2
    ])
    error_message = "Each SNAT entry.snat_entry_name must be at least 2 characters."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.snat_entry_name == null || try(length(entry.snat_entry_name), 0) <= 128
    ])
    error_message = "Each SNAT entry.snat_entry_name must be at most 128 characters."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.snat_entry_name == null || can(regex("^[a-zA-Z]", entry.snat_entry_name))
    ])
    error_message = "Each SNAT entry.snat_entry_name must start with a letter."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      entry.snat_entry_name == null || !can(regex("^https?://", entry.snat_entry_name))
    ])
    error_message = "Each SNAT entry.snat_entry_name cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for entry in var.snat_entries :
      contains([0, 1], entry.eip_affinity)
    ])
    error_message = "Each SNAT entry.eip_affinity must be 0 or 1."
  }
}







