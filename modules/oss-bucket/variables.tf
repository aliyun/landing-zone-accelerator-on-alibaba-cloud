# The name of the OSS bucket
variable "bucket_name" {
  description = "The name of the OSS bucket"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, start and end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

# Whether to append a random suffix to the OSS bucket_name to ensure global uniqueness
variable "append_random_suffix" {
  description = "Whether to append a random suffix to the OSS bucket_name to ensure global uniqueness"
  type        = bool
  default     = false
}

# Length of the random suffix for the OSS bucket_name
variable "random_suffix_length" {
  description = "Length of the random suffix for the OSS bucket_name"
  type        = number
  default     = 6
}

# Separator between the OSS bucket_name and random suffix
variable "random_suffix_separator" {
  description = "Separator between the OSS bucket_name and random suffix"
  type        = string
  default     = "-"
}

# When deleting a bucket, automatically delete all objects
variable "force_destroy" {
  description = "When deleting a bucket, automatically delete all objects"
  type        = bool
  default     = false
}

# The versioning status of the bucket
variable "versioning" {
  description = "The versioning status of the bucket"
  type        = bool
  default     = false
}

# A mapping of tags to assign to the bucket
variable "tags" {
  description = "A mapping of tags to assign to the bucket"
  type        = map(string)
  default     = null
}

# The storage class of the bucket
variable "storage_class" {
  description = "The storage class of the bucket"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "IA", "Archive", "ColdArchive", "DeepColdArchive"], var.storage_class)
    error_message = "Storage class must be one of: Standard, IA, Archive, ColdArchive, DeepColdArchive."
  }
}

# The canned ACL to apply to the bucket
variable "acl" {
  description = "The canned ACL to apply to the bucket"
  type        = string
  default     = "private"
}


# Specifies whether to enable server-side encryption for the bucket
variable "server_side_encryption_enabled" {
  description = "Specifies whether to enable server-side encryption for the bucket"
  type        = bool
  default     = true
}

# The server-side encryption algorithm to use
variable "server_side_encryption_algorithm" {
  description = "The server-side encryption algorithm to use. Possible values: AES256 and KMS"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.server_side_encryption_algorithm)
    error_message = "Server-side encryption algorithm must be one of: AES256, KMS."
  }
}

# The alibaba cloud KMS master key ID used for the SSE-KMS encryption
variable "kms_master_key_id" {
  description = "The alibaba cloud KMS master key ID used for the SSE-KMS encryption"
  type        = string
  default     = null
}

# The algorithm used to encrypt objects
variable "kms_data_encryption" {
  description = "The algorithm used to encrypt objects. Valid values: SM4. This element is valid only when the value of SSEAlgorithm is set to KMS"
  type        = string
  default     = null

  validation {
    condition     = var.kms_data_encryption == null || var.kms_data_encryption == "SM4"
    error_message = "KMS data encryption must be null or SM4."
  }
}

# The redundancy type to enable
variable "redundancy_type" {
  description = "The redundancy type to enable. Can be 'LRS' and 'ZRS'. Defaults to 'ZRS'"
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS"], var.redundancy_type)
    error_message = "Redundancy type must be one of: LRS, ZRS."
  }
}
