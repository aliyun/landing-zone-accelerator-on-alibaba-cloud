variable "cen_instance_id" {
  description = "The ID of the CEN instance."
  type        = string
}

variable "transit_router_name" {
  description = "The name of the Transit Router to create."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_name == null || try(length(var.transit_router_name), 0) == 0 || (
      try(length(var.transit_router_name), 0) >= 1 &&
      try(length(var.transit_router_name), 0) <= 128 &&
      try(startswith(var.transit_router_name, "http://"), false) == false &&
      try(startswith(var.transit_router_name, "https://"), false) == false
    )
    error_message = "transit_router_name can be null or empty, or if not empty must be 1-128 characters and must not start with 'http://' or 'https://'."
  }
}

variable "transit_router_description" {
  description = "The description of the Transit Router."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_description == null || try(length(var.transit_router_description), 0) == 0 || (
      try(length(var.transit_router_description), 0) >= 1 &&
      try(length(var.transit_router_description), 0) <= 256 &&
      try(startswith(var.transit_router_description, "http://"), false) == false &&
      try(startswith(var.transit_router_description, "https://"), false) == false
    )
    error_message = "transit_router_description can be null or empty, or if not empty must be 1-256 characters and must not start with 'http://' or 'https://'."
  }
}

variable "transit_router_tags" {
  description = "A map of tags to assign to the Transit Router."
  type        = map(string)
  default     = null
}

variable "transit_router_cidrs" {
  description = "List of CIDR blocks to allocate to the Transit Router. Maximum 5 CIDR blocks per Transit Router. Each CIDR must have a subnet mask between /16 and /24 (inclusive)."
  type = list(object({
    cidr                     = string
    description              = optional(string)
    publish_cidr_route       = optional(bool, true)
    transit_router_cidr_name = optional(string)
  }))
  default = []

  validation {
    condition     = length(var.transit_router_cidrs) <= 5
    error_message = "A Transit Router can have at most 5 CIDR blocks configured."
  }

  validation {
    condition = alltrue([
      for cidr_config in var.transit_router_cidrs :
      can(cidrhost(cidr_config.cidr, 0))
    ])
    error_message = "Each transit_router_cidr.cidr must be a valid IPv4 CIDR block."
  }

  validation {
    condition = alltrue([
      for cidr_config in var.transit_router_cidrs :
      can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/(1[6-9]|2[0-4])$", cidr_config.cidr))
    ])
    error_message = "Each transit_router_cidr.cidr must have a subnet mask between /16 and /24 (inclusive)."
  }

  validation {
    condition     = length(var.transit_router_cidrs) == length(toset([for cidr_config in var.transit_router_cidrs : cidr_config.cidr]))
    error_message = "Each CIDR block must be unique. Duplicate CIDR blocks are not allowed."
  }

  validation {
    condition = alltrue([
      for cidr_config in var.transit_router_cidrs :
      cidr_config.description == null || (
        try(length(cidr_config.description), 0) >= 1 &&
        try(length(cidr_config.description), 0) <= 256 &&
        !can(regex("^https?://", cidr_config.description))
      )
    ])
    error_message = "Each transit_router_cidr.description must be 1-256 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for cidr_config in var.transit_router_cidrs :
      cidr_config.transit_router_cidr_name == null || (
        try(length(cidr_config.transit_router_cidr_name), 0) >= 1 &&
        try(length(cidr_config.transit_router_cidr_name), 0) <= 128 &&
        !can(regex("^https?://", cidr_config.transit_router_cidr_name))
      )
    ])
    error_message = "Each transit_router_cidr.transit_router_cidr_name must be 1-128 characters and cannot start with http:// or https://."
  }
}

