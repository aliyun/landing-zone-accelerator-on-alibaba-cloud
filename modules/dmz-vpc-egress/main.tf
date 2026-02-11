# Get VPC route tables
data "alicloud_route_tables" "route_table" {
  provider = alicloud.vpc
  vpc_id   = var.vpc_id
}

locals {
  vpc_route_table_id_list = [
    for rt in try(data.alicloud_route_tables.route_table.tables, []) : rt.id
    if rt.route_table_type == "System"
  ]
  # Use provided route_table_id if available, otherwise use system route table from data source
  vpc_route_table_id = try(var.vpc_route_table_id, null) != null ? var.vpc_route_table_id : try(local.vpc_route_table_id_list[0], null)
}

resource "alicloud_route_entry" "route_entry" {
  provider              = alicloud.vpc
  route_table_id        = local.vpc_route_table_id
  destination_cidrblock = var.vpc_route_entry_destination_cidrblock
  nexthop_type          = "Attachment"
  nexthop_id            = var.vpc_tr_attachment_id
}

# Configure DMZ VPC route table: route the egress VPC CIDR to the DMZ VPC transit router
data "alicloud_route_tables" "dmz_route_table" {
  provider = alicloud.dmz
  count    = var.dmz_route_table_id == null ? 1 : 0
  vpc_id   = var.dmz_vpc_id
}

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
  destination_cidrblock = var.vpc_cidr_block
  nexthop_type          = "Attachment"
  nexthop_id            = var.dmz_vpc_tr_attachment_id
}

# Configure NAT Gateway SNAT: add the VPC CIDR blocks that require Internet egress
data "alicloud_nat_gateways" "nat_gateway" {
  provider       = alicloud.dmz
  count          = try(length(var.dmz_eip_addresses), 0) == 0 || var.dmz_snat_table_id == null ? 1 : 0
  ids            = [var.dmz_nat_gateway_id]
  enable_details = false
}

# Extract EIP addresses and SNAT table ID
locals {
  dmz_data_eip_addresses = try(data.alicloud_nat_gateways.nat_gateway[0].gateways[0].ip_lists, [])
  dmz_data_snat_table_id = try(data.alicloud_nat_gateways.nat_gateway[0].gateways[0].snat_table_ids[0], "")
  dmz_eip_addresses      = try(length(var.dmz_eip_addresses), 0) == 0 ? local.dmz_data_eip_addresses : var.dmz_eip_addresses
  dmz_snat_table_id      = var.dmz_snat_table_id == null ? local.dmz_data_snat_table_id : var.dmz_snat_table_id
}

# Configure SNAT entry: add VPC CIDR blocks that require Internet egress
resource "alicloud_snat_entry" "snat" {
  provider      = alicloud.dmz
  snat_table_id = local.dmz_snat_table_id
  source_cidr   = var.vpc_cidr_block
  snat_ip       = join(",", local.dmz_eip_addresses)
}
