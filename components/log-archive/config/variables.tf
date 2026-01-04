# OSS delivery configuration
variable "enable_oss_delivery" {
  description = "Whether to enable OSS delivery"
  type        = bool
  default     = true
}


variable "oss_bucket_name" {
  description = "The name of the OSS bucket for config delivery"
  type        = string
  default     = null
}

variable "append_random_suffix" {
  description = "Whether to append a random suffix to resource names to ensure global uniqueness"
  type        = bool
  default     = false
}

variable "random_suffix_length" {
  description = "Length of the random suffix for resource names"
  type        = number
  default     = 6
}

variable "random_suffix_separator" {
  description = "Separator between resource names and random suffix"
  type        = string
  default     = "-"
}

variable "oss_bucket_force_destroy" {
  description = "When deleting a bucket, automatically delete all objects"
  type        = bool
  default     = false
}

variable "oss_bucket_versioning" {
  description = "The versioning status of the bucket"
  type        = bool
  default     = true
}

variable "oss_bucket_tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = {}
}

variable "oss_bucket_storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "Standard"
}

variable "oss_bucket_acl" {
  description = "The canned ACL to apply to the bucket"
  type        = string
  default     = "private"
}

variable "oss_bucket_redundancy_type" {
  description = "The redundancy type to enable. Can be 'LRS' and 'ZRS'"
  type        = string
  default     = "ZRS"
}

variable "oss_bucket_server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the bucket"
  type        = bool
  default     = true
}

variable "oss_bucket_server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use. Possible values: AES256 and KMS"
  type        = string
  default     = "AES256"
}

variable "oss_bucket_kms_master_key_id" {
  description = "The alibaba cloud KMS master key ID used for the SSE-KMS encryption"
  type        = string
  default     = null
}

variable "oss_bucket_kms_data_encryption" {
  description = "The algorithm used to encrypt objects. Valid values: SM4. This element is valid only when the value of SSEAlgorithm is set to KMS"
  type        = string
  default     = null
}

# SLS delivery configuration
variable "enable_sls_delivery" {
  description = "Whether to enable SLS delivery"
  type        = bool
  default     = true
}


variable "sls_project_name" {
  description = "The name of the SLS project for config delivery"
  type        = string
  default     = null
}

variable "sls_create_project" {
  description = "Whether to create a new SLS project. If false, use existing project_name"
  type        = bool
  default     = true
}

variable "sls_project_description" {
  description = "The description of the SLS project"
  type        = string
  default     = "Config delivery project"
}

variable "sls_project_tags" {
  description = "A mapping of tags to assign to the project"
  type        = map(string)
  default     = {}
}

# Optional logstore settings for config delivery (used when sls_create_project = true)
variable "sls_logstore_create" {
  description = "Whether to create the SLS logstore (true) or use an existing one (false)"
  type        = bool
  default     = true
}

variable "sls_logstore_name" {
  description = "Name of the SLS logstore to create or reference. It is recommended to use a prefix like 'cloudconfig_' for consistency"
  type        = string
  default     = null

  validation {
    condition     = var.sls_logstore_name == null || can(regex("^[a-z0-9][a-z0-9_-]{0,61}[a-z0-9]$", var.sls_logstore_name))
    error_message = "sls_logstore_name must be 2-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits, hyphens (-), and underscores (_)."
  }
}

variable "sls_logstore_retention_period" {
  description = "SLS logstore retention period in days"
  type        = number
  default     = 180

  validation {
    condition     = var.sls_logstore_retention_period >= 1 && var.sls_logstore_retention_period <= 3650
    error_message = "sls_logstore_retention_period must be between 1 and 3650 days."
  }
}

variable "sls_logstore_shard_count" {
  description = "SLS logstore shard count"
  type        = number
  default     = 2
}

variable "sls_logstore_auto_split" {
  description = "Whether SLS logstore automatically split shards"
  type        = bool
  default     = true
}

variable "sls_logstore_max_split_shard_count" {
  description = "Max shards for auto split"
  type        = number
  default     = 64

  validation {
    condition     = var.sls_logstore_max_split_shard_count == null || (var.sls_logstore_max_split_shard_count >= 1 && var.sls_logstore_max_split_shard_count <= 256)
    error_message = "sls_logstore_max_split_shard_count must be between 1 and 256."
  }
}

variable "sls_logstore_mode" {
  description = "Storage mode: standard, query, lite"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "query", "lite"], var.sls_logstore_mode)
    error_message = "sls_logstore_mode must be one of: standard, query, lite."
  }
}

variable "sls_logstore_metering_mode" {
  description = "Metering mode: ChargeByFunction or ChargeByDataIngest"
  type        = string
  default     = null

  validation {
    condition     = var.sls_logstore_metering_mode == null || try(contains(["ChargeByFunction", "ChargeByDataIngest"], var.sls_logstore_metering_mode), false)
    error_message = "sls_logstore_metering_mode must be 'ChargeByFunction' or 'ChargeByDataIngest'."
  }
}

variable "sls_logstore_telemetry_type" {
  description = "Store type: empty for log store, Metrics for metric store"
  type        = string
  default     = null
}

variable "sls_logstore_hot_ttl" {
  description = "TTL of hot storage (>=30)"
  type        = number
  default     = 30

  validation {
    condition     = var.sls_logstore_hot_ttl == null || var.sls_logstore_hot_ttl >= 30
    error_message = "sls_logstore_hot_ttl must be at least 30 days."
  }
}

variable "sls_logstore_infrequent_access_ttl" {
  description = "Low-frequency storage time"
  type        = number
  default     = null
}

variable "sls_logstore_append_meta" {
  description = "Whether to append log meta automatically"
  type        = bool
  default     = true
}


# Config aggregator configuration
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

variable "config_aggregator_name" {
  description = "The name of the config aggregator"
  type        = string
  default     = "enterprise"
}

variable "config_aggregator_description" {
  description = "The description of the config aggregator"
  type        = string
  default     = ""

  validation {
    condition     = var.config_aggregator_description == "" || (length(var.config_aggregator_description) >= 1 && length(var.config_aggregator_description) <= 256)
    error_message = "Aggregator description must be empty or between 1 and 256 characters."
  }
}

variable "config_aggregator_type" {
  description = "The type of the config aggregator. Valid values are 'RD' (Resource Directory), 'FOLDER' and 'CUSTOM'."
  type        = string
  default     = "RD"

  validation {
    condition     = var.config_aggregator_type == "RD" || var.config_aggregator_type == "CUSTOM" || var.config_aggregator_type == "FOLDER"
    error_message = "Aggregator type must be either 'RD', 'FOLDER' or 'CUSTOM'."
  }
}

variable "config_aggregator_folder_id" {
  description = "The folder ID of the config aggregator. Required when config_aggregator_type is 'FOLDER'."
  type        = string
  default     = null
}

# Config delivery channel configuration
variable "oss_delivery_channel_name" {
  description = "The name of the OSS delivery channel"
  type        = string
  default     = null
}

variable "sls_delivery_channel_name" {
  description = "The name of the SLS delivery channel"
  type        = string
  default     = null
}
