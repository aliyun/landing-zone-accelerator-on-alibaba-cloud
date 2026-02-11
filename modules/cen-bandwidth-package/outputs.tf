output "bandwidth_package_id" {
  description = "The ID of the CEN bandwidth package."
  value       = local.bandwidth_package_id
}

output "bandwidth_package_created" {
  description = "Whether a new bandwidth package was created."
  value       = local.create_bandwidth_package
}

output "cen_instance_id" {
  description = "The ID of the CEN instance the bandwidth package is attached to."
  value       = var.cen_instance_id
}
