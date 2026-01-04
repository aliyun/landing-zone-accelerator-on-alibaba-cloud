# Provider configuration
provider "alicloud" {
  region = "cn-hangzhou"
}

# Test CEN component
module "cen" {
  source = "../../../../components/network/cen"

  # CEN instance configuration
  cen_instance_name        = "lz-cen"
  cen_instance_description = "Landing Zone CEN for tests"
  cen_instance_tags = {
    env     = "test"
    project = "landing-zone"
  }

  # Transit Router configuration
  transit_router_name        = "lz-tr"
  transit_router_description = "Landing Zone Transit Router for tests"
  transit_router_tags = {
    env     = "test"
    project = "landing-zone"
  }
}

output "cen_instance_id" {
  value = module.cen.cen_instance_id
}

output "transit_router_id" {
  value = module.cen.transit_router_id
}

output "system_transit_router_route_table_id" {
  value = module.cen.system_transit_router_route_table_id
}
