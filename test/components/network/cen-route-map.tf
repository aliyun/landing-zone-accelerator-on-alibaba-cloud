# CEN Route Map for Shanghai
module "cen_route_map_shanghai" {
  source = "../../../components/network/cen-route-map"

  providers = {
    alicloud = alicloud.cen_sh
  }

  cen_id                        = module.cen_instance.cen_instance_id
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = module.cen_transit_router_sh.system_transit_router_route_table_id

  # Direct policy configuration in Terraform - VPC route filtering
  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 5
      map_result         = "Permit"
      description        = "Allow routes from specific VPCs with preference 100"

      # Match VPC routes
      source_child_instance_types = ["VPC"]
      route_types                 = ["System", "Custom"]

      # Set route preference
      preference = 100
    }
  ]

  # Load policy from file
  policy_file_paths = [
    "${path.module}/route-policies/shanghai-route-policy.yaml"
  ]

  policy_dir_paths = [
    "${path.module}/route-policies/shared",
    "${path.module}/route-policies/shanghai"
  ]
}

# CEN Route Map for Beijing
module "cen_route_map_beijing" {
  source = "../../../components/network/cen-route-map"

  providers = {
    alicloud = alicloud.cen_bj
  }

  cen_id                        = module.cen_instance.cen_instance_id
  tr_region_id                  = "cn-beijing"
  transit_router_route_table_id = module.cen_transit_router_bj.system_transit_router_route_table_id

  # Load policies from files and shared directory
  policy_file_paths = [
    "${path.module}/route-policies/beijing-route-policies.yaml"
  ]
  policy_dir_paths = ["${path.module}/route-policies/shared"]
}

output "route_map_ids_shanghai" {
  description = "The IDs of route map policies for Shanghai"
  value       = module.cen_route_map_shanghai.route_map_ids
}

output "route_maps_shanghai" {
  description = "Route map policy details for Shanghai"
  value       = module.cen_route_map_shanghai.route_maps
}

output "route_map_ids_beijing" {
  description = "The IDs of route map policies for Beijing"
  value       = module.cen_route_map_beijing.route_map_ids
}

output "route_maps_beijing" {
  description = "Route map policy details for Beijing"
  value       = module.cen_route_map_beijing.route_maps
}

