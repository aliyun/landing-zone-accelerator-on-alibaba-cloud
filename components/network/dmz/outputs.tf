output "dmz_vpc_id" {
  value = module.dmz_vpc.vpc_id
}

output "dmz_route_table_id" {
  value = module.dmz_vpc.route_table_id
}

output "nat_gateway_id" {
  value = module.dmz_nat_gateway.nat_gateway_id
}

output "dmz_vswitch" {
  value = [
    for vsw in var.dmz_vswitch : {
      zone_id      = local.vswitches_by_cidr[vsw.vswitch_cidr].zone_id
      cidr_block   = vsw.vswitch_cidr
      vswitch_id   = local.vswitches_by_cidr[vsw.vswitch_cidr].id
      vswitch_name = vsw.vswitch_name
      purpose      = try(vsw.purpose, null)
    }
  ]
}

output "dmz_vswitch_for_tr" {
  value = [
    for vsw in local.vswitches_for_tr : {
      zone_id      = local.vswitches_by_cidr[vsw.vswitch_cidr].zone_id
      cidr_block   = vsw.vswitch_cidr
      vswitch_id   = local.vswitches_by_cidr[vsw.vswitch_cidr].id
      vswitch_name = vsw.vswitch_name
    }
  ]
}

output "dmz_vswitch_for_nat_gateway" {
  value = {
    zone_id      = local.vswitches_by_cidr[local.vswitch_for_nat_gateway.vswitch_cidr].zone_id
    cidr_block   = local.vswitch_for_nat_gateway.vswitch_cidr
    vswitch_id   = local.vswitches_by_cidr[local.vswitch_for_nat_gateway.vswitch_cidr].id
    vswitch_name = local.vswitch_for_nat_gateway.vswitch_name
  }
}

output "transit_router_vpc_attachment_id" {
  value = module.dmz_vpc_attach_to_cen.transit_router_attachment_id
}

output "eip_instances" {
  value = module.dmz_eip.eip_instances
}

output "eip_ids" {
  value = module.dmz_eip.eip_ids
}

output "eip_ips" {
  value = module.dmz_eip.eip_ips
}

output "common_bandwidth_package_id" {
  value = var.dmz_enable_common_bandwidth_package ? module.dmz_common_bandwidth_package[0].bandwidth_package_id : null
}
