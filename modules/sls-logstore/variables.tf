# Target project name (must exist)
variable "project_name" {
  description = "Name of the destination SLS project to host the logstore"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

# Whether to create the logstore (true) or use an existing one (false)
variable "create_logstore" {
  description = "Whether to create the logstore (true) or use an existing logstore (false)"
  type        = bool
  default     = true
}

# Logstore configuration (align with log-audit collection_policies.logstore)
variable "logstore_name" {
  description = "Name of the logstore to create or reference"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{0,61}[a-z0-9]$", var.logstore_name))
    error_message = "logstore name must be 2-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits, hyphens (-), and underscores (_)."
  }
}

variable "retention_period" {
  description = "Data retention time in days (1-3650)"
  type        = number
  default     = 30

  validation {
    condition     = var.retention_period >= 1 && var.retention_period <= 3650
    error_message = "retention_period must be between 1 and 3650 days."
  }
}

variable "shard_count" {
  description = "Number of shards (default 2 if omitted by provider)"
  type        = number
  default     = 2
}

variable "auto_split" {
  description = "Whether to automatically split a shard"
  type        = bool
  default     = false
}

variable "max_split_shard_count" {
  description = "Maximum number of shards for auto split (1-256); required when auto_split is true"
  type        = number
  default     = null

  validation {
    condition     = var.max_split_shard_count == null || (var.max_split_shard_count != null && var.max_split_shard_count >= 1 && var.max_split_shard_count <= 256)
    error_message = "max_split_shard_count must be provided when auto_split is true and be between 1 and 256."
  }
}

variable "mode" {
  description = "Storage mode: standard, query, lite"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "query", "lite"], var.mode)
    error_message = "mode must be one of: standard, query, lite."
  }
}

variable "metering_mode" {
  description = "Metering mode: ChargeByFunction or ChargeByDataIngest"
  type        = string
  default     = null

  validation {
    condition     = var.metering_mode == null || try(contains(["ChargeByFunction", "ChargeByDataIngest"], var.metering_mode), false)
    error_message = "metering_mode must be 'ChargeByFunction' or 'ChargeByDataIngest'."
  }
}

variable "telemetry_type" {
  description = "Store type: empty for log store, Metrics for metric store"
  type        = string
  default     = null
}

variable "hot_ttl" {
  description = "TTL of hot storage (>=30 and <= retention_period)"
  type        = number
  default     = 30

  validation {
    condition     = var.hot_ttl == null || var.hot_ttl >= 30
    error_message = "hot_ttl must be at least 30 days."
  }
}

variable "infrequent_access_ttl" {
  description = "Low-frequency storage time"
  type        = number
  default     = null
}

variable "append_meta" {
  description = "Whether to append log meta automatically"
  type        = bool
  default     = true
}


