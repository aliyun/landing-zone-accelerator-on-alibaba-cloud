

resource "alicloud_tag_policy" "this" {
  for_each = {
    for policy in var.tag_policies : policy.policy_name => policy
  }

  policy_name    = each.value.policy_name
  policy_desc    = each.value.policy_desc
  policy_content = each.value.policy_content
  user_type      = try(each.value.user_type, "USER")
}

resource "alicloud_tag_policy_attachment" "this" {
  for_each = {
    for attachment in var.policy_attachments : "${attachment.policy_name}-${attachment.target_id}" => attachment
  }

  policy_id   = alicloud_tag_policy.this[each.value.policy_name].id
  target_id   = each.value.target_id
  target_type = each.value.target_type
}
