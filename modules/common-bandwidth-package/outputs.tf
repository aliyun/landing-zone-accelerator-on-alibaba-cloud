output "bandwidth_package_id" {
  description = "ID of the common bandwidth package."
  value       = alicloud_common_bandwidth_package.bandwidth_package.id
}

output "bandwidth_package_name" {
  description = "Name of the common bandwidth package."
  value       = alicloud_common_bandwidth_package.bandwidth_package.bandwidth_package_name
}

output "attachment_ids" {
  description = "List of attachment IDs for EIPs attached to the bandwidth package."
  value = [
    for attachment in alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment : attachment.id
  ]
}

output "attachment_details" {
  description = "List of attachment details including attachment ID, EIP instance ID, and bandwidth_package_bandwidth."
  value = [
    for idx, attachment in alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment : {
      attachment_id               = attachment.id
      eip_instance_id             = attachment.instance_id
      bandwidth_package_bandwidth = var.eip_attachments[idx].bandwidth_package_bandwidth
    }
  ]
}

