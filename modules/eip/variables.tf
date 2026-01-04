variable "eip_instances" {
  type = list(object({
    payment_type     = optional(string, "PayAsYouGo")
    period           = optional(number)
    eip_address_name = optional(string)
    tags             = optional(map(string), {})
  }))
  description = "List of EIP instance configurations. Each element contains payment_type, period, eip_address_name, and tags."

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.eip_address_name == null ||
        can(regex("^[a-zA-Z][a-zA-Z0-9._-]{0,127}$", instance.eip_address_name))
      )
    ])
    error_message = "eip_address_name must be empty or 1 to 128 characters in length, start with a letter, and contain only letters, digits, periods (.), underscores (_), and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.payment_type == null ||
        contains(["Subscription", "PayAsYouGo"], instance.payment_type)
      )
    ])
    error_message = "payment_type must be empty or one of 'Subscription' or 'PayAsYouGo'."
  }
}

variable "eip_associate_instance_id" {
  type        = string
  description = "The ID of the ECS or SLB instance or Nat Gateway or NetworkInterface or HaVip."
  default     = ""
}


variable "enable_common_bandwidth_package" {
  type        = bool
  description = "Whether to enable common bandwidth package. If the value is true, please fill in the following bandwidth package parameters."
  default     = false
}

variable "common_bandwidth_package_name" {
  type        = string
  description = "The name of the common bandwidth package."
  default     = null

  validation {
    condition = (
      var.common_bandwidth_package_name == null || (
        can(regex("^[a-zA-Z].*$", var.common_bandwidth_package_name)) &&
        !can(regex("^https?://", var.common_bandwidth_package_name)) &&
        length(var.common_bandwidth_package_name) >= 2 &&
        length(var.common_bandwidth_package_name) <= 256
      )
    )
    error_message = "common_bandwidth_package_name may be null, or must be 2 to 256 characters, start with a letter, and must not start with http:// or https://."
  }
}

variable "common_bandwidth_package_bandwidth" {
  type        = string
  description = "The bandwidth of the common bandwidth package. Unit: Mbps."
  default     = "5"

  validation {
    condition = (
      can(regex("^[0-9]+$", var.common_bandwidth_package_bandwidth)) &&
      tonumber(var.common_bandwidth_package_bandwidth) >= 1 &&
      tonumber(var.common_bandwidth_package_bandwidth) <= 1000
    )
    error_message = "common_bandwidth_package_bandwidth must be an integer between 1 and 1000."
  }
}

variable "common_bandwidth_package_internet_charge_type" {
  type        = string
  description = "The billing method of the common bandwidth package."
  default     = "PayByBandwidth"

  validation {
    condition     = contains(["PayByBandwidth", "PayBy95", "PayByDominantTraffic"], var.common_bandwidth_package_internet_charge_type)
    error_message = "common_bandwidth_package_internet_charge_type must be one of 'PayByBandwidth', 'PayBy95', or 'PayByDominantTraffic'."
  }
}

variable "common_bandwidth_package_ratio" {
  type        = number
  description = "The ratio for PayBy95 billing method. Currently only supports 20."
  default     = 20

  validation {
    condition     = var.common_bandwidth_package_ratio == 20
    error_message = "common_bandwidth_package_ratio must be 20."
  }
}






