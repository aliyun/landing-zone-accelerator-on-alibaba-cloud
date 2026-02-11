<div align="right">

**中文** | [English](README.md)

</div>

# Guardrails Preventive 组件

该组件用于创建和管理阿里云资源管理控制策略，实现预防性防护规则，在资源创建前强制执行合规性。

## 功能特性

- 创建资源管理控制策略
- 将策略附加到文件夹、账号或根文件夹
- 支持从文件（JSON/YAML）加载配置或内联定义
- 自动将文件夹名称和账号显示名称解析为 ID
- 支持将策略附加到根文件夹

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
| [alicloud_resource_manager_resource_directories.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_resource_directories) | data source | 资源目录信息（用于根文件夹） |
| [alicloud_resource_manager_folders.by_name](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_folders) | data source | 按名称查询文件夹 |
| [alicloud_resource_manager_folders.by_regex](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_folders) | data source | 按正则表达式查询文件夹 |
| [alicloud_resource_manager_accounts.all](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/resource_manager_accounts) | data source | 查询所有账号 |
| [alicloud_resource_manager_control_policy.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_control_policy) | resource | 控制策略 |
| [alicloud_resource_manager_control_policy_attachment.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_control_policy_attachment) | resource | 策略到目标的附加 |

## 使用方法

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "PreventPublicAccess"
      description = "防止资源公网访问"
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

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `control_policies` | 要创建的控制策略及其附加的列表 | `list(object)` | `[]` | No | 参见控制策略结构 |
| `control_policies_dir` | 包含控制策略配置文件的目录路径 | `string` | `null` | No | JSON/YAML 文件，与 `control_policies` 合并 |

### 控制策略对象结构

`control_policies` 中每个策略必须具有以下结构：

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | 策略名称 | 1-128 个字符 |
| `description` | `string` | `null` | No | 策略描述 | - |
| `policy_document` | `string` | - | Yes | 策略文档（JSON 字符串） | 有效的 JSON |
| `tags` | `map(string)` | `{}` | No | 控制策略的标签 | 最多 20 个标签 |
| `target_ids` | `list(string)` | `[]` | No | 目标文件夹/账号 ID | - |
| `target_account_display_names` | `list(string)` | `[]` | No | 目标账号显示名称 | - |
| `target_folder_names` | `list(string)` | `[]` | No | 目标文件夹名称 | 注意：不同级别的同名文件夹都会被绑定 |
| `target_folder_name_regexes` | `list(string)` | `[]` | No | 用于匹配文件夹名称的正则表达式 | 所有匹配的文件夹都会被绑定，与其他目标字段合并 |
| `attach_to_root` | `bool` | `false` | No | 是否附加到根文件夹 | - |

**注意**：所有目标字段都是可选的。您可以创建不绑定任何目标的控制策略。策略将被创建，但不会创建任何绑定。目标字段（`target_ids`、`target_folder_names`、`target_folder_name_regexes`、`target_account_display_names`）会为每个策略合并并去重。

## 输出参数

| Name | Description |
|------|-------------|
| `policies` | 控制策略及其附加的列表 |

## 使用示例

### 将策略附加到文件夹

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "ProductionPolicy"
      description = "生产环境文件夹策略"
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

### 将策略附加到根文件夹

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "GlobalPolicy"
      description = "全局资源策略"
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

### 使用目标 ID 进行精确控制

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "SpecificFolderPolicy"
      description = "特定文件夹策略"
      policy_document = jsonencode({...})
      target_ids = ["fd-2ze0xxxxxxxxxxxxxxxx", "fd-2ze0xxxxxxxxxxxxxxxx"]
    }
  ]
}
```

### 使用正则表达式匹配文件夹

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "ProductionFoldersPolicy"
      description = "所有生产环境文件夹的策略"
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

### 创建带标签的策略

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "TaggedPolicy"
      description = "带标签的策略"
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

### 创建不绑定目标的策略

您可以创建不绑定任何目标的控制策略。策略将被创建，但不会创建任何附加：

```hcl
module "preventive_guardrails" {
  source = "./components/guardrails/preventive"

  control_policies = [
    {
      name        = "UnattachedPolicy"
      description = "创建时不绑定目标的策略"
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
      # 不设置 target_ids, target_folder_names, target_folder_name_regexes, target_account_display_names 或 attach_to_root
    }
  ]
}
```

## 注意事项

- 控制策略在资源创建前强制执行合规性
- 文件夹可以在不同级别使用相同名称 - 所有匹配的文件夹都会被绑定
- 要进行精确控制，建议使用 `target_ids` 指定文件夹 ID 而不是名称
- `target_folder_name_regexes` 使用正则表达式模式匹配文件夹名称 - 所有匹配的文件夹都会被绑定
- 目标字段（`target_ids`、`target_folder_names`、`target_folder_name_regexes`、`target_account_display_names`）会为每个策略合并并去重
- 策略文档必须是有效的 JSON
- 文件配置优先于内联配置（同名时）
- 策略创建后附加到目标（文件夹、账号或根文件夹）

