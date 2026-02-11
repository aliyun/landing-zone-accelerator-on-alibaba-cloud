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
}

variable "dmz_vpc_description" {
  type        = string
  description = "The description of DMZ vpc."
  default     = null
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

variable "dmz_egress_nat_gateway_description" {
  type        = string
  description = "The description of the DMZ egress NAT Gateway."
  default     = null
}

variable "dmz_egress_nat_gateway_deletion_protection" {
  type        = bool
  description = "Specifies whether to enable deletion protection for the DMZ egress NAT Gateway."
  default     = false
}

variable "dmz_egress_nat_gateway_eip_bind_mode" {
  type        = string
  description = "The EIP binding mode of the DMZ egress NAT Gateway."
  default     = "MULTI_BINDED"
}

variable "dmz_egress_nat_gateway_icmp_reply_enabled" {
  type        = bool
  description = "Specifies whether to enable ICMP reply on the DMZ egress NAT Gateway."
  default     = true
}

variable "dmz_egress_nat_gateway_private_link_enabled" {
  type        = bool
  description = "Specifies whether to enable PrivateLink on the DMZ egress NAT Gateway."
  default     = false
}

variable "dmz_nat_gateway_snat_entries" {
  description = "SNAT entries configuration for the DMZ NAT Gateway. Passed through to modules/nat-gateway.snat_entries. Only source_cidr is supported (source_vswitch_id is not allowed). snat_ips will be automatically set to all EIP IPs created by this component."
  type = list(object({
    source_cidr     = string
    snat_entry_name = optional(string)
    eip_affinity    = optional(number, 0)
  }))
  default = []
}

variable "dmz_egress_nat_gateway_access_mode" {
  description = "Access mode configuration for reverse access to the DMZ egress NAT Gateway."
  type = set(object({
    mode_value  = string
    tunnel_type = optional(string)
  }))
  default = []
}

variable "dmz_egress_nat_gateway_name" {
  type        = string
  description = "The name of NAT gateway instance for outbound."
  default     = null
}

variable "dmz_egress_eip_instances" {
  description = "List of EIP instance configs for outbound."
  type = list(object({
    eip_address_name          = optional(string)
    payment_type              = optional(string, "PayAsYouGo")
    period                    = optional(number)
    pricing_cycle             = optional(string)
    auto_pay                  = optional(bool, false)
    bandwidth                 = optional(number, 5)
    deletion_protection       = optional(bool, false)
    description               = optional(string)
    internet_charge_type      = optional(string, "PayByBandwidth")
    ip_address                = optional(string)
    isp                       = optional(string, "BGP")
    mode                      = optional(string)
    netmode                   = optional(string, "public")
    public_ip_address_pool_id = optional(string)
    resource_group_id         = optional(string)
    security_protection_type  = optional(string)
    tags                      = optional(map(string), {})
  }))
  default = []
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
}

variable "dmz_common_bandwidth_package_name" {
  type        = string
  description = "The name of the common bandwidth package for DMZ outbound."
  default     = null
}

variable "dmz_common_bandwidth_package_internet_charge_type" {
  type        = string
  description = "The billing method of the common bandwidth package. Valid values: PayByBandwidth, PayBy95, PayByDominantTraffic."
  default     = "PayByBandwidth"
}

variable "dmz_common_bandwidth_package_ratio" {
  type        = number
  description = "The ratio for PayBy95 billing method. Currently only supports 20."
  default     = 20
}

variable "dmz_common_bandwidth_package_deletion_protection" {
  type        = bool
  description = "Specifies whether to enable deletion protection for the common bandwidth package."
  default     = false
}

variable "dmz_common_bandwidth_package_description" {
  type        = string
  description = "The description of the Internet Shared Bandwidth instance."
  default     = null
}

variable "dmz_common_bandwidth_package_isp" {
  type        = string
  description = "The line type of the common bandwidth package."
  default     = "BGP"
}

variable "dmz_common_bandwidth_package_resource_group_id" {
  type        = string
  description = "The ID of the resource group to which you want to move the resource."
  default     = null
}

variable "dmz_common_bandwidth_package_security_protection_types" {
  type        = list(string)
  description = "The edition of Anti-DDoS. Empty list for Anti-DDoS Origin Basic, 'AntiDDoS_Enhanced' for Anti-DDoS Pro(Premium). Valid when internet_charge_type is PayBy95. Maximum 10 security protection types."
  default     = []
}

variable "dmz_common_bandwidth_package_tags" {
  type        = map(string)
  description = "The tags of the common bandwidth package resource."
  default     = {}
}

variable "dmz_vswitch" {
  type = list(object({
    zone_id             = string
    vswitch_name        = string
    vswitch_description = string
    vswitch_cidr        = string
    purpose             = optional(string)
    tags                = optional(map(string))
  }))
  description = "Vswitches in DMZ vpc. Use purpose to specify the vswitch usage: 'TR' for Transit Router attachment (recommend /29 segment, at least 2 vswitches), 'NATGW' for NAT Gateway."

  validation {
    condition = alltrue([
      for vsw in var.dmz_vswitch : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", vsw.vswitch_cidr))
    ])
    error_message = "Each dmz_vswitch.vswitch_cidr must be a valid IPv4 CIDR block, e.g., 192.168.1.0/24."
  }

  validation {
    condition = alltrue([
      for vsw in var.dmz_vswitch : vsw.purpose == null || vsw.purpose == "" || vsw.purpose == "TR" || vsw.purpose == "NATGW"
    ])
    error_message = "Each dmz_vswitch.purpose must be null, empty string, 'TR', or 'NATGW'."
  }

  validation {
    condition = length([
      for vsw in var.dmz_vswitch : vsw if try(vsw.purpose, null) == "TR"
    ]) >= 2
    error_message = "There must be at least 2 vswitches with purpose='TR' (primary and secondary)."
  }

  validation {
    condition = length([
      for vsw in var.dmz_vswitch : vsw if try(vsw.purpose, null) == "NATGW"
    ]) == 1
    error_message = "There must be exactly 1 vswitch with purpose='NATGW'."
  }
}

variable "dmz_tr_attachment_name" {
  type        = string
  description = "Transit Router VPC attachment name. Empty means not set."
  default     = ""
}

variable "dmz_tr_attachment_description" {
  type        = string
  description = "Transit Router VPC attachment description. Empty means not set."
  default     = ""
}

variable "dmz_tr_attachment_force_delete" {
  type        = bool
  description = "Whether to forcibly delete the DMZ VPC connection. When true, related dependencies will be deleted automatically."
  default     = false
}

variable "dmz_tr_attachment_tags" {
  type        = map(string)
  description = "Tags to apply to the DMZ transit router VPC attachment."
  default     = {}
}

variable "dmz_tr_attachment_options" {
  type        = map(string)
  description = "TransitRouterVpcAttachmentOptions for the DMZ VPC attachment."
  default     = { "ipv6Support" = "disable" }
}

variable "cen_service_linked_role_exists" {
  type        = bool
  description = "Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role. If false, the module will create it."
  default     = false
}

variable "create_cen_instance_grant" {
  type        = bool
  description = "Whether to create CEN instance grant for cross-account attachment."
  default     = false
}

variable "dmz_tr_attachment_auto_publish_route_enabled" {
  type        = bool
  description = "Specifies whether to enable the Enterprise Edition transit router to automatically advertise routes to VPCs."
  default     = false
}

variable "dmz_tr_route_table_association_enabled" {
  type        = bool
  description = "Whether to enable route table association for the Transit Router VPC attachment."
  default     = true
}

variable "dmz_tr_route_table_propagation_enabled" {
  type        = bool
  description = "Whether to enable route table propagation for the Transit Router VPC attachment."
  default     = true
}

variable "dmz_vpc_route_entries" {
  description = "List of route entries to add to the DMZ VPC system route table. All entries will use the transit router attachment as the next hop (nexthop_type is fixed to Attachment)."
  type = list(object({
    destination_cidrblock = string
    name                  = optional(string)
    description           = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.dmz_vpc_route_entries : can(cidrhost(entry.destination_cidrblock, 0))
    ])
    error_message = "Each dmz_vpc_route_entry must have a valid destination_cidrblock (valid IPv4 CIDR block)."
  }

  validation {
    condition = alltrue([
      for entry in var.dmz_vpc_route_entries : entry.name == null || (
        try(length(entry.name), 0) >= 1 &&
        try(length(entry.name), 0) <= 128 &&
        !can(regex("^https?://", entry.name))
      )
    ])
    error_message = "Each dmz_vpc_route_entry.name must be 1-128 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for entry in var.dmz_vpc_route_entries : entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each dmz_vpc_route_entry.description must be 1-256 characters and cannot start with http:// or https://."
  }
}

variable "cen_route_entry_cidr_blocks" {
  description = "List of CIDR blocks to publish as CEN route entries. Routes will be published to the Transit Router route table."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.cen_route_entry_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "Each cen_route_entry_cidr_block must be a valid IPv4 CIDR block."
  }
}
