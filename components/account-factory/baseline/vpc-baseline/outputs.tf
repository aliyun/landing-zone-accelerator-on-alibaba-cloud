output "vpcs" {
  description = "Map of all created VPCs, keyed by vpc_name."
  value = {
    for vpc_name, vpc_module in module.vpc : vpc_name => {
      vpc_id      = vpc_module.vpc_id
      vswitch_ids = vpc_module.vswitch_ids
      vswitchs    = vpc_module.vswitchs
      vswitchs_by_name = {
        for vsw in vpc_module.vswitchs :
        vsw.vswitch_name => vsw
        if vsw.vswitch_name != null
      }
      route_table_id       = vpc_module.route_table_id
      cen_tr_attachment_id = try(module.cen_vpc_attach[vpc_name].transit_router_attachment_id, null)
      security_groups = {
        for key, sg_module in module.security_group :
        split(":", key)[1] => {
          security_group_id   = sg_module.security_group_id
          security_group_name = sg_module.security_group_name
        }
        if split(":", key)[0] == vpc_name
      }
    }
  }
}

output "vpc_ids" {
  description = "Map of VPC IDs, keyed by vpc_name."
  value = {
    for vpc_name, vpc_module in module.vpc :
    vpc_name => vpc_module.vpc_id
  }
}

output "cen_tr_attachment_ids" {
  description = "Map of CEN transit router attachment IDs, keyed by vpc_name. Null if attachment is not enabled for the VPC."
  value = {
    for vpc_name, vpc_module in module.vpc :
    vpc_name => try(module.cen_vpc_attach[vpc_name].transit_router_attachment_id, null)
  }
}

output "security_groups" {
  description = "Map of all created security groups, keyed by vpc_name:security_group_name."
  value = {
    for key, sg_module in module.security_group : key => {
      security_group_id   = sg_module.security_group_id
      security_group_name = sg_module.security_group_name
      vpc_id              = module.vpc[local.security_groups_map[key].vpc_name].vpc_id
    }
  }
}

