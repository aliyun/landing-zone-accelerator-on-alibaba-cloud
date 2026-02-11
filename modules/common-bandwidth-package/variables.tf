variable "bandwidth" {
  type        = string
  description = "The bandwidth of the common bandwidth package. Unit: Mbps."
  default     = "5"

  validation {
    condition = (
      can(regex("^[0-9]+$", var.bandwidth)) &&
      tonumber(var.bandwidth) >= 1 &&
      tonumber(var.bandwidth) <= 1000
    )
    error_message = "bandwidth must be an integer between 1 and 1000."
  }
}

variable "internet_charge_type" {
  type        = string
  description = "The billing method of the common bandwidth package."
  default     = "PayByBandwidth"

  validation {
    condition     = contains(["PayByBandwidth", "PayBy95", "PayByDominantTraffic"], var.internet_charge_type)
    error_message = "internet_charge_type must be one of 'PayByBandwidth', 'PayBy95', or 'PayByDominantTraffic'."
  }
}

variable "bandwidth_package_name" {
  type        = string
  description = "The name of the common bandwidth package."
  default     = null

  validation {
    condition = (
      var.bandwidth_package_name == null || (
        can(regex("^[a-zA-Z].{1,255}$", var.bandwidth_package_name)) &&
        !can(regex("^https?://", var.bandwidth_package_name))
      )
    )
    error_message = "bandwidth_package_name may be null, or must be 2 to 256 characters, start with a letter, and must not start with http:// or https://."
  }
}

variable "ratio" {
  type        = number
  description = "The ratio for PayBy95 billing method. Currently only supports 20."
  default     = 20

  validation {
    condition     = var.ratio == 20
    error_message = "ratio must be 20."
  }
}

variable "deletion_protection" {
  type        = bool
  description = "Specifies whether to enable deletion protection for the common bandwidth package."
  default     = false
}

variable "description" {
  type        = string
  description = "The description of the Internet Shared Bandwidth instance."
  default     = null

  validation {
    condition = (
      var.description == null || (
        try(length(var.description), 0) >= 0 &&
        try(length(var.description), 0) <= 256 &&
        !can(regex("^(http://|https://)", var.description))
      )
    )
    error_message = "The description must be 0 to 256 characters in length and cannot start with http:// or https://."
  }
}

variable "force" {
  type        = bool
  description = "Specifies whether to forcefully delete the Internet Shared Bandwidth instance."
  default     = false
}

variable "isp" {
  type        = string
  description = "The line type of the common bandwidth package."
  default     = "BGP"

  validation {
    condition     = contains(["BGP", "BGP_PRO"], var.isp)
    error_message = "isp must be one of 'BGP' or 'BGP_PRO'."
  }
}

variable "resource_group_id" {
  type        = string
  description = "The ID of the resource group to which you want to move the resource."
  default     = null
}

variable "security_protection_types" {
  type        = list(string)
  description = "The edition of Anti-DDoS. Empty list for Anti-DDoS Origin Basic, 'AntiDDoS_Enhanced' for Anti-DDoS Pro(Premium). Valid when internet_charge_type is PayBy95. Maximum 10 security protection types."
  default     = []

  validation {
    condition = (
      length(var.security_protection_types) <= 10
    )
    error_message = "security_protection_types can have at most 10 elements."
  }

  validation {
    condition = alltrue([
      for protection_type in var.security_protection_types :
      protection_type == "" || protection_type == "AntiDDoS_Enhanced"
    ])
    error_message = "security_protection_types elements must be empty string or 'AntiDDoS_Enhanced'."
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags of the common bandwidth package resource."
  default     = {}
}

variable "zone" {
  type        = string
  description = "The zone of the Internet Shared Bandwidth instance. Required if creating for a cloud box."
  default     = null
}

variable "eip_attachments" {
  type = list(object({
    instance_id                 = string
    bandwidth_package_bandwidth = optional(string)
  }))
  description = "List of EIP attachments to the common bandwidth package. Each object contains instance_id and optional bandwidth_package_bandwidth (Mbit/s). bandwidth_package_bandwidth can be positive integer string or 'Cancelled' (from version 1.261.0)."
  default     = []

  validation {
    condition = alltrue([
      for attachment in var.eip_attachments :
      attachment.bandwidth_package_bandwidth == null || attachment.bandwidth_package_bandwidth == "Cancelled" || (
        can(regex("^[0-9]+$", attachment.bandwidth_package_bandwidth)) &&
        try(tonumber(attachment.bandwidth_package_bandwidth) >= 1, false)
      )
    ])
    error_message = "eip_attachments bandwidth_package_bandwidth values must be null, 'Cancelled', or a positive integer string representing bandwidth in Mbit/s."
  }
}

