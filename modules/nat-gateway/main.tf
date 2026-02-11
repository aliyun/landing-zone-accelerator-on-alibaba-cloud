# Create NAT Gateway
resource "alicloud_nat_gateway" "nat_gateway" {
  vpc_id               = var.vpc_id
  nat_gateway_name     = var.nat_gateway_name
  description          = var.description
  force                = var.force
  vswitch_id           = var.vswitch_id
  network_type         = var.network_type
  tags                 = var.tags
  deletion_protection  = var.deletion_protection
  eip_bind_mode        = var.eip_bind_mode
  icmp_reply_enabled   = var.icmp_reply_enabled
  private_link_enabled = var.private_link_enabled
  nat_type             = "Enhanced"

  dynamic "access_mode" {
    for_each = var.access_mode
    content {
      mode_value  = access_mode.value.mode_value
      tunnel_type = try(access_mode.value.tunnel_type, null)
    }
  }
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
  for_each = {
    for entry in var.snat_entries :
    "${entry.source_cidr != null ? entry.source_cidr : ""}:${entry.source_vswitch_id != null ? entry.source_vswitch_id : ""}" => entry
  }

  snat_ip           = each.value.use_all_associated_eips ? join(",", data.alicloud_eip_addresses.associated_eips[0].addresses[*].ip_address) : join(",", each.value.snat_ips)
  source_cidr       = try(each.value.source_cidr, null)
  source_vswitch_id = try(each.value.source_vswitch_id, null)
  snat_entry_name   = each.value.snat_entry_name
  eip_affinity      = each.value.eip_affinity
  snat_table_id     = alicloud_nat_gateway.nat_gateway.snat_table_ids
}

