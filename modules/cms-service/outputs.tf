output "basic_cloud_monitor_service_id" {
  description = "The ID of the Basic CloudMonitor service."
  value       = alicloud_cloud_monitor_service_basic_public.basic.id
}

output "enterprise_cloud_monitor_service_id" {
  description = "The ID of the Enterprise CloudMonitor service (null if not enabled)."
  value       = length(alicloud_cloud_monitor_service_enterprise_public.enterprise) > 0 ? alicloud_cloud_monitor_service_enterprise_public.enterprise[0].id : null
}


