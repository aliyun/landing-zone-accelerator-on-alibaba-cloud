# Create RAM policies
resource "alicloud_ram_policy" "policy" {
  for_each = {
    for policy in var.inline_custom_policies : policy.policy_name => policy
  }

  policy_name     = each.value.policy_name
  policy_document = each.value.policy_document
  description     = each.value.description
  rotate_strategy = "DeleteOldestNonDefaultVersionWhenLimitExceeded"
  force           = each.value.force
}

# Create RAM role and attach policies
module "ram_role" {
  source                      = "terraform-alicloud-modules/ram-role/alicloud"
  version                     = "2.0.1"
  role_name                   = var.role_name
  role_description            = var.role_description
  force                       = var.force
  max_session_duration        = var.max_session_duration
  role_requires_mfa           = var.role_requires_mfa
  managed_system_policy_names = var.managed_system_policy_names
  attach_admin_policy         = var.attach_admin_policy
  attach_readonly_policy      = var.attach_readonly_policy
  trusted_principal_arns      = var.trusted_principal_arns
  trusted_services            = var.trusted_services
  trust_policy                = var.trust_policy
  managed_custom_policy_names = concat(var.managed_custom_policy_names, keys(alicloud_ram_policy.policy))
}
