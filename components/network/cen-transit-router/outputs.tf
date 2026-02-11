output "transit_router_id" {
  description = "The ID of the created Transit Router."
  value       = alicloud_cen_transit_router.transit_router.transit_router_id
}

output "transit_router_region_id" {
  description = "The region ID of the created Transit Router."
  value       = alicloud_cen_transit_router.transit_router.region_id
}

output "system_transit_router_route_table_id" {
  description = "The ID of the system transit router route table."
  value       = local.system_transit_router_route_table_id
}

output "transit_router_cidrs" {
  description = "List of Transit Router CIDR blocks with their details."
  value = [
    for cidr_config in var.transit_router_cidrs : {
      cidr                     = cidr_config.cidr
      description              = cidr_config.description
      publish_cidr_route       = cidr_config.publish_cidr_route
      transit_router_cidr_name = cidr_config.transit_router_cidr_name
      transit_router_cidr_id   = alicloud_cen_transit_router_cidr.transit_router_cidr[cidr_config.cidr].transit_router_cidr_id
    }
  ]
}

output "transit_router_cidr_ids" {
  description = "Map of CIDR blocks to their Transit Router CIDR IDs."
  value = {
    for cidr_config in var.transit_router_cidrs :
    cidr_config.cidr => alicloud_cen_transit_router_cidr.transit_router_cidr[cidr_config.cidr].transit_router_cidr_id
  }
}

