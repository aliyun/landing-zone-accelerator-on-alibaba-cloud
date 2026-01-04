<div align="right">

**English** | [中文](README-CN.md)

</div>

# Guardrails Preventive Component

This component creates and manages Alibaba Cloud Resource Manager control policies for preventive guardrails to enforce compliance before resource creation.

## Features

- Creates Resource Manager control policies
- Attaches policies to folders, accounts, or root folder
- Supports loading configurations from files (JSON/YAML) or inline definitions
- Resolves folder names and account display names to IDs automatically
- Supports attaching policies to root folder

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
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | Resource directory information (for root folder) |
| [alicloud_resource_manager_folders.by_name](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_folders) | data source | Folders lookup by name |
| [alicloud_resource_manager_folders.by_regex](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_folders) | data source | Folders lookup by regex |
| [alicloud_resource_manager_accounts.all](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_accounts) | data source | All accounts lookup |
| [alicloud_resource_manager_control_policy.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_control_policy) | resource | Control policies |
| [alicloud_resource_manager_control_policy_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_control_policy_attachment) | resource | Policy attachments to targets |

## Usage

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "PreventPublicAccess"
      description = "Prevent public access to resources"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["*"]
            Resource = "*"
            Condition = {
              StringEquals = {
                "acs:PublicAccess" = "true"
              }
            }
          }
        ]
      })
      target_folder_names = ["Production", "Development"]
      attach_to_root      = false
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `control_policies` | List of control policies to create and their attachments | `list(object)` | `[]` | No | See control policy structure below |
| `control_policies_dir` | Directory path containing control policy config files | `string` | `null` | No | JSON/YAML files, merged with `control_policies` |

### Control Policy Object Structure

Each policy in `control_policies` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Policy name | 1-128 characters |
| `description` | `string` | `null` | No | Policy description | - |
| `policy_document` | `string` | - | Yes | Policy document (JSON string) | Valid JSON |
| `tags` | `map(string)` | `{}` | No | Tags for the control policy | Maximum 20 tags |
| `target_ids` | `list(string)` | `[]` | No | Target folder/account IDs | - |
| `target_account_display_names` | `list(string)` | `[]` | No | Target account display names | - |
| `target_folder_names` | `list(string)` | `[]` | No | Target folder names | Note: Duplicate folder names at different levels will all be bound |
| `target_folder_name_regexes` | `list(string)` | `[]` | No | Regular expressions to match folder names | All matching folders will be bound, merged with other target fields |
| `attach_to_root` | `bool` | `false` | No | Whether to attach to root folder | - |

**Note**: All target fields are optional. You can create a control policy without binding it to any target. The policy will be created but no attachments will be made. Target fields (`target_ids`, `target_folder_names`, `target_folder_name_regexes`, `target_account_display_names`) are merged and deduplicated for each policy.

## Outputs

| Name | Description |
|------|-------------|
| `policies` | List of control policies with their attachments |

## Examples

### Attach Policy to Folders

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "ProductionPolicy"
      description = "Policy for production folder"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Allow"
            Action   = ["*"]
            Resource = "*"
          }
        ]
      })
      target_folder_names = ["Production"]
    }
  ]
}
```

### Attach Policy to Root Folder

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "GlobalPolicy"
      description = "Global policy for all resources"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["*"]
            Resource = "*"
            Condition = {
              StringEquals = {
                "acs:PublicAccess" = "true"
              }
            }
          }
        ]
      })
      attach_to_root = true
    }
  ]
}
```

### Use Target IDs for Precise Control

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "SpecificFolderPolicy"
      description = "Policy for specific folder"
      policy_document = jsonencode({...})
      target_ids = ["fd-abc123", "fd-xyz789"]
    }
  ]
}
```

### Use Regex to Match Folders

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "ProductionFoldersPolicy"
      description = "Policy for all production folders"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["*"]
            Resource = "*"
            Condition = {
              StringEquals = {
                "acs:PublicAccess" = "true"
              }
            }
          }
        ]
      })
      target_folder_name_regexes = ["^Prod.*", "^Production.*"]
    }
  ]
}
```

### Create Policy with Tags

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "TaggedPolicy"
      description = "Policy with tags"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["*"]
            Resource = "*"
          }
        ]
      })
      tags = {
        Environment = "production"
        Team        = "security"
        Project     = "landing-zone"
      }
      target_folder_names = ["Production"]
    }
  ]
}
```

### Create Policy Without Target Binding

You can create a control policy without binding it to any target. The policy will be created but no attachments will be made:

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "UnattachedPolicy"
      description = "Policy created without target binding"
      policy_document = jsonencode({
        Version = "1"
        Statement = [
          {
            Effect   = "Deny"
            Action   = ["ram:DeleteRole", "ram:DeletePolicy"]
            Resource = "*"
          }
        ]
      })
      # No target_ids, target_folder_names, target_folder_name_regexes, target_account_display_names, or attach_to_root
    }
  ]
}
```

## Notes

- Control policies enforce compliance before resource creation
- Folders can have the same name at different levels - all matching folders will be bound
- For precise control, use `target_ids` to specify folder IDs instead of names
- `target_folder_name_regexes` uses regex patterns to match folder names - all matching folders will be bound
- Target fields (`target_ids`, `target_folder_names`, `target_folder_name_regexes`, `target_account_display_names`) are merged and deduplicated for each policy
- Policy document must be valid JSON
- File configurations take priority over inline configurations for matching names
- Policies are attached to targets (folders, accounts, or root) after creation
