# OSS outputs
output "oss_bucket_name" {
  description = "The name of the OSS bucket"
  value       = try(module.oss_bucket[0].bucket, null)
}

output "oss_extranet_endpoint" {
  description = "The extranet access endpoint of the OSS bucket"
  value       = try(module.oss_bucket[0].extranet_endpoint, null)
}

output "oss_intranet_endpoint" {
  description = "The intranet access endpoint of the OSS bucket"
  value       = try(module.oss_bucket[0].intranet_endpoint, null)
}

# SLS outputs
output "sls_project_name" {
  description = "The name of the SLS project"
  value       = try(module.sls_project[0].project_name, null)
}

output "sls_project_description" {
  description = "The description of the SLS project"
  value       = try(module.sls_project[0].project_description, null)
}

output "sls_logstore_name" {
  description = "The name of the logstore"
  value       = try(module.sls_project[0].logstore_name, null)
}

output "sls_retention_period" {
  description = "The retention period of the logstore"
  value       = try(module.sls_project[0].retention_period, null)
}

# Config aggregator outputs
output "config_aggregator_id" {
  description = "The ID of the config aggregator"
  value       = local.aggregator_id
}

output "config_aggregator_name" {
  description = "The name of the config aggregator"
  value       = var.use_existing_aggregator ? null : try(alicloud_config_aggregator.aggregator[0].aggregator_name, null)
}

# Config delivery channel outputs
output "config_delivery_channel_ids" {
  description = "The IDs of the config delivery channels"
  value = flatten([
    try([alicloud_config_aggregate_delivery.oss[0].id], []),
    try([alicloud_config_aggregate_delivery.sls[0].id], [])
  ])
}
