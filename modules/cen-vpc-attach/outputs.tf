output "transit_router_attachment_id" {
  description = "The ID of the CEN transit router VPC attachment"
  value       = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
}

output "route_table_association_id" {
  description = "The ID of the route table association resource (if enabled)"
  value       = try(alicloud_cen_transit_router_route_table_association.route_table_association[0].id, null)
}

output "route_table_propagation_id" {
  description = "The ID of the route table propagation resource (if enabled)"
  value       = try(alicloud_cen_transit_router_route_table_propagation.route_table_propagation[0].id, null)
}

