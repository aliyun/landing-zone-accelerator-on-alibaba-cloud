output "user_name" {
  description = "The name of RAM user"
  value       = module.ram_user.user_name
}

output "user_id" {
  description = "The unique ID assigned by alicloud"
  value       = module.ram_user.user_id
}

output "access_key_id" {
  description = "The access key ID"
  value       = module.ram_user.access_key_id
}

output "access_key_secret" {
  description = "The access key secret"
  value       = module.ram_user.access_key_secret
  sensitive   = true
}

output "access_key_encrypted_secret" {
  description = "The access key encrypted secret, base64 encoded"
  value       = module.ram_user.access_key_encrypted_secret
}

output "access_key_key_fingerprint" {
  description = "The fingerprint of the PGP key used to encrypt the secret"
  value       = module.ram_user.access_key_key_fingerprint
}

output "access_key_status" {
  description = "Active or Inactive. Keys are initially active, but can be made inactive by other means."
  value       = module.ram_user.access_key_status
}

output "pgp_key" {
  description = "PGP key used to encrypt sensitive data for this user (if empty, no encryption)"
  value       = module.ram_user.pgp_key
}
