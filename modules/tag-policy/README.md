<div align="right">

**English** | [中文](README-CN.md)

</div>

# Tag Policy Module

This module creates and manages Alibaba Cloud tag policies and their attachments to control tagging behavior across resources.

## Features

- Creates tag policies with custom rules
- Attaches tag policies to users, accounts, or resource directories
- Supports multiple policy attachments
- Enforces tag compliance and governance

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_tag_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_policy) | resource | Tag policies |
| [alicloud_tag_policy_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/tag_policy_attachment) | resource | Tag policy attachments |

## Usage

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "EnforceEnvironmentTag"
      policy_desc = "Enforce Environment tag on all resources"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging", "development"]
            }
          }
        }
      })
      user_type = "ACCOUNT"
    }
  ]

  policy_attachments = [
    {
      policy_name = "EnforceEnvironmentTag"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `tag_policies` | List of tag policies to create | `list(object)` | `[]` | No | See tag policy structure below |
| `policy_attachments` | List of policy attachments to create | `list(object)` | `[]` | No | See policy attachment structure below |

### Tag Policy Object Structure

Each tag policy in `tag_policies` must have the following structure:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `policy_name` | `string` | Yes | Tag policy name | 1-128 characters, cannot start with "http://" or "https://" |
| `policy_desc` | `string` | No | Tag policy description | 1-512 characters, cannot start with "http://" or "https://" |
| `policy_content` | `string` | Yes | Tag policy content in JSON format | Valid JSON string defining tag rules |
| `user_type` | `string` | No | User type | Valid values: USER, ACCOUNT, RD. Default: USER |

### Policy Attachment Object Structure

Each policy attachment in `policy_attachments` must have the following structure:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `policy_name` | `string` | Yes | Name of the tag policy to attach | Must match a policy name in tag_policies |
| `target_id` | `string` | Yes | ID of the target to attach the policy to | Valid user ID, account ID, or resource directory ID |
| `target_type` | `string` | Yes | Type of the target | Valid values: USER, ACCOUNT, RD |

## Outputs

| Name | Description |
|------|-------------|
| `policy_ids` | Map of policy names to their IDs |
| `policy_names` | List of created tag policy names |
| `attachment_ids` | List of policy attachment IDs |

## Examples

### Basic Tag Policy

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "RequireProjectTag"
      policy_desc = "Require Project tag on resources"
      policy_content = jsonencode({
        tags = {
          Project = {
            tag_key = {
              "@@assign" = "Project"
            }
            tag_value = {
              "@@assign" = ["*"]
            }
          }
        }
      })
    }
  ]
}
```

### Tag Policy with Multiple Attachments

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "TagGovernance"
      policy_desc = "Comprehensive tag governance policy"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging", "development"]
            }
          }
          CostCenter = {
            tag_key = {
              "@@assign" = "CostCenter"
            }
            tag_value = {
              "@@assign" = ["*"]
            }
          }
        }
      })
      user_type = "ACCOUNT"
    }
  ]

  policy_attachments = [
    {
      policy_name = "TagGovernance"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    },
    {
      policy_name = "TagGovernance"
      target_id   = "rd-abcdef****"
      target_type = "RD"
    }
  ]
}
```

### Restrict Tag Values

```hcl
module "tag_policy" {
  source = "./modules/tag-policy"

  tag_policies = [
    {
      policy_name = "RestrictEnvironmentValues"
      policy_desc = "Restrict Environment tag to specific values"
      policy_content = jsonencode({
        tags = {
          Environment = {
            tag_key = {
              "@@assign" = "Environment"
            }
            tag_value = {
              "@@assign" = ["production", "staging"]
            }
          }
        }
      })
    }
  ]

  policy_attachments = [
    {
      policy_name = "RestrictEnvironmentValues"
      target_id   = "<ACCOUNT_ID>"
      target_type = "ACCOUNT"
    }
  ]
}
```

## Notes

- Tag policies help enforce consistent tagging across resources
- Policy content must be valid JSON following Alibaba Cloud tag policy schema
- **IMPORTANT**: Every tag key MUST include a `tag_value` field. Use `["*"]` to allow any value
- The `@@assign` operator is used to define tag rules
- The `enforced_for` field is optional and used for pre-event interception (preventing non-compliant resource creation)
  - Do NOT use `["*"]` for `enforced_for` - it's not supported
  - Specify exact resource types like `ACS::ECS::Instance`, `ACS::RDS::DBInstance`, etc.
  - Omit `enforced_for` to use post-event detection only (recommended for most cases)
- Tag policies can be attached to users, accounts, or resource directories
- Multiple policies can be attached to the same target
- Policy attachments require the policy to be created first (handled automatically by the module)
- USER type is for individual RAM users
- ACCOUNT type is for Alibaba Cloud accounts
- RD type is for Resource Directory (multi-account management)
