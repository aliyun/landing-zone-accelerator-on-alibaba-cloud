# Provider configuration for master account
provider "alicloud" {
  alias  = "master"
  region = "cn-shanghai"
}

# Provider configuration for IAM account
provider "alicloud" {
  alias  = "iam"
  region = "cn-shanghai"
}

# Test CloudSSO component
module "cloudsso" {
  source = "../../../components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name       = "landingzone-accelerator"
  append_random_suffix = true

  random_suffix_separator = "-"

  # Test login preferences
  login_preference = {
    allow_user_to_get_credentials = true
  }

  # Test MFA authentication settings
  mfa_authentication_setting_info = {
    mfa_authentication_advance_settings = "Enabled"
    operation_for_risk_login            = "Autonomous"
  }

  # Test password policy (explicit values)
  password_policy = {
    max_login_attempts            = 3
    max_password_age              = 100
    min_password_different_chars  = 4
    min_password_length           = 8
    password_not_contain_username = true
    password_reuse_prevention     = 0
  }

  access_configurations = [
    {
      name                    = "DirectConfig"
      description             = "Direct configuration test"
      session_duration        = 7200
      managed_system_policies = ["AliyunECSFullAccess"]
      inline_custom_policy = {
        policy_document = jsonencode({
          Version = "1"
          Statement = [
            {
              Effect   = "Allow"
              Action   = ["oss:GetObject"]
              Resource = "*"
            }
          ]
        })
      }
    },
    {
      name                    = "Iam"
      session_duration        = 7200
      managed_system_policies = ["AliyunECSFullAccess"]
    }
  ]
  # Specify config directory
  access_configurations_dir = "${path.module}/configs"

  # Test users and groups creation
  users = [
    {
      user_name    = "tf-test-admin"
      display_name = "Terraform Test Admin User"
      email        = "tf-test-admin@example.com"
      first_name   = "Terraform"
      last_name    = "Admin"
      password     = "TestPassword123!"
      description  = "Default admin user for testing CloudSSO"
      status       = "Enabled"
    }
  ]

  groups = []

  # Test access assignments
  access_assignments = [
    {
      principal_name             = "tf-test-admin"
      principal_type             = "User"
      account_names              = ["Test Log Management Account"]
      include_master_account     = true
      access_configuration_names = ["Billing"]
    }
  ]
}

output "directory_id" {
  value = module.cloudsso.directory_id
}

output "directory_name" {
  value = module.cloudsso.directory_name
}

output "access_configurations" {
  value = module.cloudsso.access_configurations
}

output "users" {
  value = module.cloudsso.users
}

output "groups" {
  value = module.cloudsso.groups
}

output "access_assignments" {
  value = module.cloudsso.access_assignments
}
