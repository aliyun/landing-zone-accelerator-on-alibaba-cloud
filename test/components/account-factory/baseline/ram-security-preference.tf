# RAM Security Preference
module "ram_security_preference" {
  source = "../../../../components/account-factory/baseline/ram-security-preference"

  providers = {
    alicloud = alicloud.default
  }

  allow_user_to_change_password           = true
  allow_user_to_login_with_passkey        = true
  allow_user_to_manage_access_keys        = false
  allow_user_to_manage_mfa_devices        = true
  allow_user_to_manage_personal_ding_talk = true
  enable_save_mfa_ticket                  = true
  login_session_duration                  = 6
  login_network_masks                     = []
  mfa_operation_for_login                 = "independent"
  operation_for_risk_login                = "autonomous"
  verification_types                      = ["sms", "email"]

  password_policy = {
    minimum_password_length              = 8
    require_lowercase_characters         = true
    require_numbers                      = true
    require_uppercase_characters         = true
    require_symbols                      = false
    max_password_age                     = 90
    password_reuse_prevention            = 3
    max_login_attempts                   = 5
    hard_expiry                          = false
    password_not_contain_user_name       = false
    minimum_password_different_character = 0
  }
}

output "ram_security_preference" {
  description = "RAM security preference output"
  value       = module.ram_security_preference
}

