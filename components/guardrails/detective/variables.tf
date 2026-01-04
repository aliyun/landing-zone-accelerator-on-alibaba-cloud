variable "use_existing_aggregator" {
  description = "Whether to use an existing config aggregator. If true, use existing_aggregator_id."
  type        = bool
  default     = false
}

variable "existing_aggregator_id" {
  description = "The ID of existing config aggregator to use when use_existing_aggregator is true."
  type        = string
  default     = null
}

variable "aggregator_name" {
  description = "The name of the config aggregator."
  type        = string
  default     = "enterprise"

  validation {
    condition     = length(var.aggregator_name) >= 1 && length(var.aggregator_name) <= 128
    error_message = "Aggregator name must be between 1 and 128 characters."
  }
}

variable "aggregator_description" {
  description = "The description of the config aggregator."
  type        = string
  default     = ""

  validation {
    condition     = var.aggregator_description == "" || (length(var.aggregator_description) >= 1 && length(var.aggregator_description) <= 256)
    error_message = "Aggregator description must be empty or between 1 and 256 characters."
  }
}

variable "aggregator_type" {
  description = "The type of the config aggregator. Valid values are 'RD' (Resource Directory), 'FOLDER' and 'CUSTOM'."
  type        = string
  default     = "RD"

  validation {
    condition     = var.aggregator_type == "RD" || var.aggregator_type == "CUSTOM" || var.aggregator_type == "FOLDER"
    error_message = "Aggregator type must be either 'RD', 'FOLDER' or 'CUSTOM'."
  }
}

variable "aggregator_folder_id" {
  description = "The folder ID of the config aggregator. Required when aggregator_type is 'FOLDER'."
  type        = string
  default     = null
}

variable "aggregator_accounts" {
  description = "List of accounts to be aggregated. Required when aggregator_type is 'CUSTOM'."
  type = list(object({
    account_id = string
    account_name = string
  }))
  default = []
}

variable "aggregator_accounts_dir" {
  description = "Directory path containing aggregator account configuration files (JSON/YAML). Files in this directory are loaded and merged with aggregator_accounts parameter, directory config takes precedence."
  type        = string
  default     = null
}

variable "enable_compliance_pack" {
  description = "Whether to enable compliance pack."
  type        = bool
  default     = true
}

variable "compliance_pack_name" {
  description = "The name of the compliance pack."
  type        = string
  default     = "LandingZoneCompliancePack"

  validation {
    condition     = length(var.compliance_pack_name) >= 1 && length(var.compliance_pack_name) <= 128
    error_message = "Compliance pack name must be between 1 and 128 characters."
  }
}

variable "risk_level" {
  description = "The risk level of the compliance pack. Valid values: 1, 2, 3, 4."
  type        = number
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4], var.risk_level)
    error_message = "Risk level must be one of 1, 2, 3, or 4."
  }
}

variable "template_based_rules" {
  description = "A list of config rules to be created based on templates."
  type = list(object({
    rule_name                       = string
    description                     = string
    source_template_id              = string
    input_parameters                = optional(map(string), {})
    maximum_execution_frequency     = optional(string, "TwentyFour_Hours")
    scope_compliance_resource_types = optional(list(string), [])
    risk_level                      = optional(number, 1)
    trigger_types                   = optional(string, "ConfigurationItemChangeNotification")
    tag_key_scope                   = optional(string)
    tag_value_scope                 = optional(string)
    region_ids_scope                = optional(string)
    exclude_resource_ids_scope      = optional(string)
    resource_group_ids_scope        = optional(list(string), [])
    add_to_compliance_pack          = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.template_based_rules :
      rule.risk_level >= 1 && rule.risk_level <= 4
    ])
    error_message = "Risk level for template based rules must be between 1 and 4."
  }

  validation {
    condition = alltrue([
      for rule in var.template_based_rules :
      length(rule.rule_name) >= 1 && length(rule.rule_name) <= 128
    ])
    error_message = "Rule name for template based rules must be between 1 and 128 characters."
  }

  validation {
    condition = alltrue([
      for rule in var.template_based_rules :
      contains([
        "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"
      ], rule.maximum_execution_frequency)
    ])
    error_message = "Maximum execution frequency must be one of: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours."
  }
}

variable "template_based_rules_dir" {
  description = "Directory path containing template-based rule configuration files (JSON/YAML). Files in this directory are loaded and merged with template_based_rules parameter, directory config takes precedence."
  type        = string
  default     = null
}

variable "custom_fc_rules" {
  description = "A list of custom config rules based on Function Compute."
  type = list(object({
    rule_name                       = string
    description                     = string
    source_arn                      = string
    input_parameters                = optional(map(string), {})
    maximum_execution_frequency     = optional(string, "TwentyFour_Hours")
    scope_compliance_resource_types = optional(list(string), [])
    risk_level                      = optional(number, 1)
    trigger_types                   = optional(string, "ConfigurationItemChangeNotification")
    tag_key_scope                   = optional(string)
    tag_value_scope                 = optional(string)
    region_ids_scope                = optional(string)
    exclude_resource_ids_scope      = optional(string)
    resource_group_ids_scope        = optional(list(string), [])
    add_to_compliance_pack          = optional(bool, true)
  }))
  default = []

  validation {
    condition = alltrue([
      for rule in var.custom_fc_rules :
      rule.risk_level >= 1 && rule.risk_level <= 4
    ])
    error_message = "Risk level for custom FC rules must be between 1 and 4."
  }

  validation {
    condition = alltrue([
      for rule in var.custom_fc_rules :
      length(rule.rule_name) >= 1 && length(rule.rule_name) <= 128
    ])
    error_message = "Rule name for custom FC rules must be between 1 and 128 characters."
  }

  validation {
    condition = alltrue([
      for rule in var.custom_fc_rules :
      can(regex("^acs:fc:[a-z0-9-]+:[0-9]{16}:services/[a-zA-Z0-9_-]+\\.(LATEST|\\d+)/functions/[a-zA-Z0-9_-]+$", rule.source_arn))
    ])
    error_message = "Source ARN for custom FC rules must be a valid Function Compute function ARN."
  }

  validation {
    condition = alltrue([
      for rule in var.custom_fc_rules :
      contains([
        "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", "TwentyFour_Hours"
      ], rule.maximum_execution_frequency)
    ])
    error_message = "Maximum execution frequency for custom FC rules must be one of: One_Hour, Three_Hours, Six_Hours, Twelve_Hours, TwentyFour_Hours."
  }
}