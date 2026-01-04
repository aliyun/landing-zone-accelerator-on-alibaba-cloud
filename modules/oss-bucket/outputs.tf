output "bucket" {
  description = "The name of the bucket"
  value       = local.effective_bucket_name
}

output "extranet_endpoint" {
  description = "The extranet access endpoint of the bucket"
  value       = alicloud_oss_bucket.bucket.extranet_endpoint
}

output "intranet_endpoint" {
  description = "The intranet access endpoint of the bucket"
  value       = alicloud_oss_bucket.bucket.intranet_endpoint
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = format("acs:oss:oss-%s:%s:%s", data.alicloud_regions.this.regions.0.id, data.alicloud_account.this.id, local.effective_bucket_name)
}
