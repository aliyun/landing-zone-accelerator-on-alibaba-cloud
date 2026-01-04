# Get current account information
data "alicloud_account" "this" {}

# Get current region information
data "alicloud_regions" "this" {
  current = true
}

# Verify existing logstore when not creating
data "alicloud_log_stores" "existing" {
  count      = var.create_logstore ? 0 : 1
  project    = var.project_name
  name_regex = "^${var.logstore_name}$"
}

# Create SLS logstore
resource "alicloud_log_store" "this" {
  count         = var.create_logstore ? 1 : 0
  project_name  = var.project_name
  logstore_name = var.logstore_name

  # Core settings
  retention_period      = var.retention_period
  shard_count           = var.shard_count
  auto_split            = var.auto_split
  max_split_shard_count = var.auto_split ? var.max_split_shard_count : null

  # Storage/metering settings
  mode           = var.mode
  metering_mode  = var.metering_mode
  telemetry_type = var.telemetry_type

  # TTL settings
  hot_ttl               = var.hot_ttl
  infrequent_access_ttl = var.infrequent_access_ttl

  # Meta settings
  append_meta = var.append_meta
}

# Validate that existing logstore exists when create_logstore = false
resource "null_resource" "assert_existing_logstore_found" {
  count = var.create_logstore ? 0 : 1

  lifecycle {
    precondition {
      condition     = length(data.alicloud_log_stores.existing[0].stores) > 0
      error_message = "Logstore not found: ensure project_name and logstore_name reference an existing SLS logstore."
    }
  }
}




