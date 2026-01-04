output "account_ids" {
  description = "List of created account IDs."
  value = [
    for account in alicloud_resource_manager_account.account :
    account.id
  ]
}

output "accounts" {
  description = "Information about created accounts."
  value = {
    for gid, account in alicloud_resource_manager_account.account :
    gid => {
      id           = account.id
      display_name = account.display_name
      roles        = contains(keys(local.account_configs), gid) ? local.account_configs[gid].roles : []
    }
  }
}

output "role_to_account_mapping" {
  description = "Mapping of individual roles to their account IDs."
  value = {
    for role, group_id in local.role_to_group_id :
    role => alicloud_resource_manager_account.account[group_id].id
    if contains(keys(alicloud_resource_manager_account.account), group_id)
  }
}

output "delegated_services" {
  description = "Mapping of services to their delegated administrator account IDs. Each service can have multiple delegated administrators (one per role)."
  value = {
    for service, roles in var.delegated_services :
    service => [
      for role in roles :
      alicloud_resource_manager_account.account[local.role_to_group_id[role]].id
      if contains(keys(alicloud_resource_manager_account.account), local.role_to_group_id[role])
    ]
  }
}

