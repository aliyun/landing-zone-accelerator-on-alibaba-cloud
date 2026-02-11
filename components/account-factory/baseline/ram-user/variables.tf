variable "user_name" {
  description = "Desired name for the ram user."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,64}$", var.user_name))
    error_message = "user_name must be 1-64 characters long and can only contain letters, numbers, periods (.), hyphens (-), and underscores (_)."
  }
}

variable "display_name" {
  description = "Name of the RAM user which for display"
  type        = string
  default     = null

  validation {
    condition = var.display_name == null || (
      try(length(var.display_name), 0) >= 1 &&
      try(length(var.display_name), 0) <= 128
    )
    error_message = "display_name must be 1-128 characters long."
  }
}

variable "mobile" {
  description = "Phone number of the RAM user. This number must contain an international area code prefix, just look like this: 86-18600008888."
  type        = string
  default     = null
}

variable "email" {
  description = "Email of the RAM user."
  type        = string
  default     = null
}

variable "comments" {
  description = "Comment of the RAM user. This parameter can have a string of 1 to 128 characters."
  type        = string
  default     = null

  validation {
    condition = var.comments == null || (
      try(length(var.comments), 0) >= 1 &&
      try(length(var.comments), 0) <= 128
    )
    error_message = "comments must be 1-128 characters long."
  }
}

variable "force_destroy_user" {
  description = "When destroying this user, destroy even if it has non-Terraform-managed ram access keys, login profile or MFA devices. Without force_destroy a user with non-Terraform-managed access keys and login profile will fail to be destroyed."
  type        = bool
  default     = false
}

variable "create_ram_user_login_profile" {
  description = "Whether to create ram user login profile"
  type        = bool
  default     = false
}

variable "password" {
  description = "Login password of the user"
  type        = string
  default     = null
  sensitive   = true
}

variable "password_reset_required" {
  description = "This parameter indicates whether the password needs to be reset when the user logs in."
  type        = bool
  default     = false
}

variable "mfa_bind_required" {
  description = "This parameter indicates whether the MFA needs to be bind when the user logs in."
  type        = bool
  default     = false
}

variable "create_ram_access_key" {
  description = "Whether to create ram access key. Default value is 'false'."
  type        = bool
  default     = false
}

variable "pgp_key" {
  description = "Either a base-64 encoded PGP public key, or a keybase username in the form"
  type        = string
  default     = null
}

variable "secret_file" {
  description = "A file used to store access key and secret key of ther user."
  type        = string
  default     = null
}

variable "status" {
  description = "Status of access key"
  type        = string
  default     = "Active"
}

variable "managed_custom_policy_names" {
  description = "List of names of managed policies of Custom type to attach to RAM user"
  type        = list(string)
  default     = []
}

variable "managed_system_policy_names" {
  description = "List of names of managed policies of System type to attach to RAM user"
  type        = list(string)
  default     = []
}

variable "inline_custom_policies" {
  description = "List of custom policies to be created and attached to the RAM user within this module. This is different from managed_custom_policy_names, which refers to existing custom policy names."
  type = list(object({
    policy_name     = string
    policy_document = string
    description     = optional(string)
    force           = optional(bool, true)
  }))
  default = []
}
