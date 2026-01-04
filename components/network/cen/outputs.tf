output "cen_instance_id" {
  description = "The ID of the created CEN instance."
  value       = alicloud_cen_instance.cen.id
}

output "transit_router_id" {
  description = "The ID of the created Transit Router."
  value       = alicloud_cen_transit_router.cen_tr.transit_router_id
}

output "system_transit_router_route_table_id" {
  description = "The ID of the system transit router route table."
  value       = local.system_transit_router_route_table_id
}

