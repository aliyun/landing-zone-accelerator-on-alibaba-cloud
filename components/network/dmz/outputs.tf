output "dmz_vpc_id" {
  value = alicloud_vpc.dmz_vpc.id
}

output "dmz_route_table_id" {
  value = alicloud_vpc.dmz_vpc.route_table_id
}

output "nat_gateway_id" {
  value = module.dmz_nat_gateway.nat_gateway_id
}

output "dmz_vswitch_for_tr" {
  value = [
    for vsw in alicloud_vswitch.dmz_vswitch_for_tr : {
      zone_id    = vsw.availability_zone
      cidr_block = vsw.cidr_block
      vswitch_id = vsw.id
    }
  ]
}

output "dmz_vswitch_for_nat_gateway" {
  value = [
    {
      zone_id    = alicloud_vswitch.dmz_vswitch_for_nat_gateway.zone_id
      cidr_block = alicloud_vswitch.dmz_vswitch_for_nat_gateway.cidr_block
      vswitch_id = alicloud_vswitch.dmz_vswitch_for_nat_gateway.id
    }
  ]
}

output "dmz_vswitch" {
  value = [
    for vsw in alicloud_vswitch.dmz_vswitch : {
      zone_id    = vsw.availability_zone
      cidr_block = vsw.cidr_block
      vswitch_id = vsw.id
    }
  ]
}

output "transit_router_vpc_attachment_id" {
  value = module.dmz_vpc_attach_to_cen.transit_router_attachment_id
}

output "transit_router_outbound_route_entry_id" {
  value = alicloud_cen_transit_router_route_entry.dmz_vpc_outbound.transit_router_route_entry_id
}

output "eip_instances" {
  value = module.dmz_eip.eip_instances
}

output "common_bandwidth_package_id" {
  value = module.dmz_eip.common_bandwidth_package_id
}
