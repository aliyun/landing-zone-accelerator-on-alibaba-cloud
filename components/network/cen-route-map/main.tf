locals {
  # Direct policies from variable (add tr_region_id and transit_router_route_table_id)
  direct_policies = [
    for policy in var.route_policies : merge(policy, {
      tr_region_id                  = var.tr_region_id
      transit_router_route_table_id = var.transit_router_route_table_id
    })
  ]

  # Extract policies from files
  # File format: array of policy objects only
  file_policies = flatten([
    for filename, content in merge(
      # Files from policy_file_paths
      length(var.policy_file_paths) > 0 ? {
        for file in var.policy_file_paths : file => (
          endswith(file, ".yaml") || endswith(file, ".yml") ?
          yamldecode(file(file)) :
          jsondecode(file(file))
        )
      } : tomap({}),
      # Files from policy_dir_paths (multiple directories)
      length(var.policy_dir_paths) > 0 ? merge([
        for dir in var.policy_dir_paths : {
          for file in fileset(dir, "**/*.{json,yaml,yml}") : "${dir}/${file}" => (
            endswith(file, ".yaml") || endswith(file, ".yml") ?
            yamldecode(file("${dir}/${file}")) :
            jsondecode(file("${dir}/${file}"))
          )
        }
      ]...) : tomap({})
      ) : [
      # File content must be an array of policy objects
      for idx in range(length(content)) : merge(content[idx], {
        tr_region_id                  = var.tr_region_id
        transit_router_route_table_id = var.transit_router_route_table_id
      })
    ]
  ])

  # All policies combined
  all_policies = concat(local.direct_policies, local.file_policies)

  # Create a map for for_each, using unique key
  route_map_key_map = {
    for policy in local.all_policies :
    "${policy.transmit_direction}-${policy.priority}" => policy
  }
}

# Create CEN route maps
resource "alicloud_cen_route_map" "route_map" {
  for_each = local.route_map_key_map

  cen_id                        = var.cen_id
  cen_region_id                 = var.tr_region_id
  transmit_direction            = each.value.transmit_direction
  priority                      = each.value.priority
  map_result                    = each.value.map_result
  description                   = try(each.value.description, null)
  next_priority                 = try(each.value.next_priority, null)
  transit_router_route_table_id = try(each.value.transit_router_route_table_id, null)

  # Match conditions
  cidr_match_mode                        = try(each.value.cidr_match_mode, null)
  as_path_match_mode                     = try(each.value.as_path_match_mode, null)
  community_match_mode                   = try(each.value.community_match_mode, null)
  community_operate_mode                 = try(each.value.community_operate_mode, null)
  match_asns                             = try(each.value.match_asns, null)
  match_community_set                    = try(each.value.match_community_set, null)
  route_types                            = try(each.value.route_types, null)
  source_instance_ids                    = try(each.value.source_instance_ids, null)
  source_instance_ids_reverse_match      = try(each.value.source_instance_ids_reverse_match, null)
  source_route_table_ids                 = try(each.value.source_route_table_ids, null)
  source_region_ids                      = try(each.value.source_region_ids, null)
  source_child_instance_types            = try(each.value.source_child_instance_types, null)
  destination_instance_ids               = try(each.value.destination_instance_ids, null)
  destination_instance_ids_reverse_match = try(each.value.destination_instance_ids_reverse_match, null)
  destination_route_table_ids            = try(each.value.destination_route_table_ids, null)
  destination_child_instance_types       = try(each.value.destination_child_instance_types, null)
  destination_cidr_blocks                = try(each.value.destination_cidr_blocks, null)
  prepend_as_path                        = try(each.value.prepend_as_path, null)
  preference                             = try(each.value.preference, null)
  operate_community_set                  = try(each.value.operate_community_set, null)
}
