variable "vpc_name" {
  description = "The name of the VPC."
  type        = string
  default     = null

  validation {
    condition = var.vpc_name == null || (
      try(length(var.vpc_name), 0) >= 1 && try(length(var.vpc_name), 0) <= 128 && !can(regex("^https?://", var.vpc_name))
    )
    error_message = "The name must be 1 to 128 characters in length and cannot start with http:// or https://."
  }
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC."
  type        = string
  default     = null

  validation {
    condition     = var.vpc_cidr == null || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr))
    error_message = "The vpc_cidr must be a valid IPv4 CIDR block, e.g., 192.168.0.0/16."
  }
}

variable "vpc_description" {
  description = "The description of the VPC."
  type        = string
  default     = null

  validation {
    condition = var.vpc_description == null || (
      try(length(var.vpc_description), 0) >= 1 &&
      try(length(var.vpc_description), 0) <= 256 &&
      !can(regex("^https?://", var.vpc_description))
    )
    error_message = "The description must be 1 to 256 characters in length, and cannot start with http:// or https://."
  }
}

variable "enable_ipv6" {
  description = "Whether to enable IPv6 for the VPC."
  type        = bool
  default     = false
}

variable "ipv6_isp" {
  description = "The type of IPv6 CIDR block. Valid values: BGP (default), ChinaMobile, ChinaUnicom, ChinaTelecom."
  type        = string
  default     = "BGP"

  validation {
    condition     = contains(["BGP", "ChinaMobile", "ChinaUnicom", "ChinaTelecom"], var.ipv6_isp)
    error_message = "ipv6_isp must be one of: BGP, ChinaMobile, ChinaUnicom, ChinaTelecom."
  }
}

variable "resource_group_id" {
  description = "The ID of the resource group to which the VPC belongs."
  type        = string
  default     = null
}

variable "user_cidrs" {
  description = "List of user CIDR blocks. Up to 3 CIDR blocks can be specified."
  type        = list(string)
  default     = null

  validation {
    condition     = var.user_cidrs == null || try(length(var.user_cidrs), 0) <= 3
    error_message = "user_cidrs can have at most 3 CIDR blocks."
  }
}

variable "ipv4_cidr_mask" {
  description = "Allocate VPC from The IPAM address pool by entering a mask."
  type        = number
  default     = null

  validation {
    condition     = var.ipv4_cidr_mask == null || try(var.ipv4_cidr_mask >= 0 && var.ipv4_cidr_mask <= 32, false)
    error_message = "The ipv4_cidr_mask must be an integer between 8 and 32, e.g., 16 for a /16 CIDR block."
  }
}

variable "ipv4_ipam_pool_id" {
  description = "The ID of the IP Address Manager (IPAM) pool that contains IPv4 addresses. When set, you must also set at least one of vpc_cidr or ipv4_cidr_mask manually."
  type        = string
  default     = null
}

variable "ipv6_cidr_block" {
  description = "The IPv6 CIDR block of the default VPC. When enable_ipv6 is true, this field must be set manually."
  type        = string
  default     = null
}

variable "vpc_tags" {
  description = "Tags of the VPC."
  type        = map(string)
  default     = {}
}

variable "vswitches" {
  description = "List of VSwitches. Each element contains vswitch_name, cidr_block, zone_id, etc."
  type = list(object({
    cidr_block           = string
    zone_id              = string
    vswitch_name         = optional(string)
    description          = optional(string)
    enable_ipv6          = optional(bool)
    ipv6_cidr_block_mask = optional(number)
    tags                 = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for vsw in var.vswitches : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", vsw.cidr_block))
    ])
    error_message = "Each vswitch.cidr_block must be a valid IPv4 CIDR block, e.g., 192.168.1.0/24."
  }
}

variable "enable_acl" {
  description = "Whether to enable VPC Network ACL."
  type        = bool
  default     = false
}

variable "acl_name" {
  description = "The name of the network ACL."
  type        = string
  default     = null

  validation {
    condition = var.acl_name == null || (
      try(length(var.acl_name), 0) >= 1 &&
      try(length(var.acl_name), 0) <= 128 &&
      !can(regex("^https?://", var.acl_name))
    )
    error_message = "The name must be 1 to 128 characters in length and cannot start with http:// or https://."
  }
}

variable "acl_description" {
  description = "The description of the network ACL."
  type        = string
  default     = null

  validation {
    condition = var.acl_description == null || (
      try(length(var.acl_description), 0) >= 1 &&
      try(length(var.acl_description), 0) <= 256 &&
      !can(regex("^https?://", var.acl_description))
    )
    error_message = "The description must be 1 to 256 characters in length and cannot start with http:// or https://."
  }
}

variable "acl_tags" {
  description = "The tags of the network ACL."
  type        = map(string)
  default     = {}
}

variable "ingress_acl_entries" {
  description = "List of ingress ACL entries for the network ACL. Each entry is an object with properties such as policy, protocol, port, source_cidr_ip, description, network_acl_entry_name, ip_version, etc."
  type = list(object({
    protocol               = string
    port                   = string
    source_cidr_ip         = string
    policy                 = optional(string, "accept")
    description            = optional(string)
    network_acl_entry_name = optional(string)
    ip_version             = optional(string, "IPV4")
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      !contains(keys(entry), "description") || entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each ingress_acl_entry.description must be 1-256 chars and not start with http(s)."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      !contains(keys(entry), "ip_version") || entry.ip_version == null || try(contains(["IPV4", "IPV6"], try(upper(entry.ip_version), "")), false)
    ])
    error_message = "Each ingress_acl_entry.ip_version must be IPV4 or IPV6."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      !contains(keys(entry), "network_acl_entry_name") || entry.network_acl_entry_name == null || (
        try(length(entry.network_acl_entry_name), 0) >= 1 &&
        try(length(entry.network_acl_entry_name), 0) <= 128 &&
        !can(regex("^https?://", entry.network_acl_entry_name))
      )
    ])
    error_message = "Each ingress_acl_entry.network_acl_entry_name must be 1-128 chars and not start with http(s)."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      contains(["accept", "drop"], entry.policy)
    ])
    error_message = "Each ingress_acl_entry.policy must be 'accept' or 'drop'."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      contains(["icmp", "gre", "tcp", "udp", "all"], entry.protocol)
    ])
    error_message = "Each ingress_acl_entry.protocol must be one of: icmp, gre, tcp, udp, all."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      contains(["all", "icmp", "gre"], entry.protocol) ? entry.port == "-1/-1" : can(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port))
    ])
    error_message = "Each ingress_acl_entry.port must be '-1/-1' for all/icmp/gre protocols, or in format 'start_port/end_port' for tcp/udp protocols."
  }

  validation {
    condition = alltrue([
      for entry in var.ingress_acl_entries :
      contains(["all", "icmp", "gre"], entry.protocol) || entry.port == "-1/-1" || try(
        can(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)) && (
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[0]) >= 1 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[0]) <= 65535 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[1]) >= 1 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[1]) <= 65535
        ),
        false
      )
    ])
    error_message = "Each ingress_acl_entry.port start_port and end_port must be 1-65535 for tcp/udp protocols."
  }
}

variable "egress_acl_entries" {
  description = "List of egress ACL entries for the network ACL. Each entry is an object with properties such as policy, protocol, port, destination_cidr_ip, description, network_acl_entry_name, ip_version, etc."
  type = list(object({
    protocol               = string
    port                   = string
    destination_cidr_ip    = string
    policy                 = optional(string, "accept")
    description            = optional(string)
    network_acl_entry_name = optional(string)
    ip_version             = optional(string, "IPV4")
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      !contains(keys(entry), "description") || entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each egress_acl_entry.description must be 1-256 chars and not start with http(s)."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      !contains(keys(entry), "ip_version") || entry.ip_version == null || try(contains(["IPV4", "IPV6"], try(upper(entry.ip_version), "")), false)
    ])
    error_message = "Each egress_acl_entry.ip_version must be IPV4 or IPV6."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      !contains(keys(entry), "network_acl_entry_name") || entry.network_acl_entry_name == null || (
        try(length(entry.network_acl_entry_name), 0) >= 1 &&
        try(length(entry.network_acl_entry_name), 0) <= 128 &&
        !can(regex("^https?://", entry.network_acl_entry_name))
      )
    ])
    error_message = "Each egress_acl_entry.network_acl_entry_name must be 1-128 chars and not start with http(s)."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      contains(["accept", "drop"], entry.policy)
    ])
    error_message = "Each egress_acl_entry.policy must be 'accept' or 'drop'."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      contains(["icmp", "gre", "tcp", "udp", "all"], entry.protocol)
    ])
    error_message = "Each egress_acl_entry.protocol must be one of: icmp, gre, tcp, udp, all."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      contains(["all", "icmp", "gre"], entry.protocol) ? entry.port == "-1/-1" : can(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port))
    ])
    error_message = "Each egress_acl_entry.port must be '-1/-1' for all/icmp/gre protocols, or in format 'start_port/end_port' for tcp/udp protocols."
  }

  validation {
    condition = alltrue([
      for entry in var.egress_acl_entries :
      contains(["all", "icmp", "gre"], entry.protocol) || entry.port == "-1/-1" || try(
        can(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)) && (
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[0]) >= 1 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[0]) <= 65535 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[1]) >= 1 &&
          tonumber(regex("^(\\d{1,5})/(\\d{1,5})$", entry.port)[1]) <= 65535
        ),
        false
      )
    ])
    error_message = "Each egress_acl_entry.port start_port and end_port must be 1-65535 for tcp/udp protocols."
  }
}
