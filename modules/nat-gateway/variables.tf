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
      length(var.nat_gateway_name) >= 2 &&
      length(var.nat_gateway_name) <= 128 &&
      can(regex("^[a-zA-Z0-9._-]+$", var.nat_gateway_name)) &&
      !can(regex("^-", var.nat_gateway_name)) &&
      !can(regex("-$", var.nat_gateway_name)) &&
      !can(regex("^https?://", var.nat_gateway_name))
    )
    error_message = "NAT Gateway name must be null or a string of 2 to 128 characters, contain only alphanumeric characters or hyphens (.-_), not begin or end with a hyphen, and not begin with http:// or https://."
  }
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

variable "payment_type" {
  description = "The billing method of the NAT gateway."
  type        = string
  default     = "PayAsYouGo"

  validation {
    condition     = contains(["PayAsYouGo", "Subscription"], var.payment_type)
    error_message = "Payment type must be either 'PayAsYouGo' or 'Subscription'."
  }
}

variable "period" {
  description = "The duration that you will buy the resource, in month. It is valid when payment_type is Subscription."
  type        = number
  default     = null
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
      # Either source_cidr or source_vswitch_id must be provided, but not both
      (entry.source_cidr != null && entry.source_vswitch_id == null) ||
      (entry.source_cidr == null && entry.source_vswitch_id != null) &&
      # If source_cidr is provided, it must be a valid CIDR
      (entry.source_cidr == null || can(cidrhost(entry.source_cidr, 0))) &&
      # If use_all_associated_eips is false, snat_ips must be provided and valid
      (entry.use_all_associated_eips == true || (
        length(entry.snat_ips) > 0 &&
        alltrue([
          for ip in entry.snat_ips :
          can(regex("^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", ip))
        ])
      )) &&
      # snat_entry_name validation
      (entry.snat_entry_name == null || (
        length(entry.snat_entry_name) >= 2 &&
        length(entry.snat_entry_name) <= 128 &&
        can(regex("^[a-zA-Z]", entry.snat_entry_name)) &&
        !can(regex("^https?://", entry.snat_entry_name))
      )) &&
      # eip_affinity validation
      contains([0, 1], entry.eip_affinity)
    ])
    error_message = "Each SNAT entry must have either source_cidr or source_vswitch_id (but not both), valid snat_ips (when use_all_associated_eips is false), snat_entry_name (2-128 chars, must start with a letter, cannot start with http:// or https://), and eip_affinity (0 or 1) values."
  }
}







