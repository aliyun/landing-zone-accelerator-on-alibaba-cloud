variable "cen_instance_id" {
  type = string
}

variable "cen_transit_router_id" {
  type = string
}

variable "transit_router_route_table_id" {
  type = string
}

variable "dmz_vpc_name" {
  type        = string
  description = "The name of DMZ vpc."
  default     = null

  validation {
    condition = var.dmz_vpc_name == null || (
      length(var.dmz_vpc_name) >= 1 && length(var.dmz_vpc_name) <= 128 && !can(regex("^https?://", var.dmz_vpc_name))
    )
    error_message = "The name must be 1 to 128 characters in length and cannot start with http:// or https://."
  }
}

variable "dmz_vpc_description" {
  type        = string
  description = "The description of DMZ vpc."
  default     = null

  validation {
    condition = var.dmz_vpc_description == null || (
      length(var.dmz_vpc_description) >= 1 &&
      length(var.dmz_vpc_description) <= 256 &&
      !can(regex("^https?://", var.dmz_vpc_description))
    )
    error_message = "The description must be 1 to 256 characters in length, and cannot start with http:// or https://."
  }
}

variable "dmz_vpc_cidr" {
  type        = string
  description = "DMZ vpc cidr block."

  validation {
    condition     = var.dmz_vpc_cidr == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.dmz_vpc_cidr))
    error_message = "The dmz_vpc_cidr must be a valid IPv4 CIDR block, e.g., 192.168.0.0/16."
  }
}

variable "dmz_vpc_tags" {
  type        = map(string)
  description = "A map of tags to assign to the DMZ VPC."
  default     = {}
}

variable "dmz_egress_nat_gateway_tags" {
  type        = map(string)
  description = "A map of tags to assign to the DMZ egress NAT Gateway."
  default     = {}
}

variable "dmz_egress_nat_gateway_name" {
  type        = string
  description = "The name of NAT gateway instance for outbound."
  default     = null

  validation {
    condition = var.dmz_egress_nat_gateway_name == null || (
      length(var.dmz_egress_nat_gateway_name) >= 2 &&
      length(var.dmz_egress_nat_gateway_name) <= 128 &&
      can(regex("^[a-zA-Z0-9._-]+$", var.dmz_egress_nat_gateway_name)) &&
      !can(regex("^-", var.dmz_egress_nat_gateway_name)) &&
      !can(regex("-$", var.dmz_egress_nat_gateway_name)) &&
      !can(regex("^https?://", var.dmz_egress_nat_gateway_name))
    )
    error_message = "NAT Gateway name must be null or a string of 2 to 128 characters, contain only alphanumeric characters or hyphens (.-_), not begin or end with a hyphen, and not begin with http:// or https://."
  }
}

variable "dmz_egress_eip_instances" {
  description = "List of EIP instance configs for outbound."
  type = list(object({
    payment_type     = optional(string, "PayAsYouGo")
    period           = optional(number)
    eip_address_name = optional(string)
    tags             = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for instance in var.dmz_egress_eip_instances :
      (
        instance.eip_address_name == null ||
        can(regex("^[a-zA-Z][a-zA-Z0-9._-]{0,127}$", instance.eip_address_name))
      )
    ])
    error_message = "eip_address_name must be empty or 1 to 128 characters in length, start with a letter, and contain only letters, digits, periods (.), underscores (_), and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for instance in var.dmz_egress_eip_instances :
      (
        instance.payment_type == null ||
        contains(["Subscription", "PayAsYouGo"], instance.payment_type)
      )
    ])
    error_message = "payment_type must be empty or one of 'Subscription' or 'PayAsYouGo'."
  }
}

variable "dmz_enable_common_bandwidth_package" {
  type        = bool
  description = "Whether to enable common bandwidth package for all EIP instances."
  default     = true
}

variable "dmz_common_bandwidth_package_bandwidth" {
  type        = string
  description = "The bandwidth for DMZ outbound. Unit: Mbps."
  default     = "5"

  validation {
    condition = (
      can(regex("^[0-9]+$", var.dmz_common_bandwidth_package_bandwidth)) &&
      tonumber(var.dmz_common_bandwidth_package_bandwidth) >= 1 &&
      tonumber(var.dmz_common_bandwidth_package_bandwidth) <= 1000
    )
    error_message = "dmz_common_bandwidth_package_bandwidth must be an integer between 1 and 1000."
  }
}

variable "dmz_common_bandwidth_package_name" {
  type        = string
  description = "The name of the common bandwidth package for DMZ outbound."
  default     = null

  validation {
    condition = (
      var.dmz_common_bandwidth_package_name == null || (
        can(regex("^[a-zA-Z].*$", var.dmz_common_bandwidth_package_name)) &&
        !can(regex("^https?://", var.dmz_common_bandwidth_package_name)) &&
        length(var.dmz_common_bandwidth_package_name) >= 2 &&
        length(var.dmz_common_bandwidth_package_name) <= 256
      )
    )
    error_message = "dmz_common_bandwidth_package_name may be null, or must be 2 to 256 characters, start with a letter, and must not start with http:// or https://."
  }
}

variable "dmz_common_bandwidth_package_internet_charge_type" {
  type        = string
  description = "The billing method of the common bandwidth package. Valid values: PayByBandwidth, PayBy95, PayByDominantTraffic."
  default     = "PayByBandwidth"

  validation {
    condition     = contains(["PayByBandwidth", "PayBy95", "PayByDominantTraffic"], var.dmz_common_bandwidth_package_internet_charge_type)
    error_message = "dmz_common_bandwidth_package_internet_charge_type must be one of 'PayByBandwidth', 'PayBy95', or 'PayByDominantTraffic'."
  }
}

variable "dmz_common_bandwidth_package_ratio" {
  type        = number
  description = "The ratio for PayBy95 billing method. Currently only supports 20."
  default     = 20

  validation {
    condition     = var.dmz_common_bandwidth_package_ratio == 20
    error_message = "dmz_common_bandwidth_package_ratio must be 20."
  }
}

variable "dmz_vswitch_for_tr" {
  type = list(object({
    zone_id             = string
    vswitch_name        = string
    vswitch_description = string
    vswitch_cidr        = string
    tags                = optional(map(string))
  }))
  description = "Vswitches in DMZ vpc for Transit Router. Recommend a segment of /29. Should have 2 vswitches."

  validation {
    condition     = length(var.dmz_vswitch_for_tr) == 2
    error_message = "dmz_vswitch_for_tr must contain exactly 2 vswitches (primary and secondary)."
  }

  validation {
    condition = alltrue([
      for vsw in var.dmz_vswitch_for_tr : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", vsw.vswitch_cidr))
    ])
    error_message = "Each dmz_vswitch_for_tr.vswitch_cidr must be a valid IPv4 CIDR block, e.g., 192.168.1.0/29."
  }
}

variable "dmz_vswitch_for_nat_gateway" {
  type = object({
    zone_id             = string
    vswitch_name        = string
    vswitch_description = string
    vswitch_cidr        = string
    tags                = optional(map(string))
  })
  description = "Vswitch for Enhanced NAT gateway."

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.dmz_vswitch_for_nat_gateway.vswitch_cidr))
    error_message = "dmz_vswitch_for_nat_gateway.vswitch_cidr must be a valid IPv4 CIDR block, e.g., 192.168.1.0/24."
  }
}

variable "dmz_vswitch" {
  type = list(object({
    zone_id             = string
    vswitch_name        = string
    vswitch_description = string
    vswitch_cidr        = string
    tags                = optional(map(string))
  }))
  description = "Vswitches in DMZ vpc."

  validation {
    condition = alltrue([
      for vsw in var.dmz_vswitch : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", vsw.vswitch_cidr))
    ])
    error_message = "Each dmz_vswitch.vswitch_cidr must be a valid IPv4 CIDR block, e.g., 192.168.1.0/24."
  }
}

variable "dmz_tr_attachment_name" {
  type        = string
  description = "Transit Router VPC attachment name. Empty means not set."
  default     = ""

  validation {
    condition = var.dmz_tr_attachment_name == "" || (
      length(var.dmz_tr_attachment_name) >= 2 &&
      length(var.dmz_tr_attachment_name) <= 128 &&
      !can(regex("^https?://", var.dmz_tr_attachment_name))
    )
    error_message = "dmz_tr_attachment_name may be empty, or must be 2-128 characters and must not start with http:// or https://."
  }
}

variable "dmz_tr_attachment_description" {
  type        = string
  description = "Transit Router VPC attachment description. Empty means not set."
  default     = ""

  validation {
    condition = var.dmz_tr_attachment_description == "" || (
      length(var.dmz_tr_attachment_description) >= 1 &&
      length(var.dmz_tr_attachment_description) <= 256 &&
      !can(regex("^https?://", var.dmz_tr_attachment_description))
    )
    error_message = "dmz_tr_attachment_description may be empty, or must be 1-256 characters and must not start with http:// or https://."
  }
}

variable "dmz_outbound_route_entry_name" {
  type        = string
  description = "Name of the outbound route entry in Transit Router."
  default     = null

  validation {
    condition = var.dmz_outbound_route_entry_name == null || (
      length(var.dmz_outbound_route_entry_name) >= 2 &&
      length(var.dmz_outbound_route_entry_name) <= 128 &&
      can(regex("^[a-zA-Z]", var.dmz_outbound_route_entry_name)) &&
      !can(regex("^https?://", var.dmz_outbound_route_entry_name))
    )
    error_message = "dmz_outbound_route_entry_name may be null, or must be 2-128 characters, start with a letter, and must not start with http:// or https://."
  }
}

variable "dmz_outbound_route_entry_description" {
  type        = string
  description = "Description of the outbound route entry in Transit Router."
  default     = null

  validation {
    condition = var.dmz_outbound_route_entry_description == null || (
      length(var.dmz_outbound_route_entry_description) >= 1 &&
      length(var.dmz_outbound_route_entry_description) <= 256 &&
      !can(regex("^https?://", var.dmz_outbound_route_entry_description))
    )
    error_message = "dmz_outbound_route_entry_description may be null, or must be 1-256 characters and must not start with http:// or https://."
  }
}
