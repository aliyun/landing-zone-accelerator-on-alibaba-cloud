# RAM User
module "ram_user" {
  source = "../../../../components/account-factory/baseline/ram-user"

  providers = {
    alicloud = alicloud.default
  }

  user_name    = "test-user"
  display_name = "Test User"
  email        = "test-user@example.com"
  mobile       = "<MOBILE>"
  comments     = "Test RAM user with login profile and policies"

  create_ram_user_login_profile = true
  password                      = "TestPassword123!"
  password_reset_required       = false
  mfa_bind_required             = false

  managed_system_policy_names = ["ReadOnlyAccess"]

  inline_custom_policies = [
    {
      policy_name = "test-oss-readonly"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["oss:GetObject", "oss:ListObjects"]
            Resource = ["acs:oss:*:*:*"]
          }
        ]
      })
      description = "Test OSS read-only access policy"
    }
  ]
}

output "ram_user_name" {
  description = "The name of RAM user"
  value       = module.ram_user.user_name
}

output "ram_user_id" {
  description = "The unique ID assigned by alicloud"
  value       = module.ram_user.user_id
}

output "ram_user_access_key_id" {
  description = "The access key ID"
  value       = module.ram_user.access_key_id
}

output "ram_user_access_key_secret" {
  description = "The access key secret"
  value       = module.ram_user.access_key_secret
  sensitive   = true
}

output "ram_user_access_key_encrypted_secret" {
  description = "The access key encrypted secret, base64 encoded"
  value       = module.ram_user.access_key_encrypted_secret
}

output "ram_user_access_key_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the secret"
  value       = module.ram_user.access_key_key_fingerprint
}

output "ram_user_access_key_status" {
  description = "Active or Inactive. Keys are initially active, but can be made inactive by other means."
  value       = module.ram_user.access_key_status
}

output "ram_user_pgp_key" {
  description = "PGP key used to encrypt sensitive data for this user (if empty, no encryption)"
  value       = module.ram_user.pgp_key
}
