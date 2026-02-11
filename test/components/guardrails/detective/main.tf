# Provider configuration
provider "alicloud" {
  region = "cn-shanghai"
}

# Test detective guardrails component
module "detective_guardrails" {
  source = "../../../../components/guardrails/detective"
  # Use CUSTOM aggregator type with mock member accounts
  use_existing_aggregator = false
  aggregator_name         = "test-custom-aggregator"
  aggregator_type         = "CUSTOM"

  aggregator_accounts = [
    {
      account_id   = "<ACCOUNT_ID>"
      account_name = "shared-service"
    }
  ]
  enable_compliance_pack = true
  compliance_pack_name   = "Resource Stability Best Practices v2"
  risk_level             = 1
  template_based_rules = [
    {
      rule_name                       = "ECSInstanceNoPublicIP"
      description                     = "Ensure ECS instances do not have public IP addresses"
      source_template_id              = "ecs-instance-no-public-ip"
      maximum_execution_frequency     = "One_Hour"
      scope_compliance_resource_types = ["ACS::ECS::Instance"]
      add_to_compliance_pack          = true
    },
    {
      rule_name                       = "OSSBucketPublicReadProhibited"
      description                     = "Ensure OSS buckets do not allow public read"
      source_template_id              = "oss-bucket-public-read-prohibited"
      maximum_execution_frequency     = "Six_Hours"
      scope_compliance_resource_types = ["ACS::OSS::Bucket"]
      risk_level                      = 2
      trigger_types                   = "ScheduledNotification"
      add_to_compliance_pack          = true
    },
    {
      rule_name                       = "ActionTrailEnabled"
      description                     = "Ensure ActionTrail is enabled for audit logging"
      source_template_id              = "actiontrail-enabled"
      scope_compliance_resource_types = ["ACS::ActionTrail::Trail"]
      trigger_types                   = "ScheduledNotification"
      add_to_compliance_pack          = false
    },
    {
      rule_name                       = "OSSBucketVersioningEnabled"
      description                     = "Ensure OSS bucket versioning is enabled"
      source_template_id              = "oss-bucket-versioning-enabled"
      scope_compliance_resource_types = ["ACS::OSS::Bucket"]
      trigger_types                   = "ScheduledNotification"
      risk_level                      = 2
      add_to_compliance_pack          = false
    }
  ]
  aggregator_accounts_dir  = "${path.module}/aggregator_accounts"
  template_based_rules_dir = "${path.module}/template_based_rules"
  # Custom FC rules are disabled as test environment lacks required Function Compute resources
  custom_fc_rules = []
}

# Test FOLDER type aggregator with specific folder ID
resource "alicloud_config_aggregator" "folder_test" {
  aggregator_name = "test-folder-aggregator"
  aggregator_type = "FOLDER"
  description     = "Test FOLDER type aggregator"
  folder_id       = "fd-dearwxxxxxxxxxxxx"
}

# Test RD type aggregator
resource "alicloud_config_aggregator" "rd_test" {
  aggregator_name = "test-RD-aggregator"
  aggregator_type = "RD"
  description     = "Test RD type aggregator"
}

output "aggregator_id" {
  value = module.detective_guardrails.aggregator_id
}

output "compliance_pack_id" {
  value = module.detective_guardrails.compliance_pack_id
}

output "rule_ids" {
  value = module.detective_guardrails.rule_ids
}
