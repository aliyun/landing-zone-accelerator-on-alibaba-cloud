<div align="right">

**English** | [中文](README-CN.md)

</div>

# CloudSSO Component

This component creates and manages Alibaba Cloud CloudSSO (Cloud Single Sign-On) directory, access configurations, users, groups, and access assignments for centralized identity and access management.

## Features

- Creates CloudSSO directory with configurable name and random suffix support
- Creates access configurations with system-managed or inline custom policies
- Creates CloudSSO users and groups
- Configures access assignments for users/groups to member accounts and master account
- Supports loading configurations from files (JSON/YAML) or inline definitions
- Configures login preferences, MFA settings, and password policies
- Automatically delegates IAM account if different from master account

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| alicloud.master | >= 1.262.1 |
| alicloud.iam | >= 1.262.1 |
| random | >= 3.6.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| users_and_groups | ../../../modules/cloudsso-users-and-groups | CloudSSO users and groups |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.master](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Master account information |
| [alicloud_account.iam](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | IAM account information |
| [alicloud_cloud_sso_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cloud_sso_service) | data source | CloudSSO service activation |
| [alicloud_resource_manager_accounts.accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_accounts) | data source | Resource directory accounts lookup |
| [random_string.directory_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | Random suffix for directory name (optional) |
| [alicloud_cloud_sso_directory.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_directory) | resource | CloudSSO directory |
| [alicloud_cloud_sso_delegate_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_delegate_account) | resource | Delegate account (when IAM account differs from master) |
| [alicloud_cloud_sso_access_configuration.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_configuration) | resource | Access configurations |
| [alicloud_cloud_sso_access_assignment.member_accounts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_assignment) | resource | Access assignments for member accounts |
| [alicloud_cloud_sso_access_assignment.master_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_access_assignment) | resource | Access assignments for master account |

## Usage

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "my-cloudsso"
  
  access_configurations = [
    {
      name        = "Administrator"
      description = "Full access configuration"
      managed_system_policies = ["AliyunFullAccess"]
      session_duration = 3600
    }
  ]
  
  users = [
    {
      user_name = "admin"
      email     = "admin@example.com"
      status    = "Enabled"
    }
  ]
  
  access_assignments = [
    {
      principal_name             = "admin"
      principal_type             = "User"
      account_names              = ["account-1", "account-2"]
      include_master_account     = true
      access_configuration_names = ["Administrator"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `directory_name` | The name of the CloudSSO directory | `string` | `null` | No | If null, generated from account ID. 2-64 chars, lowercase letters/numbers/hyphens, cannot start/end with hyphen, cannot start with 'd-' |
| `append_random_suffix` | Whether to append random suffix to directory_name | `bool` | `false` | No | - |
| `random_suffix_length` | Length of random suffix | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | Separator between directory_name and suffix | `string` | `"-"` | No | Must be: `"-"`, `"_"`, or `""` |
| `login_preference` | Login preferences for CloudSSO directory | `object` | `null` | No | See login preference structure |
| `mfa_authentication_setting_info` | Global MFA verification configuration | `object` | `null` | No | See MFA structure |
| `password_policy` | Password policy configuration | `object` | `null` | No | See password policy structure |
| `access_configurations` | List of access configurations to create | `list(object)` | `[]` | No | See access configuration structure |
| `access_configurations_dir` | Directory path containing access config files | `string` | `null` | No | JSON/YAML files, merged with `access_configurations` |
| `users` | List of CloudSSO users to create | `list(object)` | `[]` | No | See user structure |
| `groups` | List of CloudSSO groups to create | `list(object)` | `[]` | No | See group structure |
| `access_assignments` | List of access assignments | `list(object)` | `[]` | No | See access assignment structure |

### Login Preference Object Structure

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `allow_user_to_get_credentials` | `bool` | `false` | No | Allow users to get credentials |
| `login_network_masks` | `string` | `null` | No | Login network masks (CIDR) |

### MFA Authentication Setting Info Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `mfa_authentication_advance_settings` | `string` | `"Enabled"` | No | MFA advance settings | Must be: `Enabled`, `ByUser`, `Disabled`, `OnlyRiskyLogin` |
| `operation_for_risk_login` | `string` | `null` | No | Operation for risk login | Must be: `Autonomous` or `EnforceVerify` |

### Password Policy Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `max_login_attempts` | `number` | `5` | No | Maximum login attempts | 0-32 (0 = no limit) |
| `max_password_age` | `number` | `90` | No | Maximum password age (days) | 1-120 |
| `min_password_different_chars` | `number` | `4` | No | Minimum different characters | 0 to min_password_length |
| `min_password_length` | `number` | `8` | No | Minimum password length | 8-32 |
| `password_not_contain_username` | `bool` | `true` | No | Password cannot contain username | - |
| `password_reuse_prevention` | `number` | `1` | No | Password reuse prevention | 0-24 (0 = disabled) |

### Access Configuration Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Access configuration name | 1-32 chars, letters/digits/hyphens |
| `description` | `string` | `null` | No | Description | 1-1024 chars if provided |
| `relay_state` | `string` | `"https://home.console.aliyun.com/"` | No | Relay state URL | - |
| `session_duration` | `number` | `3600` | No | Session duration (seconds) | 900-43200 |
| `managed_system_policies` | `list(string)` | `[]` | No | System-managed policy names | - |
| `inline_custom_policy` | `object` | `null` | No | Inline custom policy | See inline policy structure |

### Inline Custom Policy Object Structure

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `policy_name` | `string` | `"InlinePolicy"` | No | Policy name |
| `policy_document` | `string` | - | Yes | Policy document (JSON string) |

### User Object Structure

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `user_name` | `string` | - | Yes | User name |
| `display_name` | `string` | `null` | No | Display name |
| `description` | `string` | `null` | No | Description |
| `email` | `string` | `null` | No | Email address |
| `first_name` | `string` | `null` | No | First name |
| `last_name` | `string` | `null` | No | Last name |
| `password` | `string` | `null` | No | Password |
| `mfa_authentication_settings` | `string` | `"Enabled"` | No | MFA settings |
| `status` | `string` | `"Enabled"` | No | User status |
| `tags` | `map(string)` | `{}` | No | Tags |

### Group Object Structure

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `group_name` | `string` | - | Yes | Group name |
| `description` | `string` | `null` | No | Description |
| `user_names` | `list(string)` | `[]` | No | User names in the group |

### Access Assignment Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `principal_name` | `string` | - | Yes | User or group name | - |
| `principal_type` | `string` | `"User"` | No | Principal type | Must be: `User` or `Group` |
| `account_names` | `list(string)` | `[]` | No | Member account display names | - |
| `include_master_account` | `bool` | `false` | No | Include master account | - |
| `access_configuration_names` | `list(string)` | - | Yes | Access configuration names | At least one required |

## Outputs

| Name | Description |
|------|-------------|
| `directory_id` | The ID of the CloudSSO directory |
| `directory_name` | The name of the CloudSSO directory |
| `access_configurations` | List of access configurations with their names and IDs |
| `users` | Information about created CloudSSO users |
| `groups` | Information about created CloudSSO groups |
| `access_assignments` | List of access assignment IDs |

## Examples

### Basic CloudSSO Setup

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "Administrator"
      managed_system_policies = ["AliyunFullAccess"]
    }
  ]
}
```

### CloudSSO with Users and Access Assignments

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "ReadOnly"
      managed_system_policies = ["AliyunReadOnlyAccess"]
    }
  ]
  
  users = [
    {
      user_name = "admin"
      email     = "admin@example.com"
    },
    {
      user_name = "developer"
      email     = "dev@example.com"
    }
  ]
  
  groups = [
    {
      group_name = "Developers"
      user_names = ["developer"]
    }
  ]
  
  access_assignments = [
    {
      principal_name             = "admin"
      principal_type             = "User"
      account_names              = ["account-1"]
      access_configuration_names = ["ReadOnly"]
    },
    {
      principal_name             = "Developers"
      principal_type             = "Group"
      account_names              = ["account-1", "account-2"]
      access_configuration_names = ["ReadOnly"]
    }
  ]
}
```

### CloudSSO with Custom Policy

```hcl
module "cloudsso" {
  source = "./components/identity/cloudsso"

  providers = {
    alicloud.master = alicloud.master
    alicloud.iam    = alicloud.iam
  }

  directory_name = "enterprise-sso"
  
  access_configurations = [
    {
      name        = "CustomPolicy"
      description = "Custom access configuration"
      inline_custom_policy = {
        policy_name = "CustomInlinePolicy"
        policy_document = jsonencode({
          Version = "1"
          Statement = [
            {
              Effect   = "Allow"
              Action   = ["oss:GetObject", "oss:ListObjects"]
              Resource = "*"
            }
          ]
        })
      }
    }
  ]
}
```

## Notes

- CloudSSO service is automatically enabled before creating directory
- Directory name defaults to `CloudSSO-{account_id}` if not specified
- Random suffix can be appended to ensure global uniqueness
- IAM account is automatically delegated if different from master account
- Access configurations support both system-managed and inline custom policies
- Account names in access assignments are resolved to IDs via Resource Directory
- File configurations take priority over inline configurations for matching names
- Users and groups are created using the cloudsso-users-and-groups module
