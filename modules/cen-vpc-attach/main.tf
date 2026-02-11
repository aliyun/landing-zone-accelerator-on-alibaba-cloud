# Get CEN account information
data "alicloud_account" "cen_account" {
  provider = alicloud.cen_tr
}

# Get VPC account information
data "alicloud_account" "vpc_account" {
  provider = alicloud.vpc
}

resource "alicloud_resource_manager_service_linked_role" "cen_service_role" {
  count        = var.cen_service_linked_role_exists ? 0 : 1
  provider     = alicloud.vpc
  service_name = "cen.aliyuncs.com"
}

locals {
  # Collect vSwitch IDs that need zone_id lookup
  vswitches_need_lookup = [
    for vsw in var.vpc_attachment_vswitches : vsw.vswitch_id
    if vsw.zone_id == null || vsw.zone_id == ""
  ]
}

# Query vSwitch information for those without zone_id
data "alicloud_vswitches" "vswitch_lookup" {
  provider = alicloud.vpc
  count    = length(local.vswitches_need_lookup) > 0 ? 1 : 0
  ids      = local.vswitches_need_lookup
  vpc_id   = var.vpc_id
}

locals {
  # Build lookup map from data source results
  vswitch_lookup_map = length(local.vswitches_need_lookup) > 0 ? {
    for vsw in data.alicloud_vswitches.vswitch_lookup[0].vswitches : vsw.id => vsw.zone_id
  } : {}

  # Build final vSwitch list with zone_id (from input or lookup)
  # If zone_id is not provided and cannot be queried, Terraform will fail naturally
  vpc_attachment_vswitches_with_zone = [
    for vsw in var.vpc_attachment_vswitches : {
      vswitch_id = vsw.vswitch_id
      zone_id    = coalesce(vsw.zone_id, try(local.vswitch_lookup_map[vsw.vswitch_id], null))
    }
  ]
}

resource "alicloud_cen_instance_grant" "cen_instance_grant" {
  provider          = alicloud.vpc
  count             = var.create_cen_instance_grant ? 1 : 0
  cen_id            = var.cen_instance_id
  cen_owner_id      = data.alicloud_account.cen_account.id
  child_instance_id = var.vpc_id

  depends_on = [alicloud_resource_manager_service_linked_role.cen_service_role]
}

# Attach VPC to CEN Transit Router
resource "alicloud_cen_transit_router_vpc_attachment" "vpc_attachment" {
  provider          = alicloud.cen_tr
  cen_id            = var.cen_instance_id
  transit_router_id = var.cen_tr_id
  vpc_id            = var.vpc_id
  vpc_owner_id      = data.alicloud_account.vpc_account.id

  dynamic "zone_mappings" {
    for_each = local.vpc_attachment_vswitches_with_zone
    content {
      zone_id    = zone_mappings.value.zone_id
      vswitch_id = zone_mappings.value.vswitch_id
    }
  }

  transit_router_vpc_attachment_name    = var.cen_tr_attachment_name
  transit_router_attachment_description = var.cen_tr_attachment_description
  auto_publish_route_enabled            = var.cen_tr_attachment_auto_publish_route_enabled
  force_delete                          = var.cen_tr_attachment_force_delete
  payment_type                          = var.cen_tr_attachment_payment_type
  tags                                  = var.cen_tr_attachment_tags
  transit_router_vpc_attachment_options = var.cen_tr_attachment_options
  resource_type                         = var.cen_tr_attachment_resource_type

  timeouts {
    create = "15m"
    update = "15m"
    delete = "30m"
  }

  depends_on = [
    alicloud_resource_manager_service_linked_role.cen_service_role,
    alicloud_cen_instance_grant.cen_instance_grant
  ]
}

# Associate route table with VPC attachment (optional)
resource "alicloud_cen_transit_router_route_table_association" "route_table_association" {
  provider                      = alicloud.cen_tr
  count                         = var.cen_tr_route_table_association_enabled == true ? 1 : 0
  transit_router_route_table_id = var.cen_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
}

# Enable route propagation to route table (optional)
resource "alicloud_cen_transit_router_route_table_propagation" "route_table_propagation" {
  provider                      = alicloud.cen_tr
  count                         = var.cen_tr_route_table_propagation_enabled == true ? 1 : 0
  transit_router_route_table_id = var.cen_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
}

# Create route entries in VPC route table with Transit Router as next hop
resource "alicloud_route_entry" "vpc_route_entry" {
  for_each = {
    for entry in var.vpc_route_entries :
    entry.destination_cidrblock => entry
  }

  provider              = alicloud.vpc
  route_table_id        = var.vpc_route_table_id
  destination_cidrblock = each.value.destination_cidrblock
  nexthop_id            = alicloud_cen_transit_router_vpc_attachment.vpc_attachment.transit_router_attachment_id
  nexthop_type          = "Attachment"
  name                  = try(each.value.name, null)
  description           = try(each.value.description, null)

  depends_on = [
    alicloud_cen_transit_router_vpc_attachment.vpc_attachment
  ]
}
