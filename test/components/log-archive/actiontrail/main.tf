# Provider configuration for log archive region
provider "alicloud" {
  alias  = "log_archive"
  region = "cn-shanghai"
}

# Provider configuration for OSS region
provider "alicloud" {
  alias  = "oss"
  region = "cn-hangzhou"
}

# Provider configuration for SLS region
provider "alicloud" {
  alias  = "sls"
  region = "cn-beijing"
}

# Test ActionTrail component
module "actiontrail" {
  source = "../../../../components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  # Basic ActionTrail Configuration
  trail_name            = "test-actiontrail"
  trail_status          = "Enable"
  event_type            = "All" # Record all types of events
  trail_region          = "All" # Enable global trail
  is_organization_trail = true  # Enable organization-wide tracking

  # Random suffix configuration (applies to both OSS and SLS)
  append_random_suffix    = true
  random_suffix_length    = 6
  random_suffix_separator = "-"

  # OSS Delivery Configuration
  enable_oss_delivery                  = true
  oss_bucket_name                      = "test-actiontrail-bucket"
  oss_force_destroy                    = true
  oss_server_side_encryption_enabled   = false
  oss_server_side_encryption_algorithm = "AES256"
  oss_kms_master_key_id                = null
  oss_kms_data_encryption              = null
  oss_redundancy_type                  = "ZRS"

  # SLS Delivery Configuration
  enable_sls_delivery     = true
  sls_project_name        = "test-actiontrail"
  sls_create_project      = true
  sls_project_description = "Test ActionTrail logs storage"

  # Resource Tags
  tags = {
    Environment = "test"
    Project     = "landing-zone"
    CreatedBy   = "terraform"
    TestCase    = "actiontrail"
  }
}

# Outputs for test verification
output "trail_name" {
  description = "The name of the created ActionTrail trail"
  value       = module.actiontrail.trail_name
}

output "oss_bucket_name" {
  description = "The name of the OSS bucket used for ActionTrail logs"
  value       = module.actiontrail.oss_bucket_name
}

output "sls_project_name" {
  description = "The name of the SLS project used for ActionTrail logs"
  value       = module.actiontrail.sls_project_name
}
