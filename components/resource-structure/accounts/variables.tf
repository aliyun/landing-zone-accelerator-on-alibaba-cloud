variable "resource_directory_id" {
  description = "The ID of the resource directory. This should come from the resource-directory component output."
  type        = string
}

variable "default_folder_id" {
  description = "The default folder ID where accounts will be created if folder_id is not specified in account_mapping. If not provided, accounts will be created in the root folder."
  type        = string
  default     = null
}

variable "account_mapping" {
  description = "Mapping of functional roles to accounts. Key can be a single role or comma-separated roles like 'log,security' for grouping multiple roles. Only specify accounts you want to create - no need for enabled flags."
  type = map(object({
    account_name_prefix = string
    display_name        = string
    billing_type        = optional(string, "Self-pay")
    billing_account_id  = optional(string)
    folder_id           = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {
    log = {
      account_name_prefix = "log"
      display_name        = "log"
      billing_type        = "Self-pay"
    }
    network = {
      account_name_prefix = "network"
      display_name        = "network"
      billing_type        = "Self-pay"
    }
    security = {
      account_name_prefix = "security"
      display_name        = "security"
      billing_type        = "Self-pay"
    }
    shared_services = {
      account_name_prefix = "shared"
      display_name        = "shared"
      billing_type        = "Self-pay"
    }
    operations = {
      account_name_prefix = "ops"
      display_name        = "ops"
      billing_type        = "Self-pay"
    }
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,48}[a-zA-Z0-9]$", account.account_name_prefix)) && !can(regex("[_.-]{2}", account.account_name_prefix))
    ])
    error_message = "Each account's account_name_prefix must be 2 to 50 characters in length, contain only letters, digits, underscores (_), periods (.), and hyphens (-), start and end with a letter or digit, and not contain consecutive special characters."
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      can(regex("^[\u4e00-\u9fa5a-zA-Z0-9_.-]{2,50}$", account.display_name))
    ])
    error_message = "Each account's display_name must be 2 to 50 characters in length, contain only Chinese characters, letters, digits, underscores (_), periods (.), and hyphens (-)."
  }

  validation {
    condition = alltrue([
      for key, account in var.account_mapping :
      can(regex("^(Trusteeship|Self-pay)$", account.billing_type))
    ])
    error_message = "Billing type must be either 'Trusteeship' or 'Self-pay'."
  }
}

variable "delegated_services" {
  description = "Map of services to delegate as administrators to specific account roles. Key is service identifier, value is a list of roles to delegate to. Each service can be delegated to multiple roles (accounts)."
  type        = map(list(string))
  default = {
    # Security services
    "cloudfw.aliyuncs.com"     = ["security"]
    "sas.aliyuncs.com"         = ["security"]
    "waf.aliyuncs.com"         = ["security"]
    "ddosbgp.aliyuncs.com"     = ["security"]
    "bastionhost.aliyuncs.com" = ["security"]
    "sddp.aliyuncs.com"        = ["security"]

    # Log and audit services
    "actiontrail.aliyuncs.com" = ["log"]
    "config.aliyuncs.com"      = ["log"]
    "audit.log.aliyuncs.com"   = ["log"]

    # Operations and monitoring services
    "cloudmonitor.aliyuncs.com"   = ["operations"]
    "prometheus.aliyuncs.com"     = ["operations"]
    "tag.aliyuncs.com"            = ["operations"]
    "ros.aliyuncs.com"            = ["operations"]
    "resourcecenter.aliyuncs.com" = ["operations"]
    "servicecatalog.aliyuncs.com" = ["operations"]
    "energy.aliyuncs.com"         = ["operations"]

    # Identity and access management services
    "cloudsso.aliyuncs.com" = ["shared_services"]
  }

  validation {
    condition = alltrue([
      for service in keys(var.delegated_services) :
      can(regex("\\.aliyuncs\\.com$", service))
    ])
    error_message = "All service identifiers must be valid trusted service identifiers ending with '.aliyuncs.com'."
  }

  validation {
    condition = alltrue([
      for service, roles in var.delegated_services :
      length(roles) > 0
    ])
    error_message = "Each service must have at least one role specified."
  }
}

