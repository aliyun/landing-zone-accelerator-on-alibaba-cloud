output "peer_attachment_id" {
  description = "The ID of the peer attachment."
  value       = alicloud_cen_transit_router_peer_attachment.peer_attachment.transit_router_attachment_id
}

output "tr_association_id" {
  description = "The ID of the route table association for Transit Router (if enabled)."
  value       = try(alicloud_cen_transit_router_route_table_association.tr_association[0].id, null)
}

output "peer_tr_association_id" {
  description = "The ID of the route table association for peer Transit Router (if enabled)."
  value       = try(alicloud_cen_transit_router_route_table_association.peer_tr_association[0].id, null)
}

output "tr_propagation_id" {
  description = "The ID of the route table propagation for Transit Router (if enabled)."
  value       = try(alicloud_cen_transit_router_route_table_propagation.tr_propagation[0].id, null)
}

output "peer_tr_propagation_id" {
  description = "The ID of the route table propagation for peer Transit Router (if enabled)."
  value       = try(alicloud_cen_transit_router_route_table_propagation.peer_tr_propagation[0].id, null)
}

output "tr_route_entries" {
  description = "List of route entries for Transit Router route table with IDs added."
  value = [
    for idx, entry in var.tr_route_entries : {
      destination_cidrblock = entry.destination_cidrblock
      name                  = entry.name
      description           = entry.description
      id                    = alicloud_cen_transit_router_route_entry.tr_route_entry[idx].transit_router_route_entry_id
    }
  ]
}

output "peer_tr_route_entries" {
  description = "List of route entries for peer Transit Router route table with IDs added."
  value = [
    for idx, entry in var.peer_tr_route_entries : {
      destination_cidrblock = entry.destination_cidrblock
      name                  = entry.name
      description           = entry.description
      id                    = alicloud_cen_transit_router_route_entry.peer_tr_route_entry[idx].transit_router_route_entry_id
    }
  ]
}
