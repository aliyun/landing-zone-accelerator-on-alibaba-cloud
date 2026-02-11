variable "vpc_id" {
  description = "The ID of the VPC in which you want to create the security group."
  type        = string

  validation {
    condition     = var.vpc_id != null && var.vpc_id != ""
    error_message = "vpc_id is required and cannot be empty."
  }
}

variable "security_group_name" {
  description = "The name of the security group. The name must be 2 to 128 characters in length. The name must start with a letter and cannot start with http:// or https://. The name can contain Unicode characters under the Decimal Number category and the categories whose names contain Letter. The name can also contain colons (:), underscores (_), periods (.), and hyphens (-)."
  type        = string
  default     = null

  validation {
    condition = var.security_group_name == null || (
      try(length(var.security_group_name), 0) >= 2 &&
      try(length(var.security_group_name), 0) <= 128 &&
      !can(regex("^https?://", var.security_group_name)) &&
      can(regex("^[a-zA-Z]", var.security_group_name))
    )
    error_message = "The security_group_name must be 2 to 128 characters in length, start with a letter, and cannot start with http:// or https://."
  }
}

variable "description" {
  description = "The description of the security group. The description must be 2 to 256 characters in length. It cannot start with http:// or https://."
  type        = string
  default     = null

  validation {
    condition = var.description == null || (
      try(length(var.description), 0) >= 2 &&
      try(length(var.description), 0) <= 256 &&
      !can(regex("^https?://", var.description))
    )
    error_message = "The description must be 2 to 256 characters in length and cannot start with http:// or https://."
  }
}

variable "inner_access_policy" {
  description = "The internal access control policy of the security group. Valid values: Accept, Drop."
  type        = string
  default     = null

  validation {
    condition     = var.inner_access_policy == null || try(contains(["Accept", "Drop"], var.inner_access_policy), false)
    error_message = "inner_access_policy must be either 'Accept' or 'Drop'."
  }
}

variable "resource_group_id" {
  description = "The ID of the resource group to which the security group belongs."
  type        = string
  default     = null
}

variable "security_group_type" {
  description = "The type of the security group. Valid values: normal, enterprise."
  type        = string
  default     = "normal"

  validation {
    condition     = contains(["normal", "enterprise"], var.security_group_type)
    error_message = "security_group_type must be either 'normal' or 'enterprise'."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the security group."
  type        = map(string)
  default     = {}
}

variable "rules" {
  description = "List of security group rules to create."
  type = list(object({
    type                       = string
    ip_protocol                = string
    policy                     = optional(string, "accept")
    priority                   = optional(number, 1)
    cidr_ip                    = optional(string)
    ipv6_cidr_ip               = optional(string)
    source_security_group_id   = optional(string)
    source_group_owner_account = optional(string)
    prefix_list_id             = optional(string)
    port_range                 = optional(string, "-1/-1")
    nic_type                   = optional(string, "internet")
    description                = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.rules : contains(["ingress", "egress"], rule.type)
    ])
    error_message = "Each rule.type must be either 'ingress' or 'egress'."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : contains(["tcp", "udp", "icmp", "icmpv6", "gre", "all"], rule.ip_protocol)
    ])
    error_message = "Each rule.ip_protocol must be one of: tcp, udp, icmp, icmpv6, gre, all."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.policy == null || try(contains(["accept", "drop"], rule.policy), false)
    ])
    error_message = "Each rule.policy must be either 'accept' or 'drop'."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.priority == null || try(rule.priority >= 1 && rule.priority <= 100, false)
    ])
    error_message = "Each rule.priority must be between 1 and 100."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.cidr_ip == null || rule.ipv6_cidr_ip == null
    ])
    error_message = "Each rule cannot have both cidr_ip and ipv6_cidr_ip set at the same time."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.nic_type == null || try(contains(["internet", "intranet"], rule.nic_type), false)
    ])
    error_message = "Each rule.nic_type must be either 'internet' or 'intranet'."
  }

  validation {
    condition = alltrue([
      for rule in var.rules : rule.description == null || (try(length(rule.description), 0) >= 1 && try(length(rule.description), 0) <= 512)
    ])
    error_message = "Each rule.description must be 1 to 512 characters in length."
  }
}

