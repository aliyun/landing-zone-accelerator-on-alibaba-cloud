output "project_name" {
  description = "The name of the SLS project"
  value       = local.effective_project_name
}

output "project_description" {
  description = "The description of the SLS project"
  value       = var.description
}


output "project_arn" {
  description = "The ARN of the SLS project"
  value       = format("acs:log:%s:%s:project/%s", data.alicloud_regions.this.regions[0].id, data.alicloud_account.this.id, local.effective_project_name)
}
