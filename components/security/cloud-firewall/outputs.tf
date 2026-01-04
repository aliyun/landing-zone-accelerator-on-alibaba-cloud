output "cloud_firewall_instance_id" {
  description = "The ID of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].id, null)
}

output "cloud_firewall_instance_status" {
  description = "The status of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].status, null)
}

output "member_account_ids" {
  description = "The list of member account IDs managed by the cloud firewall"
  value       = local.all_member_account_ids
}

output "internet_acl_rule_count" {
  description = "The number of internet ACL rules created"
  value       = length(local.all_internet_acl_rules)
}

output "internet_protection_enabled" {
  description = "Whether internet boundary protection is enabled"
  value       = var.enable_internet_protection
}

output "internet_protection_policy_id" {
  description = "The ID of the internet boundary protection policy"
  value       = try(alicloud_cloud_firewall_control_policy.internet_protection[0].id, null)
}