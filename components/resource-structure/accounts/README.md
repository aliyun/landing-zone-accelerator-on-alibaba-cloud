<div align="right">

**English** | [中文](README-CN.md)

</div>

# Accounts Component

This component creates functional accounts in the Resource Directory and configures service delegation administrators.

## Features

- Creates functional accounts in specified folders
- Supports per-account folder assignment or default core folder
- Supports multiple roles per account (comma-separated role keys)
- Configures delegated administrators for cloud services (supports multiple roles per service)
- Validates account configuration and role assignments
- Supports both Trusteeship and Self-pay billing types

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
| [alicloud_resource_manager_account.account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_account) | resource | Functional accounts |
| [alicloud_resource_manager_delegated_administrator.service_specific](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_delegated_administrator) | resource | Service delegation administrators |
| [null_resource.validate_delegated_admin_roles](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | Validates delegated admin roles |

## Usage

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "Log Archive Account"
      billing_type        = "Self-pay"
      tags                = {
        Environment = "Production"
        Team        = "Platform"
      }
    }
    security = {
      account_name_prefix = "security"
      display_name        = "Security Account"
      billing_type        = "Self-pay"
      folder_id           = "fd-2ze0xxxxxxxxxxxxxxxx"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
    "log,security" = {
      account_name_prefix = "security"
      display_name        = "Security Account"
      billing_type        = "Self-pay"
      tags                = {}
    }
  }

  delegated_services = {
    "cloudfw.aliyuncs.com"     = ["security"]
    "actiontrail.aliyuncs.com" = ["log"]
    "cloudmonitor.aliyuncs.com" = ["operations", "security"]
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `resource_directory_id` | The ID of the resource directory | `string` | - | Yes | - |
| `default_folder_id` | The default folder ID where accounts will be created if folder_id is not specified in account_mapping. If not provided, accounts will be created in the root folder. | `optional(string)` | `null` | No | No |
| `account_mapping` | Mapping of functional roles to accounts | `map(object)` | See below | No | Valid account configuration |
| `delegated_services` | Map of services to delegate as administrators (each service can have multiple roles) | `map(list(string))` | See below | No | Valid service identifiers, each service must have at least one role |

### account_mapping Object

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account_name_prefix` | Prefix for account name (2-50 chars). Must start and end with a letter or digit, contain only letters, digits, underscores (_), periods (.), and hyphens (-), and not contain consecutive special characters. | `string` | Yes |
| `display_name` | Display name for the account (2-50 chars). Can contain Chinese characters, letters, digits, underscores (_), periods (.), and hyphens (-). | `string` | Yes |
| `billing_type` | Billing type: "Trusteeship" or "Self-pay" | `string` | No |
| `billing_account_id` | Billing account ID (required for Trusteeship) | `string` | No |
| `folder_id` | Folder ID where this account will be created | `optional(string)` | `null` | No | If not specified, uses default_folder_id. If default_folder_id is also not provided, account will be created in root folder. |
| `tags` | Tags for the account | `map(string)` | No |

### Default account_mapping

```hcl
{
  log = {
    account_name_prefix = "log"
    display_name        = "log"
    billing_type        = "Self-pay"
  }
  network = {
    account_name_prefix = "network"
    display_name        = "network"
    billing_type        = "Self-pay"
  }
  security = {
    account_name_prefix = "security"
    display_name        = "security"
    billing_type        = "Self-pay"
  }
  shared_services = {
    account_name_prefix = "shared"
    display_name        = "shared"
    billing_type        = "Self-pay"
  }
  operations = {
    account_name_prefix = "ops"
    display_name        = "ops"
    billing_type        = "Self-pay"
  }
}
```

### Default delegated_services

Includes delegation for security, log, operations, and identity services. See variables.tf for complete list.

## Outputs

| Name | Description |
|------|-------------|
| `account_ids` | List of created account IDs |
| `accounts` | Information about created accounts |
| `role_to_account_mapping` | Mapping of individual roles to their account IDs |
| `delegated_services` | Mapping of services to their delegated administrator account IDs (each service maps to a list of account IDs, one per role) |

## Examples

### Basic Account Creation

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "log"
      billing_type        = "Self-pay"
      tags                = {}
    }
  }
}
```

### Multiple Roles per Account

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    "log,security" = {
      account_name_prefix = "security"
      display_name        = "Security and Log Account"
      billing_type        = "Self-pay"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
  }
}
```

### With Service Delegation

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    security = {
      account_name_prefix = "security"
      display_name        = "security"
      billing_type        = "Self-pay"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
  }

  delegated_services = {
    "cloudfw.aliyuncs.com" = ["security"]
    "sas.aliyuncs.com"     = ["security"]
    "cloudmonitor.aliyuncs.com" = ["operations", "security"]
  }
}
```

### Trusteeship Billing

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "log"
      billing_type        = "Trusteeship"
      billing_account_id = "<ACCOUNT_ID>"
      tags                = {}
    }
  }
}
```

### Per-Account Folder Assignment

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "log"
      billing_type        = "Self-pay"
      folder_id           = "fd-2ze0xxxxxxxxxxxxxxxx"
      tags                = {
        Environment = "Production"
        Team        = "Platform"
      }
    }
    security = {
      account_name_prefix = "security"
      display_name        = "security"
      billing_type        = "Self-pay"
      folder_id           = "fd-2ze0xxxxxxxxxxxxxxxx"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
    network = {
      account_name_prefix = "network"
      display_name        = "network"
      billing_type        = "Self-pay"
      tags                = {}
      # Uses default_folder_id if provided, otherwise account will be created in root folder
    }
  }
}
```

## Notes

- Accounts can be created in different folders by specifying `folder_id` in `account_mapping`
- If `folder_id` is not specified in `account_mapping`, the account will be created in `default_folder_id` (if provided) or root folder
- Priority: `folder_id` in `account_mapping` takes precedence over `default_folder_id`
- Multiple roles can be assigned to a single account using comma-separated keys (e.g., "log,security")
- Delegated services support multiple roles per service (each service can be delegated to multiple accounts)
- Each service in `delegated_services` must have at least one role specified
- Delegated services must reference roles that have corresponding accounts
- Service identifiers must end with ".aliyuncs.com"
- For Trusteeship billing, billing_account_id is required (defaults to current account if not specified)
- Tags are optional and default to empty map `{}` if not specified
- The component validates that all delegated service roles have corresponding enabled accounts
