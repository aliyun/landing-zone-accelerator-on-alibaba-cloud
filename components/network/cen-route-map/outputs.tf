output "route_map_ids" {
  description = "List of all route map IDs (route_map_id)."
  value = [
    for rm in alicloud_cen_route_map.route_map : rm.route_map_id
  ]
}

output "route_maps" {
  description = "List of all route map details."
  value = [
    for rm in alicloud_cen_route_map.route_map : {
      id                            = rm.id
      route_map_id                  = rm.route_map_id
      cen_id                        = rm.cen_id
      tr_region_id                  = rm.cen_region_id
      transmit_direction            = rm.transmit_direction
      priority                      = rm.priority
      map_result                    = rm.map_result
      description                   = rm.description
      status                        = rm.status
      transit_router_route_table_id = rm.transit_router_route_table_id
    }
  ]
}
