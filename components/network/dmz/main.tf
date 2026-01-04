# Create DMZ VPC
resource "alicloud_vpc" "dmz_vpc" {
  provider    = alicloud.dmz
  vpc_name    = var.dmz_vpc_name
  cidr_block  = var.dmz_vpc_cidr
  description = var.dmz_vpc_description
  tags        = var.dmz_vpc_tags
}

# Create VSwitches for Transit Router
resource "alicloud_vswitch" "dmz_vswitch_for_tr" {
  provider = alicloud.dmz
  for_each = {
    for idx, vsw in var.dmz_vswitch_for_tr : idx => vsw
  }

  vpc_id       = alicloud_vpc.dmz_vpc.id
  cidr_block   = each.value.vswitch_cidr
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
  description  = each.value.vswitch_description
  tags         = try(each.value.tags, null)
}

# Create VSwitch for NAT Gateway
resource "alicloud_vswitch" "dmz_vswitch_for_nat_gateway" {
  provider     = alicloud.dmz
  vpc_id       = alicloud_vpc.dmz_vpc.id
  cidr_block   = var.dmz_vswitch_for_nat_gateway.vswitch_cidr
  zone_id      = var.dmz_vswitch_for_nat_gateway.zone_id
  vswitch_name = var.dmz_vswitch_for_nat_gateway.vswitch_name
  description  = var.dmz_vswitch_for_nat_gateway.vswitch_description
  tags         = try(var.dmz_vswitch_for_nat_gateway.tags, null)
}

# Create additional VSwitches for DMZ
resource "alicloud_vswitch" "dmz_vswitch" {
  provider = alicloud.dmz
  for_each = {
    for idx, vsw in var.dmz_vswitch : idx => vsw
  }

  vpc_id       = alicloud_vpc.dmz_vpc.id
  cidr_block   = each.value.vswitch_cidr
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
  description  = each.value.vswitch_description
  tags         = try(each.value.tags, null)
}

# Create EIP instances for NAT Gateway
module "dmz_eip" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/eip"

  eip_instances                                 = var.dmz_egress_eip_instances
  enable_common_bandwidth_package               = var.dmz_enable_common_bandwidth_package
  common_bandwidth_package_name                 = var.dmz_common_bandwidth_package_name
  common_bandwidth_package_bandwidth            = tostring(var.dmz_common_bandwidth_package_bandwidth)
  common_bandwidth_package_internet_charge_type = var.dmz_common_bandwidth_package_internet_charge_type
  common_bandwidth_package_ratio                = var.dmz_common_bandwidth_package_ratio
}

# Create NAT Gateway for DMZ VPC
module "dmz_nat_gateway" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/nat-gateway"

  vpc_id              = alicloud_vpc.dmz_vpc.id
  nat_gateway_name    = var.dmz_egress_nat_gateway_name
  vswitch_id          = alicloud_vswitch.dmz_vswitch_for_nat_gateway.id
  association_eip_ids = [for e in module.dmz_eip.eip_instances : e.id]
  snat_entries        = []
  tags                = var.dmz_egress_nat_gateway_tags
}

# Attach DMZ VPC to CEN Transit Router
module "dmz_vpc_attach_to_cen" {
  providers = {
    alicloud.cen = alicloud.cen
    alicloud.vpc = alicloud.dmz
  }
  source = "../../../modules/cen-vpc-attach"

  cen_instance_id                       = var.cen_instance_id
  cen_transit_router_id                 = var.cen_transit_router_id
  transit_router_route_table_id         = var.transit_router_route_table_id
  transit_router_attachment_name        = var.dmz_tr_attachment_name
  transit_router_attachment_description = var.dmz_tr_attachment_description
  vpc_id                                = alicloud_vpc.dmz_vpc.id
  primary_vswitch = {
    vswitch_id = alicloud_vswitch.dmz_vswitch_for_tr[0].id
    zone_id    = alicloud_vswitch.dmz_vswitch_for_tr[0].availability_zone
  }
  secondary_vswitch = {
    vswitch_id = alicloud_vswitch.dmz_vswitch_for_tr[1].id
    zone_id    = alicloud_vswitch.dmz_vswitch_for_tr[1].availability_zone
  }
  route_table_association_enabled = true
  route_table_propagation_enabled = true
}

# Configure DMZ VPC outbound route: route 0.0.0.0/0 to DMZ VPC attachment
resource "alicloud_cen_transit_router_route_entry" "dmz_vpc_outbound" {
  provider = alicloud.cen

  transit_router_route_table_id                     = var.transit_router_route_table_id
  transit_router_route_entry_destination_cidr_block = "0.0.0.0/0"
  transit_router_route_entry_next_hop_type          = "Attachment"
  transit_router_route_entry_name                   = var.dmz_outbound_route_entry_name
  transit_router_route_entry_description            = var.dmz_outbound_route_entry_description
  transit_router_route_entry_next_hop_id            = module.dmz_vpc_attach_to_cen.transit_router_attachment_id
}
