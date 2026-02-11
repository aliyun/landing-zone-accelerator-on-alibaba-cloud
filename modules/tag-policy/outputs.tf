output "policy_ids" {
  description = "Map of policy names to their IDs"
  value = {
    for name, policy in alicloud_tag_policy.this : name => policy.id
  }
}

output "policy_names" {
  description = "List of created tag policy names"
  value       = [for policy in alicloud_tag_policy.this : policy.policy_name]
}

output "attachment_ids" {
  description = "List of policy attachment IDs"
  value       = [for attachment in alicloud_tag_policy_attachment.this : attachment.id]
}
