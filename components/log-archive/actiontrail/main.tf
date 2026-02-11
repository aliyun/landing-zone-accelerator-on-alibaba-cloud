# Get current account information
data "alicloud_account" "current" {
  provider = alicloud.log_archive
}

data "alicloud_account" "oss" {
  provider = alicloud.oss
}

data "alicloud_account" "sls" {
  provider = alicloud.sls
}


# Generate default resource names for OSS bucket and SLS project
locals {
  oss_bucket_name  = try(var.oss_bucket_name, "actiontrail-${data.alicloud_account.oss.id}")
  sls_project_name = try(var.sls_project_name, "actiontrail-${data.alicloud_account.sls.id}")
}

# Enable required services
data "alicloud_log_service" "open" {
  provider = alicloud.sls
  enable   = "On"
}

# Enable OSS service
data "alicloud_oss_service" "open" {
  provider = alicloud.oss
  enable   = "On"
}

# Create OSS bucket for ActionTrail logs if enabled
module "oss_bucket" {
  count  = var.enable_oss_delivery ? 1 : 0
  source = "../../../modules/oss-bucket"

  providers = {
    alicloud = alicloud.oss
  }

  bucket_name                      = local.oss_bucket_name
  append_random_suffix             = var.append_random_suffix
  random_suffix_length             = var.random_suffix_length
  random_suffix_separator          = var.random_suffix_separator
  force_destroy                    = var.oss_force_destroy
  tags                             = var.tags
  server_side_encryption_enabled   = var.oss_server_side_encryption_enabled
  server_side_encryption_algorithm = var.oss_server_side_encryption_algorithm
  kms_master_key_id                = var.oss_kms_master_key_id
  kms_data_encryption              = var.oss_kms_data_encryption
  redundancy_type                  = var.oss_redundancy_type

  depends_on = [data.alicloud_oss_service.open]
}

# Create SLS project and logstore for ActionTrail logs if enabled
module "sls_project" {
  count  = var.enable_sls_delivery ? 1 : 0
  source = "../../../modules/sls-project"

  providers = {
    alicloud = alicloud.sls
  }

  project_name            = local.sls_project_name
  create_project          = var.sls_create_project
  append_random_suffix    = var.append_random_suffix
  random_suffix_length    = var.random_suffix_length
  random_suffix_separator = var.random_suffix_separator
  description             = var.sls_project_description
  tags                    = var.tags

  depends_on = [data.alicloud_log_service.open]
}

# Create ActionTrail trail with OSS and SLS delivery
resource "alicloud_actiontrail_trail" "main" {
  provider              = alicloud.log_archive
  trail_name            = var.trail_name
  status                = var.trail_status
  event_rw              = var.event_type
  trail_region          = var.trail_region
  is_organization_trail = var.is_organization_trail

  # Configure OSS delivery (optional)
  oss_write_role_arn = var.enable_oss_delivery ? (
    var.oss_write_role_arn != null ? var.oss_write_role_arn : "acs:ram::${data.alicloud_account.oss.id}:role/aliyunserviceroleforactiontrail"
  ) : null
  oss_bucket_name = var.enable_oss_delivery ? module.oss_bucket[0].bucket : null

  # Configure SLS delivery (optional)
  sls_write_role_arn = var.enable_sls_delivery ? (
    var.sls_write_role_arn != null ? var.sls_write_role_arn : "acs:ram::${data.alicloud_account.sls.id}:role/aliyunserviceroleforactiontrail"
  ) : null
  sls_project_arn = var.enable_sls_delivery ? module.sls_project[0].project_arn : null

  depends_on = [
    module.oss_bucket,
    module.sls_project
  ]
}
