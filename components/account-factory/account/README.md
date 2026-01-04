<div align="right">

**English** | [中文](README-CN.md)

</div>

# Account Factory Account Component

This component creates and manages Alibaba Cloud Resource Manager member accounts within a resource directory.

## Features

- Creates member accounts in resource directory
- Supports Trusteeship and Self-pay billing types
- Configures account display names and tags
- Places accounts in specified folders or root folder

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
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | Resource directory information |
| [alicloud_resource_manager_account.account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_account) | resource | Member account |

## Usage

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-a"
  display_name       = "Application A Account"
  parent_folder_id   = "fd-1234567890abcdef"
  billing_type       = "Self-pay"
  
  tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `account_name_prefix` | The prefix for the display name of the member account | `string` | - | Yes | 2-50 characters, start/end with letter or digit, only letters, digits, underscores, periods, hyphens, no consecutive special characters |
| `display_name` | The display name of the member account | `string` | - | Yes | 2-50 characters, can contain Chinese characters, letters, digits, underscores (_), periods (.), and hyphens (-) |
| `parent_folder_id` | The ID of the parent folder where the account will be created | `string` | `null` | No | If null, defaults to root folder |
| `billing_type` | The billing type for the member account | `string` | `"Trusteeship"` | No | Must be: `Trusteeship` or `Self-pay` |
| `billing_account_id` | The ID of the billing account | `string` | `null` | No | Required when `billing_type = "Trusteeship"` and not using current master account |
| `tags` | Tags to assign to the account | `map(string)` | `null` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `account_id` | The ID of the created member account |
| `resource_directory_id` | The ID of the resource directory |

## Examples

### Self-Pay Account

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-a"
  display_name       = "Application A"
  parent_folder_id   = "fd-abc123"
  billing_type       = "Self-pay"
}
```

### Trusteeship Account

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-b"
  display_name       = "Application B"
  parent_folder_id   = "fd-abc123"
  billing_type       = "Trusteeship"
  billing_account_id = "1234567890123456"
}
```

### Account with Tags

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "production-app"
  display_name       = "Production Application"
  billing_type       = "Self-pay"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    Project     = "landing-zone"
  }
}
```

## Notes

- Account name prefix must be unique within the resource directory
- Display name can contain Chinese characters
- When `billing_type = "Trusteeship"` and `billing_account_id` is null, the current master account is used as the payer
- Account is created in the root folder if `parent_folder_id` is not specified
- Account creation may take a few minutes to complete
