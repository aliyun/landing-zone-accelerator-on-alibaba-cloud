resource "alicloud_cen_transit_router" "transit_router" {
  cen_id                     = var.cen_instance_id
  transit_router_name        = var.transit_router_name
  transit_router_description = var.transit_router_description
  tags                       = var.transit_router_tags
}

data "alicloud_cen_transit_router_route_tables" "route_table" {
  transit_router_id = alicloud_cen_transit_router.transit_router.transit_router_id
}

locals {
  system_transit_router_route_tables = [
    for table in data.alicloud_cen_transit_router_route_tables.route_table.tables : table.transit_router_route_table_id
    if table.transit_router_route_table_type == "System"
  ]
  system_transit_router_route_table_id = try(local.system_transit_router_route_tables[0], "")
}

resource "alicloud_cen_transit_router_cidr" "transit_router_cidr" {
  for_each = {
    for cidr_config in var.transit_router_cidrs : cidr_config.cidr => cidr_config
  }

  transit_router_id        = alicloud_cen_transit_router.transit_router.transit_router_id
  cidr                     = each.value.cidr
  description              = each.value.description
  publish_cidr_route       = each.value.publish_cidr_route
  transit_router_cidr_name = each.value.transit_router_cidr_name
}

