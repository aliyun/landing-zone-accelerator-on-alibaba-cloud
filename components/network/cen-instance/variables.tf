variable "cen_instance_name" {
  description = "The name of the CEN instance."
  type        = string
  default     = null

  validation {
    condition = var.cen_instance_name == null || try(length(var.cen_instance_name), 0) == 0 || (
      try(length(var.cen_instance_name), 0) >= 1 &&
      try(length(var.cen_instance_name), 0) <= 128 &&
      try(startswith(var.cen_instance_name, "http://"), false) == false &&
      try(startswith(var.cen_instance_name, "https://"), false) == false
    )
    error_message = "cen_instance_name can be null or empty, or if not empty must be 1-128 characters and must not start with 'http://' or 'https://'."
  }
}

variable "description" {
  description = "The description of the CEN instance."
  type        = string
  default     = null

  validation {
    condition = var.description == null || try(length(var.description), 0) == 0 || (
      try(length(var.description), 0) >= 1 &&
      try(length(var.description), 0) <= 256 &&
      try(startswith(var.description, "http://"), false) == false &&
      try(startswith(var.description, "https://"), false) == false
    )
    error_message = "description can be null or empty, or if not empty must be 1-256 characters and must not start with 'http://' or 'https://'."
  }
}

variable "tags" {
  description = "The tags of the CEN instance."
  type        = map(string)
  default     = null
}

variable "protection_level" {
  description = "The level of CIDR block overlapping. Valid values: REDUCED: Overlapped CIDR blocks are allowed. However, the overlapped CIDR blocks cannot be the same."
  type        = string
  default     = null

  validation {
    condition     = var.protection_level == null || var.protection_level == "REDUCED"
    error_message = "protection_level must be null or 'REDUCED'."
  }
}

variable "resource_group_id" {
  description = "The ID of the resource group."
  type        = string
  default     = null
}

variable "bandwidth_packages" {
  description = "List of CEN bandwidth package configurations to create and attach to this CEN instance."
  type = list(object({
    bandwidth                  = number
    cen_bandwidth_package_name = optional(string)
    description                = optional(string)
    geographic_region_a_id     = string
    geographic_region_b_id     = string
    payment_type               = optional(string, "PrePaid")
    pricing_cycle              = optional(string, "Month")
    period                     = optional(number, 1)
  }))
  default = []
}

