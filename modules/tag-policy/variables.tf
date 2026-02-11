variable "tag_policies" {
  description = "List of tag policies to create"
  type = list(object({
    policy_name    = string
    policy_desc    = optional(string)
    policy_content = string
    user_type      = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.tag_policies : (
        length(policy.policy_name) >= 1 &&
        length(policy.policy_name) <= 128 &&
        !can(regex("^https?://", policy.policy_name))
      )
    ])
    error_message = "Each policy_name must be between 1 and 128 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for policy in var.tag_policies : (
        !contains(keys(policy), "policy_desc") || policy.policy_desc == null || (
          length(policy.policy_desc) >= 1 &&
          length(policy.policy_desc) <= 512 &&
          !can(regex("^https?://", policy.policy_desc))
        )
      )
    ])
    error_message = "Each policy_desc must be between 1 and 512 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for policy in var.tag_policies : (
        !contains(keys(policy), "user_type") || policy.user_type == null ||
        contains(["USER", "ACCOUNT", "RD"], policy.user_type)
      )
    ])
    error_message = "user_type must be one of: USER, ACCOUNT, RD."
  }
}

variable "policy_attachments" {
  description = "List of policy attachments to create"
  type = list(object({
    policy_name = string
    target_id   = string
    target_type = string
  }))
  default = []

  validation {
    condition = alltrue([
      for attachment in var.policy_attachments : (
        contains(["USER", "ROOT","ACCOUNT", "FOLDER"], attachment.target_type)
      )
    ])
    error_message = "target_type must be one of: USER, ROOT, ACCOUNT, FOLDER."
  }
}
