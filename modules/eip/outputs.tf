output "eip_instances" {
  description = "List of EIP instances with details including ID, IP address, and association ID."
  value = [
    for idx, eip in alicloud_eip_address.eip_address : {
      id                              = eip.id
      ip_address                      = eip.ip_address
      address_name                    = eip.address_name
      payment_type                    = eip.payment_type
      status                          = eip.status
      association_id                  = var.eip_associate_instance_id != "" ? alicloud_eip_association.eip_association[idx].id : null
      bandwidth_package_attachment_id = var.enable_common_bandwidth_package ? alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment[idx].id : null
    }
  ]
}

output "common_bandwidth_package_id" {
  description = "ID of the common bandwidth package (if enabled)."
  value       = var.enable_common_bandwidth_package ? alicloud_common_bandwidth_package.bandwidth_package[0].id : null
}


