resource "alicloud_common_bandwidth_package" "bandwidth_package" {
  bandwidth                 = var.bandwidth
  internet_charge_type      = var.internet_charge_type
  bandwidth_package_name    = var.bandwidth_package_name
  ratio                     = var.internet_charge_type == "PayBy95" ? var.ratio : null
  deletion_protection       = var.deletion_protection
  description               = var.description
  force                     = var.force
  isp                       = var.isp
  resource_group_id         = var.resource_group_id
  security_protection_types = var.security_protection_types
  tags                      = var.tags
  zone                      = var.zone
}

resource "alicloud_common_bandwidth_package_attachment" "bandwidth_package_attachment" {
  count = length(var.eip_attachments)

  bandwidth_package_id        = alicloud_common_bandwidth_package.bandwidth_package.id
  instance_id                 = var.eip_attachments[count.index].instance_id
  bandwidth_package_bandwidth = var.eip_attachments[count.index].bandwidth_package_bandwidth
}

