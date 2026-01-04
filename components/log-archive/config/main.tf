# Get current account information
data "alicloud_account" "this" {
  provider = alicloud.log_archive
}

# Enable SLS service
data "alicloud_log_service" "open" {
  provider = alicloud.sls
  enable   = "On"
}

# Enable OSS service
data "alicloud_oss_service" "open" {
  provider = alicloud.oss
  enable   = "On"
}

# Enable Config service
module "enable_config_service" {
  source = "../../../modules/config-configuration-recorder"

  providers = {
    alicloud = alicloud.log_archive
  }
}

# Create OSS bucket for config delivery if enabled
module "oss_bucket" {
  source = "../../../modules/oss-bucket"

  count = var.enable_oss_delivery ? 1 : 0

  providers = {
    alicloud = alicloud.oss
  }

  bucket_name                      = var.oss_bucket_name
  append_random_suffix             = var.append_random_suffix
  random_suffix_length             = var.random_suffix_length
  random_suffix_separator          = var.random_suffix_separator
  force_destroy                    = var.oss_bucket_force_destroy
  versioning                       = var.oss_bucket_versioning
  tags                             = var.oss_bucket_tags
  storage_class                    = var.oss_bucket_storage_class
  acl                              = var.oss_bucket_acl
  server_side_encryption_enabled   = var.oss_bucket_server_side_encryption_enabled
  server_side_encryption_algorithm = var.oss_bucket_server_side_encryption_algorithm
  kms_master_key_id                = var.oss_bucket_kms_master_key_id
  kms_data_encryption              = var.oss_bucket_kms_data_encryption
  redundancy_type                  = var.oss_bucket_redundancy_type

  depends_on = [data.alicloud_oss_service.open]
}

# Create SLS project for config delivery if enabled
module "sls_project" {
  source = "../../../modules/sls-project"

  count = var.enable_sls_delivery ? 1 : 0

  providers = {
    alicloud = alicloud.sls
  }

  project_name            = coalesce(var.sls_project_name, "config-${data.alicloud_account.this.id}")
  create_project          = var.sls_create_project
  append_random_suffix    = var.append_random_suffix
  random_suffix_length    = var.random_suffix_length
  random_suffix_separator = var.random_suffix_separator
  description             = var.sls_project_description
  tags                    = var.sls_project_tags

  depends_on = [data.alicloud_log_service.open]
}

# Optional logstore for config delivery
module "sls_logstore" {
  source = "../../../modules/sls-logstore"

  count = var.enable_sls_delivery ? 1 : 0

  providers = {
    alicloud = alicloud.sls
  }

  project_name  = module.sls_project[0].project_name
  logstore_name = coalesce(var.sls_logstore_name, "cloudconfig_${data.alicloud_account.this.id}")

  create_logstore       = var.sls_logstore_create
  retention_period      = var.sls_logstore_retention_period
  shard_count           = var.sls_logstore_shard_count
  auto_split            = var.sls_logstore_auto_split
  max_split_shard_count = var.sls_logstore_max_split_shard_count
  mode                  = var.sls_logstore_mode
  metering_mode         = var.sls_logstore_metering_mode
  telemetry_type        = var.sls_logstore_telemetry_type
  hot_ttl               = var.sls_logstore_hot_ttl
  infrequent_access_ttl = var.sls_logstore_infrequent_access_ttl
  append_meta           = var.sls_logstore_append_meta

  depends_on = [module.sls_project]
}

# Create Config aggregator
# Note: Refer to components/guardrails/detective to avoid duplicates
resource "alicloud_config_aggregator" "aggregator" {
  count = var.use_existing_aggregator ? 0 : 1

  provider = alicloud.log_archive
  aggregator_name = var.config_aggregator_name
  aggregator_type = var.config_aggregator_type
  description     = var.config_aggregator_description
  folder_id       = var.config_aggregator_type == "FOLDER" ? var.config_aggregator_folder_id : null

  depends_on = [module.enable_config_service]
}

# Get aggregator ID (use existing or create new)
locals {
  aggregator_id = var.use_existing_aggregator ? var.existing_aggregator_id : alicloud_config_aggregator.aggregator[0].id
}

# Create OSS aggregate delivery channel if enabled
resource "alicloud_config_aggregate_delivery" "oss" {
  provider = alicloud.log_archive
  count = var.enable_oss_delivery ? 1 : 0

  aggregator_id = local.aggregator_id
  delivery_channel_name                  = var.oss_delivery_channel_name
  delivery_channel_type                  = "OSS"
  delivery_channel_target_arn            = module.oss_bucket[0].bucket_arn
  configuration_item_change_notification = true
  configuration_snapshot                 = true

  depends_on = [module.oss_bucket, alicloud_config_aggregator.aggregator]
}

# Create SLS aggregate delivery channel if enabled
resource "alicloud_config_aggregate_delivery" "sls" {
  provider = alicloud.log_archive
  count = var.enable_sls_delivery ? 1 : 0

  aggregator_id = local.aggregator_id
  delivery_channel_name                  = var.sls_delivery_channel_name
  delivery_channel_type                  = "SLS"
  delivery_channel_target_arn            = module.sls_logstore[0].logstore_arn
  configuration_item_change_notification = true
  configuration_snapshot                 = true

  depends_on = [module.sls_logstore, alicloud_config_aggregator.aggregator]
}
