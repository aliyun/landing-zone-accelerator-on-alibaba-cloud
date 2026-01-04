# Get VPC route tables
data "alicloud_route_tables" "route_table" {
  provider = alicloud.vpc
  count    = var.route_table_id == null ? 1 : 0
  vpc_id   = var.vpc_id
}

# Extract system route table ID
locals {
  route_table_id_list = [
    for rt in try(data.alicloud_route_tables.route_table[0].tables, []) : rt.id
    if rt.route_table_type == "System"
  ]
  route_table_id = try(local.route_table_id_list[0], null) == null ? var.route_table_id : local.route_table_id_list[0]
}

# Configure VPC route: route 0.0.0.0/0 to transit router
resource "alicloud_route_entry" "route_entry" {
  provider              = alicloud.vpc
  route_table_id        = local.route_table_id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "Attachment"
  nexthop_id            = var.vpc_tr_attachment_id
}

# Get DMZ VPC route tables
data "alicloud_route_tables" "dmz_route_table" {
  provider = alicloud.dmz
  count    = var.dmz_route_table_id == null ? 1 : 0
  vpc_id   = var.dmz_vpc_id
}

# Extract DMZ system route table ID
locals {
  dmz_route_table_id_list = [
    for rt in try(data.alicloud_route_tables.dmz_route_table[0].tables, []) : rt.id
    if rt.route_table_type == "System"
  ]
  dmz_route_table_id = try(local.dmz_route_table_id_list[0], null) == null ? var.dmz_route_table_id : local.dmz_route_table_id_list[0]
}

# Configure DMZ VPC route: route egress VPC CIDR to DMZ transit router
resource "alicloud_route_entry" "dmz_route_entry" {
  provider              = alicloud.dmz
  route_table_id        = local.dmz_route_table_id
  destination_cidrblock = var.cidr_block
  nexthop_type          = "Attachment"
  nexthop_id            = var.dmz_vpc_tr_attachment_id
}

# Get NAT Gateway information
data "alicloud_nat_gateways" "nat_gateway" {
  provider       = alicloud.dmz
  count          = try(length(var.eip_addresses), 0) == 0 || var.snat_table_id == null ? 1 : 0
  ids            = [var.nat_gateway_id]
  enable_details = false
}

# Extract EIP addresses and SNAT table ID
locals {
  data_eip_addresses = try(data.alicloud_nat_gateways.nat_gateway[0].gateways[0].ip_lists, [])
  data_snat_table_id = try(data.alicloud_nat_gateways.nat_gateway[0].gateways[0].snat_table_ids[0], "")
  eip_addresses      = try(length(var.eip_addresses), 0) == 0 ? local.data_eip_addresses : var.eip_addresses
  snat_table_id      = var.snat_table_id == null ? local.data_snat_table_id : var.snat_table_id
}

# Configure SNAT entry: add VPC CIDR blocks that require Internet egress
resource "alicloud_snat_entry" "snat" {
  provider      = alicloud.dmz
  snat_table_id = local.snat_table_id
  source_cidr   = var.cidr_block
  snat_ip       = join(",", local.eip_addresses)
}
