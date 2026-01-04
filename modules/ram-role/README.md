<div align="right">

**English** | [中文](README-CN.md)

</div>

# RAM Role Module

This module creates and manages Alibaba Cloud RAM (Resource Access Management) roles with policy attachments.

## Features

- Creates RAM roles with custom trust policies
- Attaches existing system policies
- Attaches existing custom policies
- Creates and attaches new custom policies
- Supports MFA requirement configuration
- Configures session duration

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

| Name | Source | Version |
|------|--------|---------|
| ram_role | terraform-alicloud-modules/ram-role/alicloud | 2.0.0 |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_ram_policy.policy](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ram_policy) | resource | Inline custom RAM policies |

## Usage

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "my-role"
  role_description = "My RAM role"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
  managed_system_policy_names = ["AliyunECSReadOnlyAccess"]
  
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
| `role_name` | The name of the RAM role | `string` | - | Yes | - |
| `role_description` | Description of the RAM role | `string` | `null` | No | - |
| `force` | Whether to delete RAM policy forcibly | `bool` | `true` | No | - |
| `max_session_duration` | Maximum session duration in seconds | `number` | `3600` | No | - |
| `role_requires_mfa` | Whether role requires MFA | `bool` | `true` | No | - |
| `trusted_principal_arns` | ARNs of Alibaba Cloud entities who can assume these roles | `list(string)` | `[]` | No | Conflicts with `trust_policy` |
| `trusted_services` | Alibaba Cloud Services that can assume these roles | `list(string)` | `[]` | No | Conflicts with `trust_policy` |
| `trust_policy` | A custom role trust policy | `string` | `null` | No | Conflicts with `trusted_principal_arns` and `trusted_services` |
| `managed_system_policy_names` | List of names of managed policies of System type to attach | `list(string)` | `[]` | No | - |
| `attach_admin_policy` | Whether to attach an admin policy to a role | `bool` | `false` | No | - |
| `attach_readonly_policy` | Whether to attach a readonly policy to a role | `bool` | `false` | No | - |
| `managed_custom_policy_names` | List of names of managed policies of Custom type to attach | `list(string)` | `[]` | No | - |
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
| `role_name` | Name of the RAM role |
| `role_arn` | ARN of RAM role |
| `role_id` | ID of RAM role |

## Examples

### Basic RAM Role with Service Trust

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "ecs-role"
  role_description = "Role for ECS service"
  
  trusted_services = ["ecs.aliyuncs.com"]
}
```

### RAM Role with System Policies

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "readonly-role"
  role_description = "Read-only access role"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
  attach_readonly_policy = true
  managed_system_policy_names = ["AliyunOSSReadOnlyAccess"]
}
```

### RAM Role with Custom Trust Policy

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "cross-account-role"
  role_description = "Role for cross-account access"
  
  trust_policy = jsonencode({
    Version = "1"
    Statement = [{
      Effect = "Allow"
      Principal = {
        RAM = ["acs:ram::1234567890123456:root"]
      }
      Action = "sts:AssumeRole"
    }]
  })
}
```

### RAM Role with Inline Custom Policies

```hcl
module "ram_role" {
  source = "./modules/ram-role"

  role_name        = "custom-policy-role"
  role_description = "Role with custom policies"
  
  trusted_services = ["ecs.aliyuncs.com"]
  
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

## Notes

- Only one of `trusted_principal_arns`, `trusted_services`, or `trust_policy` can be specified
- Existing custom policies referenced by name must exist before creating the role
- `attach_admin_policy` and `attach_readonly_policy` are convenience flags for common use cases
- MFA requirement is enabled by default (`role_requires_mfa = true`)
- Maximum session duration defaults to 3600 seconds (1 hour)
