locals {
  # Vswitches for Transit Router attachment
  vswitches_for_tr = [
    for vsw in var.dmz_vswitch : vsw
    if try(vsw.purpose, null) == "TR"
  ]

  # Vswitch for NAT Gateway (must exist, validated in variables)
  vswitch_for_nat_gateway = [
    for vsw in var.dmz_vswitch : vsw
    if try(vsw.purpose, null) == "NATGW"
  ][0]
}

module "dmz_vpc" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/vpc"

  vpc_name        = var.dmz_vpc_name
  vpc_cidr        = var.dmz_vpc_cidr
  vpc_description = var.dmz_vpc_description
  vpc_tags        = var.dmz_vpc_tags
  vswitches = [
    for vsw in var.dmz_vswitch : {
      cidr_block   = vsw.vswitch_cidr
      zone_id      = vsw.zone_id
      vswitch_name = vsw.vswitch_name
      description  = vsw.vswitch_description
      tags         = try(vsw.tags, null)
    }
  ]
}

locals {
  vswitches_by_cidr = {
    for vsw in module.dmz_vpc.vswitchs : vsw.cidr_block => vsw
  }
}

# Create EIP instances which will be attached to NAT Gateway.
module "dmz_eip" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/eip"

  eip_instances = var.dmz_egress_eip_instances
}

# Create common bandwidth package for EIP instances (optional)
module "dmz_common_bandwidth_package" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/common-bandwidth-package"
  count  = var.dmz_enable_common_bandwidth_package ? 1 : 0

  bandwidth                 = tostring(var.dmz_common_bandwidth_package_bandwidth)
  internet_charge_type      = var.dmz_common_bandwidth_package_internet_charge_type
  bandwidth_package_name    = var.dmz_common_bandwidth_package_name
  ratio                     = var.dmz_common_bandwidth_package_ratio
  deletion_protection       = var.dmz_common_bandwidth_package_deletion_protection
  description               = var.dmz_common_bandwidth_package_description
  isp                       = var.dmz_common_bandwidth_package_isp
  resource_group_id         = var.dmz_common_bandwidth_package_resource_group_id
  security_protection_types = var.dmz_common_bandwidth_package_security_protection_types
  tags                      = var.dmz_common_bandwidth_package_tags
  eip_attachments = [
    for id in module.dmz_eip.eip_ids : {
      instance_id = id
    }
  ]
}

locals {
  # Prepare SNAT entries with EIP IPs
  dmz_nat_gateway_snat_entries_with_ips = [
    for entry in var.dmz_nat_gateway_snat_entries : {
      source_cidr     = entry.source_cidr
      snat_ips        = module.dmz_eip.eip_ips
      snat_entry_name = try(entry.snat_entry_name, null)
      eip_affinity    = try(entry.eip_affinity, 0)
    }
  ]
}

module "dmz_nat_gateway" {
  providers = {
    alicloud = alicloud.dmz
  }
  source = "../../../modules/nat-gateway"

  vpc_id               = module.dmz_vpc.vpc_id
  nat_gateway_name     = var.dmz_egress_nat_gateway_name
  description          = var.dmz_egress_nat_gateway_description
  vswitch_id           = local.vswitches_by_cidr[local.vswitch_for_nat_gateway.vswitch_cidr].id
  network_type         = "internet"
  association_eip_ids  = module.dmz_eip.eip_ids
  snat_entries         = local.dmz_nat_gateway_snat_entries_with_ips
  tags                 = var.dmz_egress_nat_gateway_tags
  deletion_protection  = var.dmz_egress_nat_gateway_deletion_protection
  eip_bind_mode        = var.dmz_egress_nat_gateway_eip_bind_mode
  icmp_reply_enabled   = var.dmz_egress_nat_gateway_icmp_reply_enabled
  private_link_enabled = var.dmz_egress_nat_gateway_private_link_enabled
  access_mode          = var.dmz_egress_nat_gateway_access_mode
}

module "dmz_vpc_attach_to_cen" {
  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.dmz
  }
  source = "../../../modules/cen-vpc-attach"

  cen_instance_id               = var.cen_instance_id
  cen_tr_id                     = var.cen_transit_router_id
  cen_tr_route_table_id         = var.transit_router_route_table_id
  cen_tr_attachment_name        = var.dmz_tr_attachment_name
  cen_tr_attachment_description = var.dmz_tr_attachment_description
  vpc_id                        = module.dmz_vpc.vpc_id
  vpc_attachment_vswitches = [
    for vsw in local.vswitches_for_tr : {
      vswitch_id = local.vswitches_by_cidr[vsw.vswitch_cidr].id
      zone_id    = local.vswitches_by_cidr[vsw.vswitch_cidr].zone_id
    }
  ]
  cen_tr_route_table_association_enabled       = var.dmz_tr_route_table_association_enabled
  cen_tr_route_table_propagation_enabled       = var.dmz_tr_route_table_propagation_enabled
  cen_tr_attachment_force_delete               = var.dmz_tr_attachment_force_delete
  cen_tr_attachment_tags                       = var.dmz_tr_attachment_tags
  cen_tr_attachment_options                    = var.dmz_tr_attachment_options
  vpc_route_table_id                           = module.dmz_vpc.system_route_table_id
  vpc_route_entries                            = var.dmz_vpc_route_entries
  cen_service_linked_role_exists               = var.cen_service_linked_role_exists
  create_cen_instance_grant                    = var.create_cen_instance_grant
  cen_tr_attachment_auto_publish_route_enabled = var.dmz_tr_attachment_auto_publish_route_enabled
}

# Create CEN route entries to publish routes to CEN route tables
resource "alicloud_cen_route_entry" "dmz_cen_route_entries" {
  for_each = {
    for cidr_block in var.cen_route_entry_cidr_blocks : cidr_block => cidr_block
  }

  provider       = alicloud.cen_tr
  instance_id    = var.cen_instance_id
  route_table_id = module.dmz_vpc.system_route_table_id
  cidr_block     = each.value

  depends_on = [
    module.dmz_nat_gateway,
    module.dmz_vpc_attach_to_cen
  ]
}

