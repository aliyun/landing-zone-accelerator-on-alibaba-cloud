locals {
  # Extract VPCs from directory files
  # Each file contains a single VPC object
  vpc_config_files = var.vpc_dir_path != null ? fileset(var.vpc_dir_path, "**/*.{json,yaml,yml}") : []

  file_vpcs = [
    for file in local.vpc_config_files : (
      endswith(file, ".yaml") || endswith(file, ".yml") ?
      yamldecode(file("${var.vpc_dir_path}/${file}")) :
      jsondecode(file("${var.vpc_dir_path}/${file}"))
    )
  ]

  # All VPCs combined (direct + from files)
  all_vpcs = concat(var.vpcs, local.file_vpcs)

  # Create a map of VPCs keyed by vpc_name for for_each
  vpcs_map = {
    for vpc in local.all_vpcs :
    vpc.vpc_name => vpc
  }
}

# Create VPCs using for_each
module "vpc" {
  for_each = local.vpcs_map
  source   = "../../../../modules/vpc"

  providers = {
    alicloud = alicloud.vpc
  }

  vpc_name          = each.value.vpc_name
  vpc_cidr          = each.value.vpc_cidr
  vpc_description   = try(each.value.vpc_description, null)
  enable_ipv6       = try(each.value.enable_ipv6, false)
  ipv6_isp          = try(each.value.ipv6_isp, "BGP")
  resource_group_id = try(each.value.resource_group_id, null)
  user_cidrs        = try(each.value.user_cidrs, [])
  ipv4_cidr_mask    = try(each.value.ipv4_cidr_mask, null)
  ipv4_ipam_pool_id = try(each.value.ipv4_ipam_pool_id, null)
  ipv6_cidr_block   = try(each.value.ipv6_cidr_block, null)
  vpc_tags          = try(each.value.vpc_tags, {})

  vswitches           = each.value.vswitches
  enable_acl          = try(each.value.enable_acl, false)
  acl_name            = try(each.value.acl_name, null)
  acl_description     = try(each.value.acl_description, null)
  acl_tags            = try(each.value.acl_tags, {})
  ingress_acl_entries = try(each.value.ingress_acl_entries, [])
  egress_acl_entries  = try(each.value.egress_acl_entries, [])
}

# Prepare CEN VPC attachment vswitches for each VPC
# Use vswitches with purpose="TR" to identify vswitches for Transit Router attachment
locals {
  # Map vswitches by CIDR for quick lookup
  vswitches_by_cidr = {
    for vpc_name, vpc_module in module.vpc :
    vpc_name => {
      for vsw in vpc_module.vswitchs :
      vsw.cidr_block => vsw
    }
  }

  # Filter vswitches with purpose="TR" for each VPC
  tr_vswitches = {
    for vpc_name, vpc in local.vpcs_map :
    vpc_name => [for vsw in vpc.vswitches : vsw if try(vsw.purpose, null) == "TR"]
  }

  # Prepare CEN VPC attachment vswitches
  cen_vpc_attachment_vswitches = {
    for vpc_name, vpc in local.vpcs_map :
    vpc_name => try(vpc.cen_attachment.enabled, false) ? [
      for tr_vsw_config in local.tr_vswitches[vpc_name] : {
        vswitch_id = local.vswitches_by_cidr[vpc_name][tr_vsw_config.cidr_block].id
        zone_id    = local.vswitches_by_cidr[vpc_name][tr_vsw_config.cidr_block].zone_id
      }
    ] : []
  }
}

# Create CEN VPC attachments using for_each
module "cen_vpc_attach" {
  for_each = {
    for vpc_name, vpc in local.vpcs_map :
    vpc_name => vpc
    if try(vpc.cen_attachment.enabled, false)
  }
  source = "../../../../modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  # Common CEN configuration (from top-level variables)
  cen_instance_id       = var.cen_instance_id
  cen_tr_id             = var.cen_tr_id
  cen_tr_route_table_id = var.cen_tr_route_table_id

  # CEN service-linked role configuration
  cen_service_linked_role_exists = var.cen_service_linked_role_exists

  # CEN instance grant configuration
  create_cen_instance_grant = var.create_cen_instance_grant

  # VPC-specific CEN attachment configuration
  cen_tr_attachment_name                       = try(each.value.cen_attachment.cen_tr_attachment_name, "")
  cen_tr_attachment_description                = try(each.value.cen_attachment.cen_tr_attachment_description, "")
  cen_tr_route_table_association_enabled       = try(each.value.cen_attachment.cen_tr_route_table_association_enabled, true)
  cen_tr_route_table_propagation_enabled       = try(each.value.cen_attachment.cen_tr_route_table_propagation_enabled, true)
  cen_tr_attachment_auto_publish_route_enabled = try(each.value.cen_attachment.cen_tr_attachment_auto_publish_route_enabled, false)
  cen_tr_attachment_force_delete               = try(each.value.cen_attachment.cen_tr_attachment_force_delete, false)
  cen_tr_attachment_payment_type               = try(each.value.cen_attachment.cen_tr_attachment_payment_type, "PayAsYouGo")
  cen_tr_attachment_tags                       = try(each.value.cen_attachment.cen_tr_attachment_tags, {})
  cen_tr_attachment_options                    = try(each.value.cen_attachment.cen_tr_attachment_options, { "ipv6Support" = "disable" })
  cen_tr_attachment_resource_type              = try(each.value.cen_attachment.cen_tr_attachment_resource_type, "VPC")

  vpc_id = module.vpc[each.key].vpc_id

  vpc_attachment_vswitches = local.cen_vpc_attachment_vswitches[each.key]
  vpc_route_table_id       = module.vpc[each.key].system_route_table_id
  vpc_route_entries        = try(each.value.cen_attachment.vpc_route_entries, [])
}

# Prepare security groups for each VPC
locals {
  # Create a map of security groups for each VPC
  # Key: "${vpc_name}:${security_group_name}"
  security_groups_map = merge([
    for vpc_name, vpc in local.vpcs_map :
    {
      for sg in try(vpc.security_groups, []) :
      "${vpc_name}:${sg.security_group_name}" => {
        vpc_name = vpc_name
        sg       = sg
      }
    }
  ]...)
}

# Create security groups for each VPC
module "security_group" {
  for_each = local.security_groups_map
  source   = "../../../../modules/security-group"

  providers = {
    alicloud = alicloud.vpc
  }

  vpc_id              = module.vpc[each.value.vpc_name].vpc_id
  security_group_name = each.value.sg.security_group_name
  description         = try(each.value.sg.description, null)
  inner_access_policy = try(each.value.sg.inner_access_policy, null)
  resource_group_id   = try(each.value.sg.resource_group_id, null)
  security_group_type = try(each.value.sg.security_group_type, "normal")
  tags                = try(each.value.sg.tags, {})
  rules               = try(each.value.sg.rules, [])
}

