output "cen_instance_id" {
  description = "The ID of the created CEN instance."
  value       = alicloud_cen_instance.cen.id
}

output "bandwidth_package_ids" {
  description = "List of bandwidth package IDs attached to this CEN instance."
  value       = [for bwp in module.cen_bandwidth_package : bwp.bandwidth_package_id]
}

output "bandwidth_packages" {
  description = "The bandwidth packages attached to this CEN instance."
  value = [
    for key, bwp in module.cen_bandwidth_package : merge(
      local.bandwidth_packages_map[key],
      { bandwidth_package_id = bwp.bandwidth_package_id }
    )
  ]
}

output "bandwidth_packages_map" {
  description = "The bandwidth packages attached to this CEN instance (map format with key-value)."
  value = {
    for key, bwp in module.cen_bandwidth_package : key => merge(
      local.bandwidth_packages_map[key],
      { bandwidth_package_id = bwp.bandwidth_package_id }
    )
  }
}

