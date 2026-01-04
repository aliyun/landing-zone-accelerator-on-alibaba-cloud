output "nat_gateway_snat_entry_id" {
  value = alicloud_snat_entry.snat.snat_entry_id
}

output "route_table_id" {
  value = local.route_table_id
}

output "dmz_route_table_id" {
  value = local.dmz_route_table_id
}

output "snat_table_id" {
  value = local.snat_table_id
}

output "eip_addresses" {
  value = local.eip_addresses
}
