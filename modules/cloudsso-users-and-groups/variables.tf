variable "directory_id" {
  description = "CloudSSO directory ID."
  type        = string

  validation {
    condition     = can(regex("^d-[A-Za-z0-9]+$", var.directory_id))
    error_message = "directory_id must match CloudSSO directory ID format."
  }
}

variable "users" {
  description = "A list of cloud sso users."
  type = list(object({
    user_name                   = string
    display_name                = optional(string)
    description                 = optional(string)
    email                       = optional(string)
    first_name                  = optional(string)
    last_name                   = optional(string)
    password                    = optional(string)
    mfa_authentication_settings = optional(string, "Enabled")
    status                      = optional(string, "Enabled")
    tags                        = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for user in var.users :
      length(user.user_name) > 0 && length(user.user_name) <= 64 && can(regex("^[0-9A-Za-z@_.-]+$", user.user_name))
    ])
    error_message = "Each user_name cannot be empty, must be between 1-64 characters, and can only contain numbers, letters, and @_-. characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.display_name == null || try(length(user.display_name), 0) <= 256
    ])
    error_message = "Each display_name length must be less than or equal to 256 characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.description == null || try(length(user.description), 0) <= 1024
    ])
    error_message = "Each description length must be less than or equal to 1024 characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.email == null || (
        try(length(user.email), 0) <= 128 &&
        can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", user.email))
      )
    ])
    error_message = "Each email must be a valid email format and cannot exceed 128 characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.first_name == null || try(length(user.first_name), 0) <= 64
    ])
    error_message = "Each first_name length must be less than or equal to 64 characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.last_name == null || try(length(user.last_name), 0) <= 64
    ])
    error_message = "Each last_name length must be less than or equal to 64 characters."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      user.password == null || (
        try(length(user.password), 0) >= 8 &&
        try(length(user.password), 0) <= 32 &&
        can(regex("[A-Z]", user.password)) &&
        can(regex("[a-z]", user.password)) &&
        can(regex("[0-9]", user.password)) &&
        can(regex("[^0-9A-Za-z]", user.password))
      )
    ])
    error_message = "Each password must be 8-32 characters and include at least one uppercase letter, lowercase letter, number, and special character."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      contains(["Enabled", "Disabled"], try(user.mfa_authentication_settings, "Enabled"))
    ])
    error_message = "Each mfa_authentication_settings only supports Enabled or Disabled."
  }

  validation {
    condition = alltrue([
      for user in var.users :
      contains(["Enabled", "Disabled"], try(user.status, "Enabled"))
    ])
    error_message = "Each status only supports Enabled or Disabled."
  }
}

variable "groups" {
  description = "A list of cloud sso groups"
  type = list(object({
    group_name  = string
    description = optional(string)
    user_names  = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for group in var.groups :
      length(group.group_name) > 0 && length(group.group_name) <= 128 && can(regex("^[0-9A-Za-z_.-]+$", group.group_name))
    ])
    error_message = "Each group_name cannot be empty, must be between 1-128 characters, and can only contain letters, digits, and _-. characters."
  }

  validation {
    condition = alltrue([
      for group in var.groups :
      group.description == null || try(length(group.description), 0) <= 1024
    ])
    error_message = "Each description length must be less than or equal to 1024 characters."
  }
}
