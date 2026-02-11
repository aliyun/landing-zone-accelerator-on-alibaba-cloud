variable "cen_instance_id" {
  type        = string
  description = "The ID of the CEN instance to attach the bandwidth package to."
}

variable "use_existing_bandwidth_package" {
  type        = bool
  description = "Whether to use an existing bandwidth package instead of creating a new one."
  default     = false
}

variable "existing_bandwidth_package_id" {
  type        = string
  description = "The ID of an existing CEN bandwidth package to attach. Required when use_existing_bandwidth_package is true."
  default     = null
}

variable "bandwidth" {
  type        = number
  description = "The bandwidth in Mbps of the bandwidth package. Required when creating a new bandwidth package."
  default     = null

  validation {
    condition     = var.bandwidth == null || try(var.bandwidth >= 2 && var.bandwidth <= 10000, false)
    error_message = "bandwidth must be between 2 and 10000 Mbps."
  }
}

variable "cen_bandwidth_package_name" {
  type        = string
  description = "The name of the bandwidth package."
  default     = null

  validation {
    condition = var.cen_bandwidth_package_name == null || (
      try(length(var.cen_bandwidth_package_name), 0) >= 1 &&
      try(length(var.cen_bandwidth_package_name), 0) <= 128 &&
      !can(regex("^https?://", var.cen_bandwidth_package_name))
    )
    error_message = "cen_bandwidth_package_name must be 1-128 characters and cannot start with http:// or https://."
  }
}

variable "description" {
  type        = string
  description = "The description of the bandwidth package."
  default     = null

  validation {
    condition = var.description == null || (
      try(length(var.description), 0) >= 1 &&
      try(length(var.description), 0) <= 256 &&
      !can(regex("^https?://", var.description))
    )
    error_message = "description must be 1-256 characters and cannot start with http:// or https://."
  }
}

variable "geographic_region_a_id" {
  type        = string
  description = "The area A to which the network instance belongs. Required when creating a new bandwidth package."
  default     = null

  validation {
    condition = var.geographic_region_a_id == null || try(contains([
      "China", "North-America", "Asia-Pacific", "Europe", "Australia"
    ], var.geographic_region_a_id), false)
    error_message = "geographic_region_a_id must be one of: China, North-America, Asia-Pacific, Europe, Australia."
  }
}

variable "geographic_region_b_id" {
  type        = string
  description = "The area B to which the network instance belongs. Required when creating a new bandwidth package."
  default     = null

  validation {
    condition = var.geographic_region_b_id == null || try(contains([
      "China", "North-America", "Asia-Pacific", "Europe", "Australia"
    ], var.geographic_region_b_id), false)
    error_message = "geographic_region_b_id must be one of: China, North-America, Asia-Pacific, Europe, Australia."
  }
}

variable "payment_type" {
  type        = string
  description = "The billing method of the bandwidth package. Valid values: PrePaid (Subscription), PostPaid (Pay-As-You-Go). Default to PrePaid."
  default     = "PrePaid"

  validation {
    condition     = contains(["PrePaid", "PostPaid"], var.payment_type)
    error_message = "payment_type must be one of: PrePaid, PostPaid."
  }
}

variable "pricing_cycle" {
  type        = string
  description = "The billing cycle of the bandwidth package. Valid values: Month (default), Year. Only valid when payment_type is PrePaid."
  default     = "Month"

  validation {
    condition     = var.pricing_cycle == null || try(contains(["Month", "Year"], var.pricing_cycle), false)
    error_message = "pricing_cycle must be null or one of: Month, Year."
  }
}

variable "period" {
  type        = number
  description = "The subscription period of the bandwidth package. When pricing_cycle is Month, valid values are 1, 2, 3, 6. When pricing_cycle is Year, valid values are 1, 2, 3. Required when payment_type is PrePaid."
  default     = 1

  validation {
    condition     = var.period == null || try(var.period >= 1 && var.period <= 6, false)
    error_message = "period must be between 1 and 6."
  }
}
