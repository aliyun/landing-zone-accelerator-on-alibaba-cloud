<div align="right">

**English** | [中文](README-CN.md)

</div>

# RAM Security Preference Module

This module configures Alibaba Cloud RAM security preferences and password policies for enhanced account security.

## Features

- Configures RAM password policy (complexity, age, reuse prevention)
- Configures RAM security preferences (MFA, session duration, login restrictions)
- Manages user permissions for password and MFA device management
- Configures login network masks for IP-based access control

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_password_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_password_policy) | resource | RAM password policy |
| [alicloud_ram_security_preference.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_security_preference) | resource | RAM security preferences |

## Usage

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  allow_user_to_change_password = true
  allow_user_to_manage_mfa_devices = true
  
  login_session_duration = 8
  
  password_policy = {
    minimum_password_length = 12
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    max_password_age = 90
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `allow_user_to_change_password` | Allow users to change their password | `bool` | `true` | No | - |
| `allow_user_to_login_with_passkey` | Whether to allow RAM users to log on using a passkey | `bool` | `true` | No | - |
| `allow_user_to_manage_access_keys` | Whether to allow RAM users to manage their own access keys | `bool` | `false` | No | - |
| `allow_user_to_manage_mfa_devices` | Whether to allow RAM users to manage MFA devices | `bool` | `true` | No | - |
| `allow_user_to_manage_personal_ding_talk` | Whether to allow RAM users to manage personal DingTalk binding | `bool` | `true` | No | - |
| `enable_save_mfa_ticket` | Whether to save MFA verification status (valid for 7 days) | `bool` | `true` | No | - |
| `login_session_duration` | Duration of login session in hours | `number` | `6` | No | Must be between 1 and 24 |
| `login_network_masks` | List of IP address ranges to allow login | `list(string)` | `[]` | No | Maximum 40 masks |
| `mfa_operation_for_login` | MFA requirement during logon | `string` | `"independent"` | No | Must be: `mandatory`, `independent`, `adaptive` |
| `operation_for_risk_login` | MFA verification for abnormal logon | `string` | `"autonomous"` | No | Must be: `autonomous`, `enforceVerify` |
| `verification_types` | Means of multi-factor authentication | `set(string)` | `[]` | No | Must be: `sms`, `email`, or empty |
| `password_policy` | Configuration for the RAM password policy | `object` | See below | No | See password policy structure below |

### Password Policy Object Structure

The `password_policy` object has the following structure:

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `minimum_password_length` | `number` | `8` | No | Minimum password length |
| `require_lowercase_characters` | `bool` | `true` | No | Require lowercase characters |
| `require_numbers` | `bool` | `true` | No | Require numbers |
| `require_uppercase_characters` | `bool` | `true` | No | Require uppercase characters |
| `require_symbols` | `bool` | `false` | No | Require symbols |
| `max_password_age` | `number` | `90` | No | Maximum password age in days |
| `password_reuse_prevention` | `number` | `3` | No | Number of previous passwords to prevent reuse |
| `max_login_attempts` | `number` | `5` | No | Maximum login attempts before lockout |
| `hard_expiry` | `bool` | `false` | No | Hard expiry for passwords |
| `password_not_contain_user_name` | `bool` | `false` | No | Password cannot contain username |
| `minimum_password_different_character` | `number` | `0` | No | Minimum different characters from previous password |

## Outputs

This module does not provide any outputs.

## Examples

### Basic Security Preferences

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"
}
```

### Enhanced Security Configuration

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  allow_user_to_change_password = true
  allow_user_to_manage_access_keys = false
  allow_user_to_manage_mfa_devices = true
  
  login_session_duration = 4
  login_network_masks = ["192.168.1.0/24", "10.0.0.0/8"]
  
  mfa_operation_for_login = "mandatory"
  operation_for_risk_login = "enforceVerify"
  verification_types = ["sms", "email"]
  
  password_policy = {
    minimum_password_length = 16
    require_lowercase_characters = true
    require_numbers = true
    require_uppercase_characters = true
    require_symbols = true
    max_password_age = 60
    password_reuse_prevention = 5
    max_login_attempts = 3
    hard_expiry = false
    password_not_contain_user_name = true
    minimum_password_different_character = 4
  }
}
```

### Adaptive MFA Configuration

```hcl
module "ram_security_preference" {
  source = "./modules/ram-security-preference"

  mfa_operation_for_login = "adaptive"
  operation_for_risk_login = "enforceVerify"
  enable_save_mfa_ticket = true
  
  password_policy = {
    minimum_password_length = 12
    require_symbols = true
    max_password_age = 90
  }
}
```

## Notes

- Password policy applies to all RAM users in the account
- Security preferences are account-level settings
- `mfa_operation_for_login` options:
  - `mandatory`: MFA required for all RAM users
  - `independent`: Depends on individual user configuration
  - `adaptive`: Used only during abnormal login
- `login_network_masks` limits login to specified IP ranges (empty list allows all)
- `verification_types` can include `sms` and/or `email` for MFA
- Session duration is in hours (1-24)
- Password reuse prevention prevents using the last N passwords
