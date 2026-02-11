variable "allow_user_to_change_password" {
  description = "Allow users to change their password"
  type        = bool
  default     = true
}

variable "allow_user_to_login_with_passkey" {
  description = "Whether to allow RAM users to log on using a passkey."
  type        = bool
  default     = true
}

variable "allow_user_to_manage_access_keys" {
  description = "Whether to allow RAM users to manage their own access keys."
  type        = bool
  default     = false
}

variable "allow_user_to_manage_mfa_devices" {
  description = "Whether to allow RAM users to manage multi-factor authentication devices."
  type        = bool
  default     = true
}

variable "allow_user_to_manage_personal_ding_talk" {
  description = "Whether to allow RAM users to independently manage the binding and unbinding of personal DingTalk."
  type        = bool
  default     = true
}

variable "enable_save_mfa_ticket" {
  description = "Whether to save the verification status of a RAM user after logging in using multi-factor authentication. The validity period is 7 days. "
  type        = bool
  default     = true
}

variable "login_session_duration" {
  description = "Duration of login session in hours."
  type        = number
  default     = 6

  validation {
    condition     = var.login_session_duration >= 1 && var.login_session_duration <= 24
    error_message = "login_session_duration must be between 1 and 24 inclusive."
  }
}

variable "login_network_masks" {
  description = "List of IP address ranges to allow login. If you do not specify any mask, the login console function will apply to the entire network."
  type        = list(string)
  default     = []

  validation {
    condition     = var.login_network_masks == null || try(length(var.login_network_masks), 0) <= 40
    error_message = "The number of login_network_masks must not exceed 40."
  }
}

variable "mfa_operation_for_login" {
  description = "MFA must be used during logon (replace the original EnforceMFAForLogin parameter, the original parameter is still valid, we recommend that you update it to a new parameter). Value: mandatory: mandatory for all RAM users. The original value of EnforceMFAForLogin is true. independent (default): depends on the independent configuration of each RAM user. The original value of EnforceMFAForLogin is false. adaptive: Used only during abnormal login."
  type        = string
  default     = "independent"
  validation {
    condition     = contains(["mandatory", "independent", "adaptive"], var.mfa_operation_for_login)
    error_message = "mfa_operation_for_login must be one of: mandatory, independent, adaptive"
  }
}

variable "operation_for_risk_login" {
  description = "Whether MFA is verified twice during abnormal logon. Value: autonomous (default): Skip, do not force binding. enforceVerify: Force binding validation."
  type        = string
  default     = "autonomous"
  validation {
    condition     = contains(["autonomous", "enforceVerify"], var.operation_for_risk_login)
    error_message = "operation_for_risk_login must be one of: autonomous, enforceVerify"
  }
}

variable "verification_types" {
  description = "Means of multi-factor authentication. Value: sms: secure phone. email: Secure mailbox."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for type in var.verification_types : contains(["sms", "email"], type)]) || length(var.verification_types) == 0 || var.verification_types == null
    error_message = "verification_types must be a set containing only: sms, email, or be an empty set, or null"
  }
}

variable "password_policy" {
  description = "Configuration for the RAM password policy"
  type = object({
    minimum_password_length              = optional(number)
    require_lowercase_characters         = optional(bool)
    require_numbers                      = optional(bool)
    require_uppercase_characters         = optional(bool)
    require_symbols                      = optional(bool)
    max_password_age                     = optional(number)
    password_reuse_prevention            = optional(number)
    max_login_attempts                   = optional(number)
    hard_expiry                          = optional(bool)
    password_not_contain_user_name       = optional(bool)
    minimum_password_different_character = optional(number)
  })

  default = {
    minimum_password_length              = 8
    require_lowercase_characters         = true
    require_numbers                      = true
    require_uppercase_characters         = true
    require_symbols                      = false
    max_password_age                     = 90
    password_reuse_prevention            = 3
    max_login_attempts                   = 5
    hard_expiry                          = false
    password_not_contain_user_name       = false
    minimum_password_different_character = 0
  }
}
