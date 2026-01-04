# Provider configuration for SLS project region
provider "alicloud" {
  alias  = "sls_project"
  region = "cn-beijing"
}

# Provider configuration for log audit region
provider "alicloud" {
  alias  = "log_audit"
  region = "cn-shanghai"
}

# Test log audit component
module "log_audit" {
  source = "../../../../components/log-archive/log-audit"

  providers = {
    alicloud.sls_project = alicloud.sls_project
    alicloud.log_audit   = alicloud.log_audit
  }

  # Project settings
  project_name        = "log-audit"
  create_project      = true
  project_description = "Test project for log audit module"
  project_tags        = { env = "test" }

  # Random suffix configuration
  append_random_suffix    = true
  random_suffix_length    = 6
  random_suffix_separator = "-"

  # Collection policies: OSS access_log and RDS slow_log
  collection_policies = [
    {
      policy_name  = "oss-access-log-policy"
      product_code = "oss"
      data_code    = "access_log"
      enabled      = true

      policy_config = {
        resource_mode = "all"
      }

      # Create destination logstore in the same project (name will be auto-generated)
      logstore = {
        create                = true
        retention_period      = 30
        shard_count           = 2
        auto_split            = false
        max_split_shard_count = 64
        mode                  = "standard"
        append_meta           = true
      }
    },
    {
      policy_name  = "rds-slow-log-policy"
      product_code = "rds"
      data_code    = "slow_log"
      enabled      = true

      policy_config = {
        resource_mode = "all"
      }

      # Disable multi-account collection for RDS
      resource_directory = {
        enabled = false
      }

      # Create destination logstore in the same project (name will be auto-generated)
      logstore = {
        create                = true
        retention_period      = 30
        shard_count           = 2
        auto_split            = false
        max_split_shard_count = 64
        mode                  = "standard"
        append_meta           = true
      }
    }
  ]
}

# Outputs for test verification
output "project_name" {
  value = module.log_audit.project_name
}

output "logstore_names" {
  value = module.log_audit.logstore_names
}

output "collection_policy_names" {
  value = module.log_audit.collection_policy_names
}

output "collection_policy_ids" {
  value = module.log_audit.collection_policy_ids
}

output "collection_policy_status" {
  value = module.log_audit.collection_policy_status
}

output "collection_policies_summary" {
  value = module.log_audit.collection_policies_summary
}


