<div align="right">

**中文** | [English](README.md)

</div>

# Accounts 组件

该组件用于在资源目录中创建功能账号并配置服务委托管理员。

## 功能特性

- 在指定文件夹中创建功能账号
- 支持为每个账号指定文件夹或使用默认核心文件夹
- 支持每个账号多个角色（逗号分隔的角色键）
- 配置云服务的委托管理员（支持每个服务多个角色）
- 验证账号配置和角色分配
- 支持托管和自付费两种计费类型

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_resource_manager_account.account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_account) | resource | 功能账号 |
| [alicloud_resource_manager_delegated_administrator.service_specific](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_delegated_administrator) | resource | 服务委托管理员 |
| [null_resource.validate_delegated_admin_roles](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | 验证委托管理员角色 |

## 使用方法

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "日志归档账号"
      billing_type        = "Self-pay"
      tags                = {
        Environment = "Production"
        Team        = "Platform"
      }
    }
    security = {
      account_name_prefix = "security"
      display_name        = "安全账号"
      billing_type        = "Self-pay"
      folder_id           = "fd-2ze0xxxxxxxxxxxxxxxx"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
    "log,security" = {
      account_name_prefix = "security"
      display_name        = "安全账号"
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

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `resource_directory_id` | 资源目录 ID | `string` | - | Yes | - |
| `default_folder_id` | 默认文件夹 ID，如果 account_mapping 中未指定 folder_id，则使用此值。如果未提供，账号将在根目录创建。 | `optional(string)` | `null` | No | 否 |
| `account_mapping` | 功能角色到账号的映射 | `map(object)` | 见下方 | No | 有效的账号配置 |
| `delegated_services` | 要委托为管理员的服务映射（每个服务可以有多个角色） | `map(list(string))` | 见下方 | No | 有效的服务标识符，每个服务必须至少有一个角色 |

### account_mapping 对象

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `account_name_prefix` | 账号名称前缀（2-50 个字符）。必须以字母或数字开头和结尾，只能包含字母、数字、下划线（_）、点号（.）和连字符（-），且不能包含连续的特殊字符。 | `string` | Yes |
| `display_name` | 账号显示名称（2-50 个字符）。可以包含中文字符、字母、数字、下划线（_）、点号（.）和连字符（-）。 | `string` | Yes |
| `billing_type` | 计费类型："Trusteeship" 或 "Self-pay" | `string` | No |
| `billing_account_id` | 计费账号 ID（托管计费时必需） | `string` | No |
| `folder_id` | 创建此账号的文件夹 ID | `optional(string)` | `null` | No | 如果未指定，则使用 default_folder_id。如果 default_folder_id 也未提供，账号将在根目录创建。 |
| `tags` | 账号标签 | `map(string)` | No |

### 默认 account_mapping

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

### 默认 delegated_services

包含安全、日志、运维和身份服务的委托。完整列表请参见 variables.tf。

## 输出参数

| Name | Description |
|------|-------------|
| `account_ids` | 创建的核心账号 ID 列表 |
| `accounts` | 创建的核心账号信息 |
| `role_to_account_mapping` | 各个角色到其账号 ID 的映射 |
| `delegated_services` | 服务到其委托管理员账号 ID 的映射（每个服务映射到一个账号 ID 列表，每个角色对应一个账号 ID） |

## 使用示例

### 基础账号创建

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

### 每个账号多个角色

```hcl
module "accounts" {
  source = "./components/resource-structure/accounts"

  resource_directory_id = "rd-2ze0xxxxxxxxxxxxxxxx"
  default_folder_id     = "fd-2ze0xxxxxxxxxxxxxxxx"

  account_mapping = {
    "log,security" = {
      account_name_prefix = "security"
      display_name        = "安全和日志账号"
      billing_type        = "Self-pay"
      tags                = {
        Environment = "Production"
        Team        = "Security"
      }
    }
  }
}
```

### 带服务委托

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

### 托管计费

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

### 为每个账号指定文件夹

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
      # 如果提供了 default_folder_id，则使用它；否则账号将在根目录创建
    }
  }
}
```

## 注意事项

- 可以通过在 `account_mapping` 中指定 `folder_id` 来在不同文件夹中创建账号
- 如果 `account_mapping` 中未指定 `folder_id`，账号将在 `default_folder_id`（如果提供）或根目录创建
- 优先级：`account_mapping` 中的 `folder_id` 优先于 `default_folder_id`
- 可以使用逗号分隔的键为单个账号分配多个角色（例如 "log,security"）
- 委托服务支持每个服务多个角色（每个服务可以委托给多个账号）
- `delegated_services` 中的每个服务必须至少指定一个角色
- 委托服务必须引用具有对应账号的角色
- 服务标识符必须以 ".aliyuncs.com" 结尾
- 对于托管计费，需要 billing_account_id（如果未指定，默认为当前账号）
- 标签（tags）为可选，如果未指定则默认为空 map `{}`
- 组件会验证所有委托服务角色都有对应的已启用账号
