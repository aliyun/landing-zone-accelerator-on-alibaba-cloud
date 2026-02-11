variable "vpc_id" {
  description = "The ID of the VPC in which to create the security groups."
  type        = string
}

variable "security_groups" {
  description = "List of security group configurations. Each security group can have its own rules and settings."
  type = list(object({
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
  }))
  default = []
}

variable "security_group_dir_path" {
  description = "Directory path containing security group configuration files (YAML/JSON). Each file in this directory can contain a single security group object or a list of security group objects. Files will be loaded and combined with security_groups."
  type        = string
  default     = null
}

