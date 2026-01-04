output "account_id" {
  description = "The ID of the created member account."
  value       = alicloud_resource_manager_account.account.id
}

output "resource_directory_id" {
  description = "The ID of the resource directory."
  value       = alicloud_resource_manager_account.account.resource_directory_id
}
