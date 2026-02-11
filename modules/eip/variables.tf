variable "eip_instances" {
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
    zone                      = optional(string)
    tags                      = optional(map(string), {})
  }))
  description = "List of EIP instance configurations."

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
      contains(["Subscription", "PayAsYouGo"], instance.payment_type)
    ])
    error_message = "payment_type must be one of 'Subscription' or 'PayAsYouGo'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.description == null ||
        (
          try(length(instance.description), 0) >= 2 &&
          try(length(instance.description), 0) <= 256 &&
          can(regex("^[a-zA-Z]", instance.description)) &&
          !can(regex("^(http://|https://)", instance.description))
        )
      )
    ])
    error_message = "description must be 2 to 256 characters in length, start with a letter, and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      contains(["PayByBandwidth", "PayByTraffic"], instance.internet_charge_type)
    ])
    error_message = "internet_charge_type must be one of 'PayByBandwidth' or 'PayByTraffic'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.payment_type != "Subscription" ||
        instance.internet_charge_type == "PayByBandwidth"
      )
    ])
    error_message = "When payment_type is set to Subscription, internet_charge_type must be set to PayByBandwidth."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      contains(["BGP", "BGP_PRO"], instance.isp)
    ])
    error_message = "isp must be one of 'BGP' or 'BGP_PRO'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      instance.mode == null || try(contains(["NAT", "MULTI_BINDED", "BINDED"], instance.mode), false)
    ])
    error_message = "mode must be null or one of 'NAT', 'MULTI_BINDED', or 'BINDED'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      instance.netmode == null || instance.netmode == "public"
    ])
    error_message = "netmode must be 'public'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      instance.pricing_cycle == null || try(contains(["Month", "Year"], instance.pricing_cycle), false)
    ])
    error_message = "pricing_cycle must be null or one of 'Month' or 'Year'."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.payment_type != "Subscription" ||
        instance.period != null
      )
    ])
    error_message = "When payment_type is set to Subscription, period is required."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.period == null ||
        (
          instance.payment_type == "Subscription" &&
          (
            (instance.pricing_cycle == "Month" && try(instance.period >= 1 && instance.period <= 9, false)) ||
            (instance.pricing_cycle == "Year" && try(instance.period >= 1 && instance.period <= 5, false))
          )
        )
      )
    ])
    error_message = "When pricing_cycle is Month, period must be 1 to 9. When pricing_cycle is Year, period must be 1 to 5. period is only valid when payment_type is Subscription."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.payment_type != "PayAsYouGo" ||
        (
          (instance.internet_charge_type == "PayByBandwidth" && try(instance.bandwidth >= 1 && instance.bandwidth <= 500, false)) ||
          (instance.internet_charge_type == "PayByTraffic" && try(instance.bandwidth >= 1 && instance.bandwidth <= 200, false))
        )
      )
    ])
    error_message = "When payment_type is PayAsYouGo and internet_charge_type is PayByBandwidth, bandwidth must be 1 to 500. When payment_type is PayAsYouGo and internet_charge_type is PayByTraffic, bandwidth must be 1 to 200."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      (
        instance.payment_type != "Subscription" ||
        try(instance.bandwidth >= 1 && instance.bandwidth <= 1000, false)
      )
    ])
    error_message = "When payment_type is Subscription, bandwidth must be 1 to 1000."
  }

  validation {
    condition = alltrue([
      for instance in var.eip_instances :
      instance.security_protection_type == null ||
      instance.security_protection_type == "" ||
      instance.security_protection_type == "antidos_enhanced"
    ])
    error_message = "security_protection_type must be null, empty string, or 'antidos_enhanced'."
  }
}

variable "eip_associate_instance_id" {
  type        = string
  description = "The ID of the ECS or SLB instance or Nat Gateway or NetworkInterface or HaVip."
  default     = ""
}






