# Get current account information
data "alicloud_account" "this" {}

# Get current region information
data "alicloud_regions" "this" {
  current = true
}

# Generate random suffix for bucket name when requested
resource "random_string" "suffix" {
  count   = var.append_random_suffix ? 1 : 0
  length  = var.random_suffix_length
  upper   = false
  special = false
  numeric = true
}

# Calculate effective bucket name (with or without random suffix)
locals {
  effective_bucket_name = var.append_random_suffix ? "${var.bucket_name}${var.random_suffix_separator}${random_string.suffix[0].result}" : var.bucket_name
}

# Create OSS bucket
resource "alicloud_oss_bucket" "bucket" {
  bucket = local.effective_bucket_name

  force_destroy   = var.force_destroy
  storage_class   = var.storage_class
  redundancy_type = var.redundancy_type
  tags            = var.tags

  # Configure versioning
  versioning {
    status = var.versioning ? "Enabled" : "Suspended"
  }

  # Configure server-side encryption
  dynamic "server_side_encryption_rule" {
    for_each = var.server_side_encryption_enabled ? [1] : []
    content {
      sse_algorithm       = var.server_side_encryption_algorithm
      kms_master_key_id   = var.kms_master_key_id
      kms_data_encryption = var.kms_data_encryption
    }
  }

}

# Set bucket ACL
resource "alicloud_oss_bucket_acl" "bucket_acl" {
  bucket = alicloud_oss_bucket.bucket.id
  acl    = var.acl
}
