# RAM Role
module "ram_role" {
  source = "../../../../components/account-factory/baseline/ram-role"

  providers = {
    alicloud = alicloud.default
  }

  role_name                   = "ReadOnlyRole"
  max_session_duration        = 28800
  role_requires_mfa           = false
  trusted_principal_arns      = ["acs:ram::1499749525969183:root"]
  managed_system_policy_names = ["ReadOnlyAccess"]
}

output "ram_role" {
  description = "RAM role output"
  value       = module.ram_role
}

