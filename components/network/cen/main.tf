# Enable CEN Transit Router service
data "alicloud_cen_transit_router_service" "enable" {
  enable = "On"
}

# Create CEN instance
resource "alicloud_cen_instance" "cen" {
  cen_instance_name = var.cen_instance_name
  description       = var.cen_instance_description
  tags              = var.cen_instance_tags

  depends_on = [
    data.alicloud_cen_transit_router_service.enable
  ]
}

# Create CEN Transit Router
resource "alicloud_cen_transit_router" "cen_tr" {
  cen_id                     = alicloud_cen_instance.cen.id
  transit_router_name        = var.transit_router_name
  transit_router_description = var.transit_router_description
  tags                       = var.transit_router_tags
}

# Get Transit Router route tables
data "alicloud_cen_transit_router_route_tables" "route_table" {
  transit_router_id = alicloud_cen_transit_router.cen_tr.transit_router_id
}

# Extract system route table ID from route tables
locals {
  system_transit_router_route_tables = [
    for table in data.alicloud_cen_transit_router_route_tables.route_table.tables : table.transit_router_route_table_id
    if table.transit_router_route_table_type == "System"
  ]
  system_transit_router_route_table_id = try(local.system_transit_router_route_tables[0], "")
}
