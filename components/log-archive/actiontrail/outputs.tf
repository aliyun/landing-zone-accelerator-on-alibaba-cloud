output "trail_name" {
  description = "The name of the ActionTrail trail"
  value       = alicloud_actiontrail_trail.main.trail_name
}

output "trail_id" {
  description = "The ID of the ActionTrail trail"
  value       = alicloud_actiontrail_trail.main.id
}

output "oss_bucket_name" {
  description = "The name of the OSS bucket (if enabled)"
  value       = var.enable_oss_delivery ? module.oss_bucket[0].bucket : null
}

output "sls_project_name" {
  description = "The name of the SLS project (if enabled)"
  value       = var.enable_sls_delivery ? module.sls_project[0].project_name : null
}

