variable "account_name_prefix" {
  description = "The prefix for the display name of the member account."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,48}[a-zA-Z0-9]$", var.account_name_prefix)) && !can(regex("[_.-]{2}", var.account_name_prefix))
    error_message = "account_name_prefix must be 2 to 50 characters in length, contain only letters, digits, underscores (_), periods (.), and hyphens (-), start and end with a letter or digit, and not contain consecutive special characters."
  }
}

variable "display_name" {
  description = "The display name of the member account."
  type        = string
  validation {
    condition     = can(regex("^[\u4e00-\u9fa5a-zA-Z0-9_.-]{2,50}$", var.display_name))
    error_message = "display_name must be 2 to 50 characters in length, contain only Chinese characters, letters, digits, underscores (_), periods (.), and hyphens (-)."
  }
}

variable "parent_folder_id" {
  description = "The ID of the parent folder where the member account will be created. If null, it will default to the root folder of the resource directory."
  type        = string
  default     = null
}

variable "billing_type" {
  description = "The billing type for the member account. Can be 'Trusteeship' or 'Self-pay'."
  type        = string
  default     = "Trusteeship"
  validation {
    condition     = can(regex("^(Trusteeship|Self-pay)$", var.billing_type))
    error_message = "billing_type must be either 'Trusteeship' or 'Self-pay'."
  }
}

variable "billing_account_id" {
  description = "The ID of the billing account for the member account. If 'billing_type' is 'Trusteeship' and this value is null, it will default to the current Master account."
  type        = string
  default     = null
}

variable "tags" {
  description = "The tag of the account."
  type        = map(string)
  default     = null
}
