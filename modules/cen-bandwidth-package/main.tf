locals {
  create_bandwidth_package = !var.use_existing_bandwidth_package
}

resource "alicloud_cen_bandwidth_package" "this" {
  count = local.create_bandwidth_package ? 1 : 0

  bandwidth                  = var.bandwidth
  cen_bandwidth_package_name = var.cen_bandwidth_package_name
  description                = var.description
  geographic_region_a_id     = var.geographic_region_a_id
  geographic_region_b_id     = var.geographic_region_b_id
  payment_type               = var.payment_type
  period                     = var.period

  lifecycle {
    precondition {
      condition     = var.bandwidth != null
      error_message = "bandwidth is required when creating a new bandwidth package."
    }
    precondition {
      condition     = var.geographic_region_a_id != null
      error_message = "geographic_region_a_id is required when creating a new bandwidth package."
    }
    precondition {
      condition     = var.geographic_region_b_id != null
      error_message = "geographic_region_b_id is required when creating a new bandwidth package."
    }
    precondition {
      condition     = var.payment_type != "PrePaid" || var.pricing_cycle != null
      error_message = "pricing_cycle is required when payment_type is PrePaid."
    }
    precondition {
      condition     = var.payment_type != "PrePaid" || var.period != null
      error_message = "period is required when payment_type is PrePaid."
    }
  }
}

locals {
  bandwidth_package_id = local.create_bandwidth_package ? alicloud_cen_bandwidth_package.this[0].id : var.existing_bandwidth_package_id
}

resource "alicloud_cen_bandwidth_package_attachment" "this" {
  instance_id          = var.cen_instance_id
  bandwidth_package_id = local.bandwidth_package_id

  lifecycle {
    precondition {
      condition     = !var.use_existing_bandwidth_package || var.existing_bandwidth_package_id != null
      error_message = "existing_bandwidth_package_id is required when use_existing_bandwidth_package is true."
    }
  }
}
