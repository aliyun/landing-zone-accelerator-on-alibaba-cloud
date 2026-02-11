<div align="right">

**中文** | [English](README.md)

</div>

# Account Factory Account 组件

该组件用于在资源目录中创建和管理阿里云资源管理成员账号。

## 功能特性

- 在资源目录中创建成员账号
- 支持财务托管和自主结算两种计费类型
- 配置账号显示名称和标签
- 将账号放置在指定文件夹或根文件夹中

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
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | 资源目录信息 |
| [alicloud_resource_manager_account.account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_account) | resource | 成员账号 |

## 使用方法

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-a"
  display_name       = "应用 A 账号"
  parent_folder_id   = "fd-dearwxxxxxxxxxxxx"
  billing_type       = "Self-pay"
  
  tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `account_name_prefix` | 成员账号显示名称的前缀 | `string` | - | Yes | 2-50 个字符，以字母或数字开头和结尾，只能包含字母、数字、下划线、点号、连字符，不能有连续的特殊字符 |
| `display_name` | 成员账号的显示名称 | `string` | - | Yes | 2-50 个字符，可包含中文字符、字母、数字、下划线（_）、点号（.）和连字符（-） |
| `parent_folder_id` | 创建账号的父文件夹 ID | `string` | `null` | No | 如果为 null，则默认为根文件夹 |
| `billing_type` | 成员账号的计费类型 | `string` | `"Trusteeship"` | No | 必须是：`Trusteeship` 或 `Self-pay` |
| `billing_account_id` | 财务结算账号 ID | `string` | `null` | No | 当 `billing_type = "Trusteeship"` 且不使用当前主账号时必需 |
| `tags` | 分配给账号的标签 | `map(string)` | `null` | No | - |

## 输出参数

| Name | Description |
|------|-------------|
| `account_id` | 创建的成员账号 ID |
| `resource_directory_id` | 资源目录 ID |

## 使用示例

### 自主结算账号

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-a"
  display_name       = "应用 A"
  parent_folder_id   = "fd-dearwxxxxxxxxxxxx"
  billing_type       = "Self-pay"
}
```

### 财务托管账号

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "application-b"
  display_name       = "应用 B"
  parent_folder_id   = "fd-dearwxxxxxxxxxxxx"
  billing_type       = "Trusteeship"
  billing_account_id = "<ACCOUNT_ID>"
}
```

### 带标签的账号

```hcl
module "account" {
  source = "./components/account-factory/account"

  account_name_prefix = "production-app"
  display_name       = "生产环境应用"
  billing_type       = "Self-pay"
  
  tags = {
    Environment = "production"
    Team        = "platform"
    Project     = "landing-zone"
  }
}
```

## 注意事项

- 账号名称前缀在资源目录内必须唯一
- 显示名称可以包含中文字符
- 当 `billing_type = "Trusteeship"` 且 `billing_account_id` 为 null 时，使用当前主账号作为结算账号
- 如果未指定 `parent_folder_id`，账号将在根文件夹中创建
- 账号创建可能需要几分钟时间完成

