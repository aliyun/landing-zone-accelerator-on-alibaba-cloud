variable "project_name" {
  description = "Name of the destination SLS project (create or reuse)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

variable "create_project" {
  description = "Whether to create the SLS project; false to reuse existing"
  type        = bool
  default     = false
}


variable "project_description" {
  description = "Description used when creating the SLS project"
  type        = string
  default     = null
}

variable "project_tags" {
  description = "Tags to apply when creating the SLS project"
  type        = map(string)
  default     = null
}

# Random suffix controls for SLS project name
variable "append_random_suffix" {
  description = "Whether to append a random suffix to the SLS project_name to ensure global uniqueness (only when create_project = true)"
  type        = bool
  default     = false
}

variable "random_suffix_length" {
  description = "Length of the random suffix for the SLS project_name (project only)"
  type        = number
  default     = 6

  validation {
    condition     = var.random_suffix_length >= 3 && var.random_suffix_length <= 16
    error_message = "Random suffix length must be between 3 and 16."
  }
}

variable "random_suffix_separator" {
  description = "Separator between the SLS project_name and random suffix (project only)"
  type        = string
  default     = "-"

  validation {
    condition     = var.random_suffix_separator == "-" || var.random_suffix_separator == "_" || var.random_suffix_separator == ""
    error_message = "Random suffix separator must be '-', '_' or empty."
  }
}

variable "collection_policies" {
  description = "Collection policies to create/attach for the project"
  # For product_code and data_code values, refer to:
  # Chinese docs: https://help.aliyun.com/zh/sls/cloud-product-configuration-considerations
  # English docs: https://www.alibabacloud.com/help/en/sls/cloud-product-configuration-considerations
  type = list(object({
    # Required parameters
    policy_name  = string # The name of the rule, 3-63 chars, must start with a letter
    product_code = string # Product code (Required, ForceNew)
    enabled      = bool   # Whether to open (Required)
    data_code    = string # Log type encoding (Required, ForceNew)

    # Policy configuration (Required)
    policy_config = object({
      resource_mode = string                 # Resource collection mode: all, attributeMode, instanceMode
      instance_ids  = optional(list(string)) # Collection of instance IDs, valid only if resourceMode is instanceMode
      regions       = optional(list(string)) # Region collection, valid only when resourceMode is attributeMode
      resource_tags = optional(map(string))  # Resource label, valid if resourceMode is attributeMode
    })


    # Optional data configuration (ForceNew)
    data_config = optional(object({
      data_region = optional(string) # If log type is global, specify region for collection
    }))

    # Optional resource directory configuration
    resource_directory = optional(object({
      enabled            = optional(bool, true)    # Whether to enable multi-account collection
      account_group_type = optional(string, "all") # Support all mode 'all' and custom mode 'custom'
      members            = optional(list(string))  # Member account list when in custom mode
      }), {
      enabled            = true
      account_group_type = "all"
    })

    # Logstore configuration
    logstore = object({
      name   = optional(string)     # Target logstore name (auto-generated if null: central-{productCode}-{dataCode}-{policyName})
      create = optional(bool, true) # Whether to create the logstore

      # Core logstore parameters
      retention_period      = optional(number, 30) # Data retention time (in days). Valid values: [1-3650]. Default to 30
      shard_count           = optional(number, 2)  # Number of shards. Default to 2
      auto_split            = optional(bool, true) # Whether to automatically split a shard. Default to false
      max_split_shard_count = optional(number, 64) # Maximum number of shards for automatic split (1-256). Required when auto_split is true

      # Storage and metering parameters
      mode           = optional(string, "standard") # Storage mode: standard, query, lite. Default to standard
      metering_mode  = optional(string)             # Metering mode: ChargeByFunction, ChargeByDataIngest
      telemetry_type = optional(string)             # Store type: empty for log store, "Metrics" for metric store

      # TTL parameters
      hot_ttl               = optional(number, 30) # TTL of hot storage. Default to 30, at least 30, must be less than retention_period
      infrequent_access_ttl = optional(number)     # Low frequency storage time

      # Meta parameters
      append_meta = optional(bool, true) # Whether to append log meta automatically (receive time and client IP). Default to true
    })
  }))
  default = []

  # Validate policy names: start with letter, 3-63 chars, only [a-z0-9_-]
  validation {
    condition = alltrue([
      for p in var.collection_policies : can(regex("^[a-z][a-z0-9_-]{2,62}$", p.policy_name))
    ])
    error_message = "Each policy_name must start with a letter, be 3-63 chars, and contain only lowercase letters, digits, hyphens (-), and underscores (_)."
  }

  # Validate policy names are unique
  validation {
    condition     = length(distinct([for p in var.collection_policies : p.policy_name])) == length(var.collection_policies)
    error_message = "policy_name values must be unique within the project."
  }

  # Validate logstore names (if provided)
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.name == null || can(regex("^[a-z0-9][a-z0-9_-]{0,61}[a-z0-9]$", p.logstore.name))
    ])
    error_message = "Each logstore.name must be 2-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits, hyphens (-), and underscores (_)."
  }

  # Validate logstore names are unique (if provided)
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.name == null || length([for q in var.collection_policies : q if q.logstore.name == p.logstore.name]) == 1
    ])
    error_message = "logstore.name values must be unique within the project."
  }

  # Validate logstore name is required when create is false
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.create == true || p.logstore.name != null
    ])
    error_message = "logstore.name is required when logstore.create is false."
  }


  # Validate resource_mode values
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      contains(["all", "attributeMode", "instanceMode"], p.policy_config.resource_mode)
    ])
    error_message = "resource_mode must be one of: all, attributeMode, instanceMode."
  }

  # Validate account_group_type values
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.resource_directory == null ||
      try(p.resource_directory.account_group_type, null) == null ||
      try(contains(["all", "custom"], p.resource_directory.account_group_type), false)
    ])
    error_message = "account_group_type must be 'all' or 'custom'."
  }

  # Validate logstore retention_period
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.retention_period == null || (p.logstore.retention_period >= 1 && p.logstore.retention_period <= 3650)
    ])
    error_message = "logstore.retention_period must be between 1 and 3650 days."
  }

  # Validate logstore max_split_shard_count
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.max_split_shard_count == null || (p.logstore.max_split_shard_count >= 1 && p.logstore.max_split_shard_count <= 256)
    ])
    error_message = "logstore.max_split_shard_count must be between 1 and 256."
  }

  # Validate logstore mode
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      contains(["standard", "query", "lite"], p.logstore.mode)
    ])
    error_message = "logstore.mode must be one of: standard, query, lite."
  }

  # Validate logstore metering_mode
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.metering_mode == null ||
      try(contains(["ChargeByFunction", "ChargeByDataIngest"], p.logstore.metering_mode), false)
    ])
    error_message = "logstore.metering_mode must be 'ChargeByFunction' or 'ChargeByDataIngest'."
  }

  # Validate logstore hot_ttl
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.hot_ttl == null || p.logstore.hot_ttl >= 30
    ])
    error_message = "logstore.hot_ttl must be at least 30 days."
  }

  # Validate hot_ttl is less than or equal to retention_period
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.logstore.hot_ttl == null || p.logstore.retention_period == null || p.logstore.hot_ttl <= p.logstore.retention_period
    ])
    error_message = "logstore.hot_ttl must be less than or equal to logstore.retention_period."
  }

  # Validate resource_mode must be 'all' for specific SLS data codes
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      !(p.product_code == "sls" && contains(["audit_log", "error_log", "monitor_metric"], p.data_code)) || p.policy_config.resource_mode == "all"
    ])
    error_message = "When product_code is 'sls' and data_code is 'audit_log', 'error_log', or 'monitor_metric', policy_config.resource_mode must be 'all'."
  }

  # Validate data_region is required for specific product_code and data_code combinations
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      !((p.product_code == "sls" && contains(["audit_log", "error_log", "monitor_metric"], p.data_code)) ||
      (p.product_code == "oss" && p.data_code == "metering_log")) ||
      (p.data_config != null && try(p.data_config.data_region, null) != null)
    ])
    error_message = "data_config.data_region is required when: (product_code is 'sls' and data_code is 'audit_log', 'error_log', or 'monitor_metric') or (product_code is 'oss' and data_code is 'metering_log')."
  }

  # Validate resource_mode must be 'attributeMode' for specific product_code and data_code combinations
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      !((p.product_code == "waf" && p.data_code == "access_log") ||
        (p.product_code == "wafnew" && p.data_code == "access_log") ||
        (p.product_code == "wafng" && p.data_code == "access_log") ||
        (p.product_code == "sas" && p.data_code == "sas_log") ||
        (p.product_code == "sasnew" && contains(["http", "session", "dns", "local_dns", "snapshot_process", "snapshot_port", "snapshot_host", "login", "network", "process", "dns_query", "crack", "client", "security"], p.data_code)) ||
        (p.product_code == "ddosbgp" && p.data_code == "access_log") ||
        (p.product_code == "ddoscoo" && p.data_code == "access_log") ||
        (p.product_code == "ddosdip" && p.data_code == "access_log") ||
        (p.product_code == "kms" && p.data_code == "audit_log") ||
        (p.product_code == "cloudfirewall" && p.data_code == "firewall_log") ||
      (p.product_code == "cloudfirewallnew" && p.data_code == "firewall_log")) ||
      p.policy_config.resource_mode == "attributeMode"
    ])
    error_message = "policy_config.resource_mode must be 'attributeMode' for the specified product_code and data_code combinations (waf/wafnew/wafng access_log, sas sas_log, sasnew specific logs, ddosbgp/ddoscoo/ddosdip access_log, kms audit_log, cloudfirewall/cloudfirewallnew firewall_log)."
  }

  # Validate regions is required when resource_mode is 'attributeMode'
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.policy_config.resource_mode != "attributeMode" || p.policy_config.regions != null
    ])
    error_message = "policy_config.regions is required when policy_config.resource_mode is 'attributeMode'."
  }

  # Validate instance_ids is required when resource_mode is 'instanceMode'
  validation {
    condition = alltrue([
      for p in var.collection_policies :
      p.policy_config.resource_mode != "instanceMode" || p.policy_config.instance_ids != null
    ])
    error_message = "policy_config.instance_ids is required when policy_config.resource_mode is 'instanceMode'."
  }
}


