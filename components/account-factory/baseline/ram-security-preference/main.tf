resource "alicloud_ram_password_policy" "this" {
  minimum_password_length              = var.password_policy.minimum_password_length
  require_lowercase_characters         = var.password_policy.require_lowercase_characters
  require_numbers                      = var.password_policy.require_numbers
  require_uppercase_characters         = var.password_policy.require_uppercase_characters
  require_symbols                      = var.password_policy.require_symbols
  max_password_age                     = var.password_policy.max_password_age
  password_reuse_prevention            = var.password_policy.password_reuse_prevention
  max_login_attemps                    = var.password_policy.max_login_attempts
  hard_expiry                          = var.password_policy.hard_expiry
  password_not_contain_user_name       = var.password_policy.password_not_contain_user_name
  minimum_password_different_character = var.password_policy.minimum_password_different_character
}

resource "alicloud_ram_security_preference" "this" {
  allow_user_to_change_password           = var.allow_user_to_change_password
  allow_user_to_login_with_passkey        = var.allow_user_to_login_with_passkey
  allow_user_to_manage_access_keys        = var.allow_user_to_manage_access_keys
  allow_user_to_manage_mfa_devices        = var.allow_user_to_manage_mfa_devices
  allow_user_to_manage_personal_ding_talk = var.allow_user_to_manage_personal_ding_talk
  enable_save_mfa_ticket                  = var.enable_save_mfa_ticket
  login_session_duration                  = var.login_session_duration
  login_network_masks                     = join(";", var.login_network_masks)
  mfa_operation_for_login                 = var.mfa_operation_for_login
  operation_for_risk_login                = var.operation_for_risk_login
  verification_types                      = var.verification_types
}
