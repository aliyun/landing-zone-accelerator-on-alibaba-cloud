
# Create peer attachment for cross-region connectivity
resource "alicloud_cen_transit_router_peer_attachment" "peer_attachment" {
  provider = alicloud.cen_tr

  cen_id                                = var.cen_instance_id
  transit_router_id                     = var.transit_router_id
  peer_transit_router_id                = var.peer_transit_router_id
  peer_transit_router_region_id         = var.peer_transit_router_region_id
  transit_router_peer_attachment_name   = var.transit_router_peer_attachment_name
  transit_router_attachment_description = var.transit_router_attachment_description
  bandwidth                             = var.bandwidth
  bandwidth_type                        = var.bandwidth_type
  cen_bandwidth_package_id              = var.cen_bandwidth_package_id
  default_link_type                     = var.default_link_type
  auto_publish_route_enabled            = var.auto_publish_route_enabled
  tags                                  = var.tags

  timeouts {
    create = "10m"
    update = "10m"
    delete = "20m"
  }
}

# Route table association for TR
resource "alicloud_cen_transit_router_route_table_association" "tr_association" {
  count = var.tr_route_table_association_enabled ? 1 : 0

  provider                      = alicloud.cen_tr
  transit_router_route_table_id = var.tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# Route table association for peer TR
resource "alicloud_cen_transit_router_route_table_association" "peer_tr_association" {
  count = var.peer_tr_route_table_association_enabled ? 1 : 0

  provider                      = alicloud.cen_peer_tr
  transit_router_route_table_id = var.peer_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# Route table propagation for TR
resource "alicloud_cen_transit_router_route_table_propagation" "tr_propagation" {
  count = var.tr_route_table_propagation_enabled ? 1 : 0

  provider                      = alicloud.cen_tr
  transit_router_route_table_id = var.tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# Route table propagation for peer TR
resource "alicloud_cen_transit_router_route_table_propagation" "peer_tr_propagation" {
  count = var.peer_tr_route_table_propagation_enabled ? 1 : 0

  provider                      = alicloud.cen_peer_tr
  transit_router_route_table_id = var.peer_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

# Route entries for TR route table
resource "alicloud_cen_transit_router_route_entry" "tr_route_entry" {
  count = length(var.tr_route_entries)

  provider = alicloud.cen_tr

  transit_router_route_table_id                     = var.tr_route_table_id
  transit_router_route_entry_destination_cidr_block = var.tr_route_entries[count.index].destination_cidrblock
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
  transit_router_route_entry_name                   = try(var.tr_route_entries[count.index].name, null)
  transit_router_route_entry_description            = try(var.tr_route_entries[count.index].description, null)
}

# Route entries for peer TR route table
resource "alicloud_cen_transit_router_route_entry" "peer_tr_route_entry" {
  count = length(var.peer_tr_route_entries)

  provider = alicloud.cen_peer_tr

  transit_router_route_table_id                     = var.peer_tr_route_table_id
  transit_router_route_entry_destination_cidr_block = var.peer_tr_route_entries[count.index].destination_cidrblock
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_next_hop_id            = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
  transit_router_route_entry_name                   = try(var.peer_tr_route_entries[count.index].name, null)
  transit_router_route_entry_description            = try(var.peer_tr_route_entries[count.index].description, null)
}
