variable "enable_enterprise" {
  description = "Whether to enable CloudMonitor Enterprise edition. If false, Basic edition will be used."
  type        = bool
  default     = false
}

variable "alarm_contacts" {
  description = "List of alarm contacts to create"
  type = list(object({
    name                   = string
    description            = string
    channels_aliim         = optional(string)
    channels_ding_web_hook = optional(string)
    channels_mail          = optional(string)
    channels_sms           = optional(string)
    lang                   = optional(string, "zh-cn")
  }))
  default = []

  validation {
    condition = alltrue([
      for contact in var.alarm_contacts : (
        length(contact.name) >= 2 && length(contact.name) <= 40 &&
        can(regex("^[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5._-]*$", contact.name)) &&
        length(contact.description) > 0 &&
        (contact.channels_mail == null || can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", contact.channels_mail))) &&
        (contact.channels_sms == null || can(regex("^(1[3-9]\\d{9}|86-1[3-9]\\d{9})$", contact.channels_sms))) &&
        (contact.lang == null || contains(["en", "zh-cn"], contact.lang))
      )
    ])
    error_message = "Invalid alarm contact configuration. Please check: 1) name must start with Chinese or English characters, be 2-40 characters long, and contain only Chinese characters, English letters, numbers, dots, underscores, and hyphens; 2) description cannot be empty; 3) email format must be valid; 4) SMS must be a valid Chinese phone number (11 digits or 86- followed by 11 digits); 5) lang must be 'en' or 'zh-cn'."
  }

  validation {
    condition     = length(distinct([for contact in var.alarm_contacts : contact.name])) == length(var.alarm_contacts)
    error_message = "Alarm contact names must be unique."
  }
}

variable "alarm_contact_groups" {
  description = "List of alarm contact groups to create"
  type = list(object({
    name              = string
    contacts          = optional(list(string), []) # Contact names (optional)
    description       = optional(string)
    enable_subscribed = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for group in var.alarm_contact_groups : (
        length(group.name) >= 2 && length(group.name) <= 40 &&
        can(regex("^[a-zA-Z\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5._-]*$", group.name)) &&
        alltrue([for contact in group.contacts : length(contact) > 0])
      )
    ])
    error_message = "Invalid alarm contact group configuration. Please check: 1) name must start with Chinese or English characters, be 2-40 characters long, and contain only Chinese characters, English letters, numbers, dots, underscores, and hyphens; 2) contact names cannot be empty when provided."
  }

  validation {
    condition     = length(distinct([for group in var.alarm_contact_groups : group.name])) == length(var.alarm_contact_groups)
    error_message = "Alarm contact group names must be unique."
  }
}


