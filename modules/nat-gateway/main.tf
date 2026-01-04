# Create NAT Gateway
resource "alicloud_nat_gateway" "nat_gateway" {
  nat_type         = "Enhanced"
  vpc_id           = var.vpc_id
  nat_gateway_name = var.nat_gateway_name
  vswitch_id       = var.vswitch_id
  network_type     = var.network_type
  payment_type     = var.payment_type
  period           = var.period
  tags             = var.tags
}

# Associate EIPs with NAT Gateway
resource "alicloud_eip_association" "eip_association" {
  count = length(var.association_eip_ids)

  allocation_id = var.association_eip_ids[count.index]
  instance_id   = alicloud_nat_gateway.nat_gateway.id
}

# Get associated EIP addresses when use_all_associated_eips is true
data "alicloud_eip_addresses" "associated_eips" {
  count = anytrue([for entry in var.snat_entries : entry.use_all_associated_eips]) ? 1 : 0
  ids   = var.association_eip_ids
}

# Create SNAT entries
resource "alicloud_snat_entry" "snat_entry" {
  count = length(var.snat_entries)

  snat_ip           = var.snat_entries[count.index].use_all_associated_eips ? join(",", data.alicloud_eip_addresses.associated_eips[0].addresses[*].ip_address) : join(",", var.snat_entries[count.index].snat_ips)
  source_cidr       = try(var.snat_entries[count.index].source_cidr, null)
  source_vswitch_id = try(var.snat_entries[count.index].source_vswitch_id, null)
  snat_entry_name   = var.snat_entries[count.index].snat_entry_name
  eip_affinity      = var.snat_entries[count.index].eip_affinity
  snat_table_id     = alicloud_nat_gateway.nat_gateway.snat_table_ids
}

