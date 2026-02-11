<div align="right">

**English** | [中文](README-CN.md)

</div>

# RAM User Module

This module creates and manages Alibaba Cloud RAM (Resource Access Management) users with policy attachments, login profiles, and access keys.

## Features

- Creates RAM users with optional display information
- Attaches existing system policies
- Attaches existing custom policies
- Creates and attaches new custom policies
- Configures login profiles with password and MFA settings
- Creates access keys with optional PGP encryption
- Supports force destroy for cleanup

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|--------|
| alicloud | >= 1.267.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| ram_user | terraform-alicloud-modules/ram-user/alicloud | 1.0.0 |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_policy.policy](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_policy) | resource | Inline custom RAM policies |

## Usage

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "my-user"
  display_name = "My User"
  email        = "user@example.com"
  mobile       = "86-18600008888"
  comments     = "Test user"
  
  create_ram_user_login_profile = true
  password                      = "SecurePassword123!"
  password_reset_required       = true
  mfa_bind_required            = true
  
  create_ram_access_key = true
  pgp_key              = "keybase:username"
  
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
  
  inline_custom_policies = [
    {
      policy_name     = "custom-policy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "Custom policy for OSS access"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `user_name` | Desired name for the ram user. | `string` | - | Yes | Must be 1-64 characters long and can only contain letters, numbers, periods (.), hyphens (-), and underscores (_) |
| `display_name` | Name of the RAM user which for display | `string` | `null` | No | - |
| `mobile` | Phone number of the RAM user. This number must contain an international area code prefix, just look like this: 86-18600008888. | `string` | `null` | No | - |
| `email` | Email of the RAM user. | `string` | `null` | No | - |
| `comments` | Comment of the RAM user. This parameter can have a string of 1 to 128 characters. | `string` | `null` | No | - |
| `force_destroy_user` | When destroying this user, destroy even if it has non-Terraform-managed ram access keys, login profile or MFA devices. | `bool` | `false` | No | - |
| `create_ram_user_login_profile` | Whether to create ram user login profile | `bool` | `false` | No | - |
| `password` | Login password of the user | `string` | `null` | No | Sensitive |
| `password_reset_required` | This parameter indicates whether the password needs to be reset when the user logs in. | `bool` | `null` | No | - |
| `mfa_bind_required` | This parameter indicates whether the MFA needs to be bind when the user logs in. | `bool` | `null` | No | - |
| `create_ram_access_key` | Whether to create ram access key. Default value is 'false'. | `bool` | `false` | No | - |
| `pgp_key` | Either a base-64 encoded PGP public key, or a keybase username in the form | `string` | `null` | No | - |
| `secret_file` | A file used to store access key and secret key of the user. | `string` | `null` | No | - |
| `status` | Status of access key | `string` | `"Active"` | No | - |
| `managed_custom_policy_names` | List of names of managed policies of Custom type to attach to RAM user | `list(string)` | `[]` | No | - |
| `managed_system_policy_names` | List of names of managed policies of System type to attach to RAM user | `list(string)` | `[]` | No | - |
| `inline_custom_policies` | List of custom policies to be created and attached | `list(object)` | `[]` | No | See inline policy structure below |

### Inline Custom Policy Object Structure

Each inline custom policy in `inline_custom_policies` must have the following structure:

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `policy_name` | `string` | - | Yes | Name of the policy |
| `policy_document` | `string` | - | Yes | Policy document in JSON format |
| `description` | `string` | `null` | No | Description of the policy |
| `force` | `bool` | `true` | No | Whether to delete policy forcibly |

## Outputs

| Name | Description |
|------|-------------|
| `user_name` | The name of RAM user |
| `user_id` | The unique ID assigned by alicloud |
| `access_key_id` | The access key ID |
| `access_key_secret` | The access key secret (sensitive) |
| `access_key_encrypted_secret` | The access key encrypted secret, base64 encoded |
| `access_key_key_fingerprint` | The fingerprint of the PGP key used to encrypt the secret |
| `access_key_status` | Active or Inactive. Keys are initially active, but can be made inactive by other means. |
| `pgp_key` | PGP key used to encrypt sensitive data for this user (if empty, no encryption) |

## Examples

### Basic RAM User

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "basic-user"
  display_name = "Basic User"
  email        = "basic@example.com"
}
```

### RAM User with Login Profile

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name                      = "login-user"
  display_name                   = "Login User"
  email                          = "login@example.com"
  create_ram_user_login_profile   = true
  password                       = "SecurePassword123!"
  password_reset_required        = true
  mfa_bind_required             = true
}
```

### RAM User with Access Key

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name           = "access-key-user"
  display_name        = "Access Key User"
  email               = "accesskey@example.com"
  create_ram_access_key = true
  pgp_key             = "keybase:username"
}
```

### RAM User with System Policies

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name                   = "policy-user"
  display_name                = "Policy User"
  email                       = "policy@example.com"
  managed_system_policy_names = [
    "AliyunOSSReadOnlyAccess",
    "AliyunECSReadOnlyAccess"
  ]
}
```

### RAM User with Inline Custom Policies

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "custom-policy-user"
  display_name = "Custom Policy User"
  email        = "custom@example.com"
  
  inline_custom_policies = [
    {
      policy_name     = "oss-access"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject", "oss:PutObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "OSS bucket access policy"
    }
  ]
}
```

### Complete RAM User Example

```hcl
module "ram_user" {
  source = "./components/account-factory/baseline/ram-user"

  user_name    = "complete-user"
  display_name = "Complete User"
  email        = "complete@example.com"
  mobile       = "86-18600008888"
  comments     = "Complete user example"
  
  force_destroy_user = true
  
  create_ram_user_login_profile = true
  password                       = "SecurePassword123!"
  password_reset_required        = true
  mfa_bind_required             = true
  
  create_ram_access_key = true
  pgp_key              = "keybase:username"
  secret_file          = "./secrets/access_key.txt"
  status               = "Active"
  
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
  managed_custom_policy_names = ["existing-custom-policy"]
  
  inline_custom_policies = [
    {
      policy_name     = "custom-oss-policy"
      policy_document = jsonencode({
        Version = "1"
        Statement = [{
          Effect   = "Allow"
          Action   = ["oss:GetObject"]
          Resource = ["acs:oss:*:*:my-bucket/*"]
        }]
      })
      description = "Custom OSS access policy"
    }
  ]
}
```

## Notes

- The `password` variable is marked as sensitive and will not be displayed in logs
- When `pgp_key` is provided, the access key secret will be encrypted using PGP
- `force_destroy_user` should be used with caution as it will delete the user even if it has non-Terraform-managed resources
- Existing custom policies referenced by name must exist before creating the user
- Mobile number must include international area code prefix (e.g., "86-18600008888")
- When `create_ram_access_key` is `true` and `pgp_key` is not provided, the secret will be stored in plain text (use with caution)
