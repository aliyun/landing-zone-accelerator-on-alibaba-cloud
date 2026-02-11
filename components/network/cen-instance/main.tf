data "alicloud_cen_transit_router_service" "enable" {
  enable = "On"
}

resource "alicloud_cen_instance" "cen" {
  cen_instance_name = var.cen_instance_name
  description       = var.description
  tags              = var.tags
  protection_level  = var.protection_level
  resource_group_id = var.resource_group_id

  depends_on = [
    data.alicloud_cen_transit_router_service.enable
  ]
}

locals {
  # Sort geographic regions to ensure consistent key regardless of A/B order
  bandwidth_packages_map = {
    for bwp in var.bandwidth_packages :
    join(":", sort([bwp.geographic_region_a_id, bwp.geographic_region_b_id])) => bwp
  }
}

module "cen_bandwidth_package" {
  source   = "../../../modules/cen-bandwidth-package"
  for_each = local.bandwidth_packages_map

  cen_instance_id            = alicloud_cen_instance.cen.id
  bandwidth                  = each.value.bandwidth
  cen_bandwidth_package_name = each.value.cen_bandwidth_package_name
  description                = each.value.description
  geographic_region_a_id     = each.value.geographic_region_a_id
  geographic_region_b_id     = each.value.geographic_region_b_id
  payment_type               = each.value.payment_type
  pricing_cycle              = each.value.pricing_cycle
  period                     = each.value.period
}

