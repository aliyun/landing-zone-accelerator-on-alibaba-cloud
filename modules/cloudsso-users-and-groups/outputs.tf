output "user_ids" {
  description = "The User ID list of the users."
  value = [
    for user in alicloud_cloud_sso_user.default : user.user_id
  ]
}

output "users" {
  description = "Map of user names to user information."
  value = {
    for user_name, user in alicloud_cloud_sso_user.default : user_name => {
      user_id   = user.user_id
      user_name = user.user_name
      status    = user.status
    }
  }
}

output "group_ids" {
  description = "The Group ID list of the group"
  value = [
    for group in alicloud_cloud_sso_group.default : group.group_id
  ]
}

output "groups" {
  description = "Map of group names to group information."
  value = {
    for group_name, group in alicloud_cloud_sso_group.default : group_name => {
      group_id   = group.group_id
      group_name = group.group_name
    }
  }
}

output "user_attachment_ids" {
  description = "The resource ID of User Attachment. The value formats as <directory_id>:<group_id>:<user_id>"
  value = [
    for attachment in alicloud_cloud_sso_user_attachment.default : attachment.id
  ]
}
