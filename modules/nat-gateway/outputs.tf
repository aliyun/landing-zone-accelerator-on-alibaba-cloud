output "nat_gateway_id" {
  description = "The ID of the nat gateway."
  value       = alicloud_nat_gateway.nat_gateway.id
}

output "nat_gateway_snat_entry_ids" {
  description = "The ID list of SNAT entries."
  value       = [for entry in alicloud_snat_entry.snat_entry : entry.id]
}

output "snat_entries" {
  description = "List of all SNAT entries with detailed information."
  value = [
    for entry in alicloud_snat_entry.snat_entry : {
      id                = entry.id
      snat_entry_id     = entry.snat_entry_id
      snat_ip           = entry.snat_ip
      source_cidr       = entry.source_cidr
      source_vswitch_id = entry.source_vswitch_id
      snat_entry_name   = entry.snat_entry_name
      eip_affinity      = entry.eip_affinity
      snat_table_id     = entry.snat_table_id
      status            = entry.status
    }
  ]
}
