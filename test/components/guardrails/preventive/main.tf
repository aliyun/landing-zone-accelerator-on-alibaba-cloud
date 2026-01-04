# Provider configuration
provider "alicloud" {
  region = "cn-hangzhou"
}

# Test preventive guardrails component
module "preventive_guardrails" {
  source = "../../../../components/guardrails/preventive"

  # Test inline configurations
  control_policies = [
    {
      name = "DenyDeleteRolePolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["ram:DeleteRole", "ram:DeletePolicy"]
            Resource = "*"
          }
        ]
      })
      description = "Deny deletion of RAM roles and policies"
      tags = {
        Environment = "test"
      }
      # No target_ids, target_folder_names, target_folder_name_regexes, target_account_display_names, or attach_to_root
    },
    {
      name = "RootLevelSecurityPolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["ecs:DeleteInstance"]
            Resource = "*"
          }
        ]
      })
      description    = "Security policy applied at root level"
      attach_to_root = true
    },
    {
      name = "MixedTargetPolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["oss:DeleteBucket"]
            Resource = "*"
          }
        ]
      })
      description                  = "Policy with mixed target types"
      target_ids                   = ["123456789012"]
      target_folder_names          = ["Core", "Development"]
      target_account_display_names = ["Test Security Account"]
    },
    {
      name = "CombinedTargetPolicy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["vpc:DeleteVpc"]
            Resource = "*"
          }
        ]
      })
      description                  = "Policy with combined target types including regex"
      target_ids                   = ["fd-xxxxx"]
      target_folder_names          = ["Production"]
      target_folder_name_regexes   = ["^Web-Services-.*", "^Frontend-Prod-.*"]
      target_account_display_names = ["Test Log Management Account"]
    }
  ]

  # Test directory-based configurations
  control_policies_dir = "${path.module}/configs"
}

output "policies" {
  value = module.preventive_guardrails.policies
}
