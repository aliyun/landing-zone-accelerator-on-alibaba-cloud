variable "contacts" {
  description = "List of contacts to create, each contact includes name, email, mobile, and position."
  type = list(object({
    name     = string
    email    = string
    mobile   = optional(string, "0000")
    position = string
  }))
  default = []
  validation {
    condition = alltrue([
      for c in var.contacts : (
        can(regex("^[\u4E00-\u9FA5a-zA-Z]{2,12}$", c.name)) &&
        can(regex("^[\u4e00-\u9fa5a-zA-Z0-9+_.-]+@[a-zA-Z0-9_-]+(\\.[\u4e00-\u9fa5a-zA-Z0-9_-]+)+$", c.email)) &&
        can(regex("^[0-9]{4,}$", c.mobile)) &&
        contains([
          "CEO",
          "Finance Director",
          "Maintenance Director",
          "Other",
          "Project Director",
          "Technical Director"
        ], c.position)
      )
    ])
    error_message = "Each contact must meet: name (2-12 Chinese or English characters), email (valid format), mobile (digits only), position (one of: CEO, Finance Director, Maintenance Director, Other, Project Director, Technical Director)."
  }
}

variable "notification_recipient_mode" {
  description = "The mode for setting notification recipients when creating new contacts. Supported values: 'overwrite', 'append'. Default is 'append'."
  type        = string
  default     = "append"
  validation {
    condition     = contains(["overwrite", "append"], var.notification_recipient_mode)
    error_message = "notification_recipient_mode must be either 'overwrite' or 'append'."
  }
}
