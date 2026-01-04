variable "enable_oss_delivery" {
  description = "Whether to enable OSS delivery for ActionTrail"
  type        = bool
  default     = false
}

variable "enable_sls_delivery" {
  description = "Whether to enable SLS delivery for ActionTrail"
  type        = bool
  default     = false
}

variable "trail_name" {
  description = "The name of the ActionTrail trail"
  type        = string
  default     = "landingzone-actiontrail"
}

variable "trail_status" {
  description = "The status of the trail. Valid values: Enable, Disable"
  type        = string
  default     = "Enable"
}

variable "event_type" {
  description = "The types of events to be recorded. Valid values: Write, Read, All"
  type        = string
  default     = "Write"
}

variable "trail_region" {
  description = "The regions to which the trail belongs. Valid values: cn-hangzhou, cn-shanghai, etc. Use 'All' for global trail"
  type        = string
  default     = "All"
}

variable "is_organization_trail" {
  description = "Specifies whether to create a multi-account trail"
  type        = bool
  default     = false
}

# OSS related variables
variable "oss_bucket_name" {
  description = "The name of the OSS bucket for storing ActionTrail logs"
  type        = string
  default     = null
}

# Random suffix controls for resource names (applies to both OSS bucket and SLS project)
variable "append_random_suffix" {
  description = "Whether to append a random suffix to resource names to ensure global uniqueness"
  type        = bool
  default     = false
}

variable "random_suffix_length" {
  description = "Length of the random suffix for resource names"
  type        = number
  default     = 6

  validation {
    condition     = var.random_suffix_length >= 3 && var.random_suffix_length <= 16
    error_message = "Random suffix length must be between 3 and 16."
  }
}

variable "random_suffix_separator" {
  description = "Separator between resource names and random suffix"
  type        = string
  default     = "-"

  validation {
    condition     = var.random_suffix_separator == "-" || var.random_suffix_separator == "_" || var.random_suffix_separator == ""
    error_message = "Random suffix separator must be '-', '_' or empty."
  }
}


variable "oss_server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the OSS bucket"
  type        = bool
  default     = true
}

variable "oss_server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use for the OSS bucket. Possible values: AES256 and KMS"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.oss_server_side_encryption_algorithm)
    error_message = "OSS server-side encryption algorithm must be one of: AES256, KMS."
  }
}

variable "oss_write_role_arn" {
  description = "The ARN of the RAM role used by ActionTrail to write to OSS"
  type        = string
  default     = null
}

variable "oss_force_destroy" {
  description = "Whether to force destroy the OSS bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "oss_kms_master_key_id" {
  description = "The alibaba cloud KMS master key ID used for the SSE-KMS encryption"
  type        = string
  default     = null
}

variable "oss_kms_data_encryption" {
  description = "The algorithm used to encrypt objects. Valid values: SM4. This element is valid only when the value of SSEAlgorithm is set to KMS"
  type        = string
  default     = null

  validation {
    condition     = var.oss_kms_data_encryption == null || var.oss_kms_data_encryption == "SM4"
    error_message = "OSS KMS data encryption must be null or SM4."
  }
}

variable "oss_redundancy_type" {
  description = "The redundancy type to enable. Can be 'LRS' and 'ZRS'. Defaults to 'ZRS'"
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS"], var.oss_redundancy_type)
    error_message = "OSS redundancy type must be one of: LRS, ZRS."
  }
}

# SLS related variables
variable "sls_project_name" {
  description = "The name of the SLS project for storing ActionTrail logs"
  type        = string
  default     = null

  validation {
    condition     = var.sls_project_name == null || can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.sls_project_name))
    error_message = "SLS project name must be 3-63 characters, start and end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

# Whether to create a new SLS project. If false, use existing project_name
variable "sls_create_project" {
  description = "Whether to create a new SLS project. If false, use existing project_name"
  type        = bool
  default     = true
}

variable "sls_project_description" {
  description = "The description of the SLS project"
  type        = string
  default     = "ActionTrail logs storage"
}



variable "sls_write_role_arn" {
  description = "The ARN of the RAM role used by ActionTrail to write to SLS"
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
