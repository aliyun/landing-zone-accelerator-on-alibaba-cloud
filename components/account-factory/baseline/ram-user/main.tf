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

# Create RAM user and attach policies
module "ram_user" {
  source                        = "terraform-alicloud-modules/ram-user/alicloud"
  version                       = "2.0.0"
  user_name                     = var.user_name
  display_name                  = var.display_name
  mobile                        = var.mobile
  email                         = var.email
  comments                      = var.comments
  force_destroy_user            = var.force_destroy_user
  create_ram_user_login_profile = var.create_ram_user_login_profile
  password                      = var.password
  password_reset_required       = var.password_reset_required
  mfa_bind_required             = var.mfa_bind_required
  create_ram_access_key         = var.create_ram_access_key
  pgp_key                       = var.pgp_key
  secret_file                   = var.secret_file
  status                        = var.status
  managed_custom_policy_names   = concat(var.managed_custom_policy_names, keys(alicloud_ram_policy.policy))
  managed_system_policy_names   = var.managed_system_policy_names
}
