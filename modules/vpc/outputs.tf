output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_vpc.this.id
}

output "vswitch_ids" {
  description = "List of all VSwitch IDs."
  value       = [for vsw in alicloud_vswitch.this : vsw.id]
}

output "network_acl_id" {
  description = "The ID of the VPC ACL (if enabled)."
  value       = var.enable_acl ? alicloud_network_acl.this[0].id : null
}
