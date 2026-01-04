output "logstore_name" {
  description = "The name of the logstore"
  value       = var.logstore_name
}

output "logstore_arn" {
  description = "The ARN of the logstore"
  value       = format("acs:log:%s:%s:project/%s/logstore/%s", data.alicloud_regions.this.regions[0].id, data.alicloud_account.this.id, var.project_name, var.logstore_name)
}


