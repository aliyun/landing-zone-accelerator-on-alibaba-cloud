<div align="right">

**中文** | [English](README.md)

</div>

# SLS Project 模块

该模块用于创建和管理阿里云日志服务（SLS）项目。

## 功能特性

- 创建新的 SLS 项目或引用现有项目
- 支持随机后缀以确保项目名称唯一性
- 配置项目描述和标签

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_regions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source | 当前地域信息 |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | 项目名称的随机后缀（可选） |
| [alicloud_log_project.project](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_project) | resource | SLS 项目（当 create_project = true 时） |

## 使用方法

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "my-log-project"
  description  = "My log project"
  
  tags = {
    Environment = "production"
    Project     = "logging"
  }
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `project_name` | SLS 项目名称 | `string` | - | 是 | 3-63 个字符，必须以小写字母或数字开头和结尾，只能包含小写字母、数字和连字符 |
| `create_project` | 是否创建新的 SLS 项目 | `bool` | `true` | 否 | - |
| `append_random_suffix` | 是否在项目名称后追加随机后缀以确保唯一性 | `bool` | `false` | 否 | 仅在 `create_project = true` 时有效 |
| `random_suffix_length` | 随机后缀的长度 | `number` | `6` | 否 | 必须为 3-16 |
| `random_suffix_separator` | 项目名称和随机后缀之间的分隔符 | `string` | `"-"` | 否 | 必须为：`"-"`、`"_"` 或 `""` |
| `description` | SLS 项目描述 | `string` | `""` | 否 | - |
| `tags` | 分配给项目的标签映射 | `map(string)` | `null` | 否 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `project_name` | SLS 项目名称（如果启用了随机后缀，则包含后缀） |
| `project_description` | SLS 项目描述 |
| `project_arn` | SLS 项目的 ARN，格式：`acs:log:{region}:{account_id}:project/{project_name}` |

## 使用示例

### 基础 SLS 项目

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "my-log-project"
  description  = "Application logs"
}
```

### 带随机后缀的 SLS 项目

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name         = "my-log-project"
  append_random_suffix = true
  random_suffix_length = 8
  description          = "Application logs"
}
```

### 引用现有项目

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name  = "existing-project"
  create_project = false
}
```

### 带标签的 SLS 项目

```hcl
module "sls_project" {
  source = "./modules/sls-project"

  project_name = "production-logs"
  description  = "Production environment logs"
  
  tags = {
    Environment = "production"
    Team        = "devops"
    Project     = "landing-zone"
  }
}
```

## 注意事项

- 项目名称必须在所有阿里云账户中全局唯一
- 当可能出现项目名称冲突时，使用 `append_random_suffix` 确保唯一性
- 当 `create_project = false` 时，模块引用现有项目（项目必须存在）
- 随机后缀仅在 `create_project = true` 且 `append_random_suffix = true` 时追加
- 项目名称必须以小写字母或数字开头和结尾
- 项目名称只能包含小写字母、数字和连字符

