output "directory_id" {
  description = "The ID of the CloudSSO directory."
  value       = alicloud_cloud_sso_directory.this.id
}

output "directory_name" {
  description = "The name of the CloudSSO directory."
  value       = alicloud_cloud_sso_directory.this.directory_name
}


output "access_configurations" {
  description = "List of access configurations with their names and IDs."
  value = [
    for name, config in alicloud_cloud_sso_access_configuration.this : {
      name = name
      id   = config.access_configuration_id
    }
  ]
}

output "users" {
  description = "Information about created CloudSSO users."
  value       = length(module.users_and_groups) > 0 ? module.users_and_groups[0].users : {}
}

output "groups" {
  description = "Information about created CloudSSO groups."
  value       = length(module.users_and_groups) > 0 ? module.users_and_groups[0].groups : {}
}

output "access_assignments" {
  description = "List of access assignment IDs."
  value = concat(
    [
      for assignment in alicloud_cloud_sso_access_assignment.member_accounts : assignment.id
    ],
    [
      for assignment in alicloud_cloud_sso_access_assignment.master_account : assignment.id
    ]
  )
}
