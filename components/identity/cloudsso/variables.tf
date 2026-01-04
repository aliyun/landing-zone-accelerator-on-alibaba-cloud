variable "directory_name" {
  description = "The name of the CloudSSO directory. If null, it will be generated based on the account ID. Format: only lowercase letters, numbers, or hyphens (-). Cannot start or end with a hyphen, cannot contain two consecutive hyphens, and cannot start with 'd-'. Length: 2~64 characters."
  type        = string
  default     = null
  validation {
    condition = (
      var.directory_name == null ||
      (
        length(var.directory_name) >= 2 &&
        length(var.directory_name) <= 64 &&
        can(regex("^[a-z0-9]([a-z0-9\\-]*[a-z0-9])?$", var.directory_name)) &&
        !can(regex("--", var.directory_name)) &&
        !can(regex("^d-", var.directory_name))
      )
    )
    error_message = "directory_name must be 2~64 characters, only contain lowercase letters, numbers, or hyphens (-), cannot start or end with a hyphen, cannot contain two consecutive hyphens, and cannot start with 'd-'."
  }
}

# Random suffix controls for CloudSSO directory_name
variable "append_random_suffix" {
  description = "Whether to append a random suffix to the directory_name to ensure global uniqueness"
  type        = bool
  default     = false
}

variable "random_suffix_length" {
  description = "Length of the random suffix for the directory_name"
  type        = number
  default     = 6

  validation {
    condition     = var.random_suffix_length >= 3 && var.random_suffix_length <= 16
    error_message = "Random suffix length must be between 3 and 16."
  }
}

variable "random_suffix_separator" {
  description = "Separator between the directory_name and random suffix"
  type        = string
  default     = "-"

  validation {
    condition     = var.random_suffix_separator == "-" || var.random_suffix_separator == "_" || var.random_suffix_separator == ""
    error_message = "Random suffix separator must be '-', '_' or empty."
  }
}

variable "login_preference" {
  description = "Login preferences for the CloudSSO directory"
  type = object({
    allow_user_to_get_credentials = optional(bool, false)
    login_network_masks           = optional(string)
  })
  default = null
}

variable "mfa_authentication_setting_info" {
  description = "Global MFA verification configuration"
  type = object({
    mfa_authentication_advance_settings = optional(string, "Enabled")
    operation_for_risk_login            = optional(string)
  })
  default = null

  validation {
    condition = var.mfa_authentication_setting_info == null || (
      try(var.mfa_authentication_setting_info.mfa_authentication_advance_settings, null) == null ||
      try(var.mfa_authentication_setting_info.mfa_authentication_advance_settings, null) == "Enabled" ||
      try(var.mfa_authentication_setting_info.mfa_authentication_advance_settings, null) == "ByUser" ||
      try(var.mfa_authentication_setting_info.mfa_authentication_advance_settings, null) == "Disabled" ||
      try(var.mfa_authentication_setting_info.mfa_authentication_advance_settings, null) == "OnlyRiskyLogin"
    )
    error_message = "mfa_authentication_advance_settings must be one of: Enabled, ByUser, Disabled, OnlyRiskyLogin."
  }

  validation {
    condition = var.mfa_authentication_setting_info == null || (
      try(var.mfa_authentication_setting_info.operation_for_risk_login, null) == null ||
      try(var.mfa_authentication_setting_info.operation_for_risk_login, null) == "Autonomous" ||
      try(var.mfa_authentication_setting_info.operation_for_risk_login, null) == "EnforceVerify"
    )
    error_message = "operation_for_risk_login must be one of: Autonomous, EnforceVerify."
  }
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    max_login_attempts            = optional(number, 5)
    max_password_age              = optional(number, 90)
    min_password_different_chars  = optional(number, 4)
    min_password_length           = optional(number, 8)
    password_not_contain_username = optional(bool, true)
    password_reuse_prevention     = optional(number, 1)
  })
  default = null

  validation {
    condition = var.password_policy == null || (
      try(var.password_policy.max_login_attempts, 5) >= 0 && try(var.password_policy.max_login_attempts, 5) <= 32
    )
    error_message = "max_login_attempts must be between 0 and 32. 0 means no limit."
  }

  validation {
    condition = var.password_policy == null || (
      try(var.password_policy.max_password_age, 120) >= 1 && try(var.password_policy.max_password_age, 120) <= 120
    )
    error_message = "max_password_age must be between 1 and 120 days."
  }

  validation {
    condition = var.password_policy == null || (
      try(var.password_policy.min_password_different_chars, 4) >= 0 &&
      try(var.password_policy.min_password_different_chars, 4) <= try(var.password_policy.min_password_length, 8)
    )
    error_message = "min_password_different_chars must be between 0 and min_password_length. 0 means no limit."
  }

  validation {
    condition = var.password_policy == null || (
      try(var.password_policy.min_password_length, 8) >= 8 && try(var.password_policy.min_password_length, 8) <= 32
    )
    error_message = "min_password_length must be between 8 and 32."
  }

  validation {
    condition = var.password_policy == null || (
      try(var.password_policy.password_reuse_prevention, 0) >= 0 && try(var.password_policy.password_reuse_prevention, 0) <= 24
    )
    error_message = "password_reuse_prevention must be between 0 and 24. 0 means disabled."
  }
}



variable "access_configurations" {
  description = "List of access configurations to create."
  type = list(object({
    name                    = string
    description             = optional(string)
    relay_state             = optional(string, "https://home.console.aliyun.com/")
    session_duration        = optional(number, 3600)
    managed_system_policies = optional(list(string), [])
    inline_custom_policy = optional(object({
      policy_name     = optional(string, "InlinePolicy")
      policy_document = optional(string)
    }), null)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      length(config.name) > 0 && length(config.name) <= 32 && can(regex("^[a-zA-Z0-9-]+$", config.name))
    ])
    error_message = "Each access configuration name must be between 1 and 32 characters and can only contain letters, digits, and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      config.description == null || (try(length(config.description), 0) > 0 && try(length(config.description), 0) <= 1024)
    ])
    error_message = "Each access configuration description, if provided, must be between 1 and 1024 characters."
  }

  validation {
    condition = alltrue([
      for config in var.access_configurations :
      config.session_duration == null || (try(config.session_duration, 0) >= 900 && try(config.session_duration, 0) <= 43200)
    ])
    error_message = "Each access configuration session_duration, if provided, must be between 900 and 43200 seconds."
  }

  # Validate inline_custom_policy has policy_document when provided
  validation {
    condition = alltrue([
      for config in var.access_configurations :
      config.inline_custom_policy == null || (
        try(config.inline_custom_policy.policy_document, null) != null
      )
    ])
    error_message = "When inline_custom_policy is provided, policy_document must be set."
  }
}

variable "access_configurations_dir" {
  description = "Directory path containing access configuration files (JSON/YAML). Files in this directory will be loaded and combined with access_configurations, with file configurations taking priority over inline configurations for matching names."
  type        = string
  default     = null
}

variable "users" {
  description = "A list of cloud sso users to create."
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
}

variable "groups" {
  description = "A list of cloud sso groups to create."
  type = list(object({
    group_name  = string
    description = optional(string)
    user_names  = optional(list(string), [])
  }))
  default = []
}

variable "access_assignments" {
  description = "List of access assignments for users and groups. Account names will be resolved to IDs via Resource Directory datasource."
  type = list(object({
    principal_name             = string
    principal_type             = optional(string, "User") # "User" or "Group"
    account_names              = optional(list(string), [])
    include_master_account     = optional(bool, false)
    access_configuration_names = list(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.access_assignments :
      contains(["User", "Group"], assignment.principal_type)
    ])
    error_message = "Each principal_type must be either 'User' or 'Group'."
  }

  validation {
    condition = alltrue([
      for assignment in var.access_assignments :
      length(assignment.access_configuration_names) > 0
    ])
    error_message = "Each access_assignments element must contain at least one access_configuration_name."
  }
}
