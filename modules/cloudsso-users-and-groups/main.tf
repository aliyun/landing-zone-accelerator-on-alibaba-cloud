# Flatten user-group relationships for attachment
locals {
  groups_flatten = flatten([
    for group in var.groups : [
      for user_name in group.user_names :
      {
        user_name  = user_name
        group_name = group.group_name
      }
    ]
  ])
}

# Create CloudSSO users
resource "alicloud_cloud_sso_user" "default" {
  for_each     = { for user in var.users : user.user_name => user }
  directory_id = var.directory_id

  user_name                   = each.key
  display_name                = try(each.value.display_name, null)
  description                 = try(each.value.description, null)
  email                       = try(each.value.email, null)
  first_name                  = try(each.value.first_name, null)
  last_name                   = try(each.value.last_name, null)
  password                    = try(each.value.password, null)
  mfa_authentication_settings = try(each.value.mfa_authentication_settings, "Enabled")
  status                      = try(each.value.status, "Enabled")
  tags                        = try(each.value.tags, {})

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

# Create CloudSSO groups
resource "alicloud_cloud_sso_group" "default" {
  for_each     = { for group in var.groups : group.group_name => group }
  directory_id = var.directory_id

  group_name  = each.key
  description = try(each.value.description, null)
}

# Attach users to groups
resource "alicloud_cloud_sso_user_attachment" "default" {
  for_each     = { for item in local.groups_flatten : "${item.group_name}-${item.user_name}" => item }
  directory_id = var.directory_id

  group_id = alicloud_cloud_sso_group.default[each.value.group_name].group_id
  user_id  = alicloud_cloud_sso_user.default[each.value.user_name].user_id
}
