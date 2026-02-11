# CEN Attachment Common Configuration (shared across all VPCs)
variable "cen_instance_id" {
  description = "The ID of the CEN instance (shared for all VPCs)."
  type        = string
  default     = null
}

variable "cen_tr_id" {
  description = "The ID of the CEN Transit Router (shared for all VPCs)."
  type        = string
  default     = null
}

variable "cen_tr_route_table_id" {
  description = "The ID of the CEN Transit Router route table (shared for all VPCs)."
  type        = string
  default     = ""
}

variable "cen_service_linked_role_exists" {
  description = "Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role. If false, the module will create it."
  type        = bool
  default     = true
}

variable "create_cen_instance_grant" {
  description = "Whether to create CEN instance grant for cross-account attachment."
  type        = bool
  default     = true
}

# VPC Networks Configuration (list of VPCs to create)
variable "vpcs" {
  description = "List of VPC networking configurations. Each VPC can have its own CEN attachment settings."
  type = list(object({
    # VPC variables
    vpc_name          = string
    vpc_cidr          = string
    vpc_description   = optional(string)
    enable_ipv6       = optional(bool, false)
    ipv6_isp          = optional(string, "BGP")
    resource_group_id = optional(string)
    user_cidrs        = optional(list(string), [])
    ipv4_cidr_mask    = optional(number)
    ipv4_ipam_pool_id = optional(string)
    ipv6_cidr_block   = optional(string)
    vpc_tags          = optional(map(string), {})

    # VSwitch variables
    vswitches = list(object({
      cidr_block           = string
      zone_id              = string
      vswitch_name         = optional(string)
      description          = optional(string)
      enable_ipv6          = optional(bool)
      ipv6_cidr_block_mask = optional(number)
      tags                 = optional(map(string))
      purpose              = optional(string, null)
    }))

    # Network ACL variables
    enable_acl      = optional(bool, false)
    acl_name        = optional(string)
    acl_description = optional(string)
    acl_tags        = optional(map(string), {})
    ingress_acl_entries = optional(list(object({
      protocol               = string
      port                   = string
      source_cidr_ip         = string
      policy                 = optional(string, "accept")
      description            = optional(string)
      network_acl_entry_name = optional(string)
      ip_version             = optional(string, "IPV4")
    })), [])
    egress_acl_entries = optional(list(object({
      protocol               = string
      port                   = string
      destination_cidr_ip    = string
      policy                 = optional(string, "accept")
      description            = optional(string)
      network_acl_entry_name = optional(string)
      ip_version             = optional(string, "IPV4")
    })), [])

    # CEN attachment variables
    cen_attachment = optional(object({
      enabled                                      = optional(bool, false)
      cen_tr_attachment_name                       = optional(string, "")
      cen_tr_attachment_description                = optional(string, "")
      cen_tr_route_table_association_enabled       = optional(bool, true)
      cen_tr_route_table_propagation_enabled       = optional(bool, true)
      cen_tr_attachment_auto_publish_route_enabled = optional(bool, false)
      cen_tr_attachment_force_delete               = optional(bool, false)
      cen_tr_attachment_payment_type               = optional(string, "PayAsYouGo")
      cen_tr_attachment_tags                       = optional(map(string), {})
      cen_tr_attachment_options                    = optional(map(string), { "ipv6Support" = "disable" })
      cen_tr_attachment_resource_type              = optional(string, "VPC")
      vpc_route_entries = optional(list(object({
        destination_cidrblock = string
        name                  = optional(string)
        description           = optional(string)
      })), [])
    }), {})

    # Security groups variables
    security_groups = optional(list(object({
      security_group_name = string # Required: used as key for for_each
      description         = optional(string)
      inner_access_policy = optional(string) # Accept or Drop
      resource_group_id   = optional(string)
      security_group_type = optional(string, "normal") # normal or enterprise
      tags                = optional(map(string), {})
      rules = optional(list(object({
        type                       = string                     # ingress or egress
        ip_protocol                = string                     # tcp, udp, icmp, icmpv6, gre, all
        policy                     = optional(string, "accept") # accept or drop
        priority                   = optional(number, 1)
        cidr_ip                    = optional(string)
        ipv6_cidr_ip               = optional(string)
        source_security_group_id   = optional(string)
        source_group_owner_account = optional(string)
        prefix_list_id             = optional(string)
        port_range                 = optional(string, "-1/-1")
        nic_type                   = optional(string, "internet") # internet or intranet
        description                = optional(string)
      })), [])
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for vpc in var.vpcs :
      length(vpc.vswitches) > 0
    ])
    error_message = "Each VPC must have at least one vswitch."
  }

  validation {
    condition = alltrue([
      for vpc in var.vpcs :
      alltrue([
        for vsw in vpc.vswitches :
        try(vsw.purpose, null) == null || try(vsw.purpose, null) == "TR"
      ])
    ])
    error_message = "vswitch purpose can only be null or \"TR\"."
  }
}

variable "vpc_dir_path" {
  description = "Directory path containing VPC configuration files (YAML/JSON). Each file in this directory must contain a single VPC object. Files will be loaded and combined with vpcs."
  type        = string
  default     = null
}

