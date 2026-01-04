<div align="right">

**English** | [中文](README-CN.md)

</div>

# CloudSSO Users and Groups Module

This module creates and manages Alibaba Cloud CloudSSO users and groups, including user-group associations.

## Features

- Creates CloudSSO users with comprehensive configuration
- Creates CloudSSO groups
- Associates users with groups
- Supports user authentication settings (MFA, status)

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
| [alicloud_cloud_sso_user.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_user) | resource | CloudSSO users |
| [alicloud_cloud_sso_group.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_group) | resource | CloudSSO groups |
| [alicloud_cloud_sso_user_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_sso_user_attachment) | resource | User-group associations |

## Usage

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name = "john.doe"
      display_name = "John Doe"
      email = "john.doe@example.com"
      status = "Enabled"
    }
  ]
  
  groups = [
    {
      group_name = "developers"
      description = "Development team"
      user_names = ["john.doe"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `directory_id` | CloudSSO directory ID | `string` | - | Yes | Must match format: `d-[A-Za-z0-9]+` |
| `users` | A list of CloudSSO users | `list(object)` | `[]` | No | See user object structure below |
| `groups` | A list of CloudSSO groups | `list(object)` | `[]` | No | See group object structure below |

### User Object Structure

Each user in `users` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `user_name` | `string` | - | Yes | User name | 1-64 characters, only numbers, letters, and @_-. characters |
| `display_name` | `string` | `null` | No | Display name | Max 256 characters |
| `description` | `string` | `null` | No | User description | Max 1024 characters |
| `email` | `string` | `null` | No | Email address | Valid email format, max 128 characters |
| `first_name` | `string` | `null` | No | First name | Max 64 characters |
| `last_name` | `string` | `null` | No | Last name | Max 64 characters |
| `password` | `string` | `null` | No | User password | 8-32 characters, must include uppercase, lowercase, number, and special character |
| `mfa_authentication_settings` | `string` | `"Enabled"` | No | MFA authentication settings | Must be `"Enabled"` or `"Disabled"` |
| `status` | `string` | `"Enabled"` | No | User status | Must be `"Enabled"` or `"Disabled"` |
| `tags` | `map(string)` | `{}` | No | User tags | - |

### Group Object Structure

Each group in `groups` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `group_name` | `string` | - | Yes | Group name | 1-128 characters, only letters, digits, and _-. characters |
| `description` | `string` | `null` | No | Group description | Max 1024 characters |
| `user_names` | `list(string)` | `[]` | No | List of user names to add to the group | User names must exist in `users` |

## Outputs

| Name | Description |
|------|-------------|
| `user_ids` | The User ID list of the users |
| `users` | Map of user names to user information (user_id, user_name, status) |
| `group_ids` | The Group ID list of the groups |
| `groups` | Map of group names to group information (group_id, group_name) |
| `user_attachment_ids` | The resource ID of User Attachment in format: `<directory_id>:<group_id>:<user_id>` |

## Examples

### Create Users Only

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name  = "alice.smith"
      display_name = "Alice Smith"
      email      = "alice.smith@example.com"
      first_name = "Alice"
      last_name  = "Smith"
      status     = "Enabled"
    },
    {
      user_name  = "bob.jones"
      display_name = "Bob Jones"
      email      = "bob.jones@example.com"
      status     = "Enabled"
    }
  ]
}
```

### Create Groups with Users

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name = "admin.user"
      email     = "admin@example.com"
      status    = "Enabled"
    },
    {
      user_name = "dev.user"
      email     = "dev@example.com"
      status    = "Enabled"
    }
  ]
  
  groups = [
    {
      group_name  = "administrators"
      description = "System administrators"
      user_names  = ["admin.user"]
    },
    {
      group_name  = "developers"
      description = "Development team"
      user_names  = ["dev.user"]
    }
  ]
}
```

### User with MFA Disabled

```hcl
module "cloudsso_users_groups" {
  source = "./modules/cloudsso-users-and-groups"

  directory_id = "d-1234567890abcdef0"
  
  users = [
    {
      user_name                 = "service.account"
      email                     = "service@example.com"
      mfa_authentication_settings = "Disabled"
      status                    = "Enabled"
    }
  ]
}
```

## Notes

- User passwords must meet complexity requirements: 8-32 characters with uppercase, lowercase, number, and special character
- Passwords are ignored in lifecycle changes to prevent accidental updates
- User names referenced in `groups[].user_names` must exist in the `users` list
- MFA authentication is enabled by default for all users
- Users can be disabled by setting `status` to `"Disabled"`

