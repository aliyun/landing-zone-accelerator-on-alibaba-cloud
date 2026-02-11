# Enable Private Zone service
data "alicloud_pvtz_service" "this" {
  enable = "On"
}

# Create Private Zone
resource "alicloud_pvtz_zone" "this" {
  zone_name         = var.zone_name
  remark            = var.zone_remark
  proxy_pattern     = var.proxy_pattern
  lang              = var.lang
  resource_group_id = var.resource_group_id
  tags              = var.tags

  depends_on = [data.alicloud_pvtz_service.this]
}

# Bind VPCs to Private Zone
resource "alicloud_pvtz_zone_attachment" "this" {
  count   = length(var.vpc_bindings) > 0 ? 1 : 0
  zone_id = alicloud_pvtz_zone.this.id
  dynamic "vpcs" {
    for_each = var.vpc_bindings
    content {
      vpc_id    = vpcs.value.vpc_id
      region_id = try(vpcs.value.region_id, null)
    }
  }

  depends_on = [data.alicloud_pvtz_service.this, alicloud_pvtz_zone.this]
}

# Create DNS records in Private Zone
resource "alicloud_pvtz_zone_record" "this" {
  for_each = { for idx, rec in var.record_entries : idx => rec }
  zone_id  = alicloud_pvtz_zone.this.id
  rr       = each.value.name
  type     = each.value.type
  value    = each.value.value
  ttl      = try(each.value.ttl, 60)
  lang     = try(each.value.lang, "en")
  priority = try(each.value.priority, 1)
  remark   = try(each.value.remark, "")
  status   = try(each.value.status, "ENABLE")

  depends_on = [data.alicloud_pvtz_service.this, alicloud_pvtz_zone.this]
}
