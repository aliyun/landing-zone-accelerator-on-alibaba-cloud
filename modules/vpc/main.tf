# Create VPC
resource "alicloud_vpc" "this" {
  vpc_name          = var.vpc_name
  cidr_block        = var.vpc_cidr
  description       = var.vpc_description
  tags              = var.vpc_tags
  enable_ipv6       = var.enable_ipv6
  ipv6_isp          = var.ipv6_isp
  resource_group_id = var.resource_group_id
  user_cidrs        = var.user_cidrs
  ipv4_cidr_mask    = var.ipv4_cidr_mask
  ipv4_ipam_pool_id = var.ipv4_ipam_pool_id
  ipv6_cidr_block   = var.ipv6_cidr_block
}

# Create VSwitches
resource "alicloud_vswitch" "this" {
  for_each = {
    for vsw in var.vswitches :
    vsw.cidr_block => vsw
  }

  vpc_id               = alicloud_vpc.this.id
  cidr_block           = each.value.cidr_block
  zone_id              = each.value.zone_id
  vswitch_name         = try(each.value.vswitch_name, null)
  description          = try(each.value.description, null)
  enable_ipv6          = try(each.value.enable_ipv6, null)
  ipv6_cidr_block_mask = try(each.value.ipv6_cidr_block_mask, null)
  tags = (
    each.value.tags == null ? alicloud_vpc.this.tags :
    length(each.value.tags) == 0 ? alicloud_vpc.this.tags :
    each.value.tags
  )
}

# Create Network ACL (optional)
resource "alicloud_network_acl" "this" {
  count            = var.enable_acl ? 1 : 0
  vpc_id           = alicloud_vpc.this.id
  network_acl_name = var.acl_name != null ? var.acl_name : "${var.vpc_name}-acl"
  description      = var.acl_description
  tags             = var.acl_tags

  # Configure ingress ACL entries
  dynamic "ingress_acl_entries" {
    for_each = var.ingress_acl_entries
    content {
      entry_type             = "custom"
      policy                 = ingress_acl_entries.value.policy
      protocol               = ingress_acl_entries.value.protocol
      port                   = ingress_acl_entries.value.port
      source_cidr_ip         = ingress_acl_entries.value.source_cidr_ip
      description            = try(ingress_acl_entries.value.description, null)
      ip_version             = try(ingress_acl_entries.value.ip_version, null)
      network_acl_entry_name = try(ingress_acl_entries.value.network_acl_entry_name, null)
    }
  }

  # Configure egress ACL entries
  dynamic "egress_acl_entries" {
    for_each = var.egress_acl_entries
    content {
      entry_type             = "custom"
      policy                 = egress_acl_entries.value.policy
      protocol               = egress_acl_entries.value.protocol
      port                   = egress_acl_entries.value.port
      destination_cidr_ip    = egress_acl_entries.value.destination_cidr_ip
      description            = try(egress_acl_entries.value.description, null)
      ip_version             = try(egress_acl_entries.value.ip_version, null)
      network_acl_entry_name = try(egress_acl_entries.value.network_acl_entry_name, null)
    }
  }

  # Associate all VSwitches with the ACL
  dynamic "resources" {
    for_each = alicloud_vswitch.this
    content {
      resource_id   = resources.value.id
      resource_type = "VSwitch"
    }
  }
}

# Query system route table
data "alicloud_route_tables" "system_route_table" {
  vpc_id = alicloud_vpc.this.id
}

locals {
  system_route_table_id_list = [
    for rt in try(data.alicloud_route_tables.system_route_table.tables, []) : rt.id
    if rt.route_table_type == "System"
  ]
  system_route_table_id = try(local.system_route_table_id_list[0], null)
}
