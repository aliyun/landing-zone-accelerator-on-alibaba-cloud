output "vpc_id" {
  description = "The ID of the VPC."
  value       = alicloud_vpc.this.id
}

output "route_table_id" {
  description = "The ID of the VPC route table."
  value       = alicloud_vpc.this.route_table_id
}

output "vswitch_ids" {
  description = "List of all VSwitch IDs."
  value       = [for vsw in alicloud_vswitch.this : vsw.id]
}

output "vswitchs" {
  description = "List of all VSwitches with detailed information."
  value = [
    for vsw in alicloud_vswitch.this : {
      id              = vsw.id
      cidr_block      = vsw.cidr_block
      zone_id         = vsw.zone_id
      vswitch_name    = vsw.vswitch_name
      description     = vsw.description
      enable_ipv6     = vsw.enable_ipv6
      ipv6_cidr_block = vsw.ipv6_cidr_block
      status          = vsw.status
      tags            = vsw.tags
    }
  ]
}

output "network_acl_id" {
  description = "The ID of the VPC ACL (if enabled)."
  value       = var.enable_acl ? alicloud_network_acl.this[0].id : null
}

output "system_route_table_id" {
  description = "The ID of the system route table."
  value       = local.system_route_table_id
}
