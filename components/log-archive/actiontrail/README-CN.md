<div align="right">

**中文** | [English](README.md)

</div>

# ActionTrail 组件

该组件用于创建和管理阿里云操作审计（ActionTrail）跟踪，支持可选的 OSS 和 SLS 投递用于日志存储。

## 功能特性

- 创建操作审计跟踪用于操作审计
- 支持 OSS 投递用于日志存储
- 支持 SLS 投递用于日志存储
- 配置 OSS 存储桶的加密和冗余选项
- 配置 SLS 项目用于日志收集
- 支持多账号跟踪（组织跟踪）
- 自动开通所需服务（OSS、SLS）

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| alicloud.log_archive | >= 1.262.1 |
| alicloud.oss | >= 1.262.1 |
| alicloud.sls | >= 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| oss_bucket | ../../../modules/oss-bucket | ActionTrail 日志的 OSS 存储桶（可选） |
| sls_project | ../../../modules/sls-project | ActionTrail 日志的 SLS 项目（可选） |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | 日志服务开通 |
| [alicloud_oss_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/oss_service) | data source | OSS 服务开通 |
| [alicloud_actiontrail_trail.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/actiontrail_trail) | resource | ActionTrail 跟踪 |

## 使用方法

```hcl
module "actiontrail" {
  source = "./components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  trail_name         = "landingzone-actiontrail"
  trail_status       = "Enable"
  event_type         = "Write"
  trail_region       = "All"
  is_organization_trail = false

  enable_oss_delivery = true
  enable_sls_delivery = true

  oss_bucket_name = "actiontrail-logs"
  sls_project_name = "actiontrail-logs"
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_oss_delivery` | 是否启用 OSS 投递 | `bool` | `false` | No | - |
| `enable_sls_delivery` | 是否启用 SLS 投递 | `bool` | `false` | No | - |
| `trail_name` | ActionTrail 跟踪名称 | `string` | `"landingzone-actiontrail"` | No | - |
| `trail_status` | 跟踪状态 | `string` | `"Enable"` | No | 必须是：`Enable` 或 `Disable` |
| `event_type` | 要记录的事件类型 | `string` | `"Write"` | No | 必须是：`Write`、`Read` 或 `All` |
| `trail_region` | 跟踪所属的地域 | `string` | `"All"` | No | 使用 `All` 表示全局跟踪 |
| `is_organization_trail` | 是否创建多账号跟踪 | `bool` | `false` | No | - |
| `oss_bucket_name` | OSS 存储桶名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成 |
| `append_random_suffix` | 是否在资源名称后追加随机后缀 | `bool` | `false` | No | - |
| `random_suffix_length` | 随机后缀长度 | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | 资源名称和后缀之间的分隔符 | `string` | `"-"` | No | 必须是：`"-"`、`"_"` 或 `""` |
| `oss_server_side_encryption_enabled` | 是否启用 OSS 服务端加密 | `bool` | `true` | No | - |
| `oss_server_side_encryption_algorithm` | 服务端加密算法 | `string` | `"AES256"` | No | 必须是：`AES256` 或 `KMS` |
| `oss_write_role_arn` | ActionTrail 写入 OSS 的 RAM 角色 ARN | `string` | `null` | No | 如果为 null，使用默认服务角色 |
| `oss_force_destroy` | 是否强制删除 OSS 存储桶 | `bool` | `true` | No | - |
| `oss_kms_master_key_id` | SSE-KMS 加密的 KMS 主密钥 ID | `string` | `null` | No | 当加密算法为 KMS 时必需 |
| `oss_kms_data_encryption` | 加密对象的算法 | `string` | `null` | No | 必须是：`SM4`（仅在 SSEAlgorithm 为 KMS 时） |
| `oss_redundancy_type` | OSS 冗余类型 | `string` | `"ZRS"` | No | 必须是：`LRS` 或 `ZRS` |
| `sls_project_name` | SLS 项目名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成。3-63 个字符 |
| `sls_create_project` | 是否创建新的 SLS 项目 | `bool` | `true` | No | - |
| `sls_project_description` | SLS 项目描述 | `string` | `"ActionTrail logs storage"` | No | - |
| `sls_write_role_arn` | ActionTrail 写入 SLS 的 RAM 角色 ARN | `string` | `null` | No | 如果为 null，使用默认服务角色 |
| `tags` | 分配给所有资源的标签 | `map(string)` | `{}` | No | - |

## 输出参数

| Name | Description |
|------|-------------|
| `trail_name` | ActionTrail 跟踪名称 |
| `trail_id` | ActionTrail 跟踪 ID |
| `oss_bucket_name` | OSS 存储桶名称（如果已启用） |
| `sls_project_name` | SLS 项目名称（如果已启用） |

## 使用示例

### 基础 ActionTrail 配置 OSS 投递

```hcl
module "actiontrail" {
  source = "./components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
  }

  trail_name = "my-actiontrail"
  enable_oss_delivery = true
  oss_bucket_name = "actiontrail-logs"
}
```

### ActionTrail 配置 OSS 和 SLS 投递

```hcl
module "actiontrail" {
  source = "./components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  trail_name = "comprehensive-actiontrail"
  enable_oss_delivery = true
  enable_sls_delivery = true
  
  oss_bucket_name = "actiontrail-oss"
  oss_redundancy_type = "ZRS"
  
  sls_project_name = "actiontrail-sls"
  sls_create_project = true
}
```

### 组织跟踪

```hcl
module "actiontrail" {
  source = "./components/log-archive/actiontrail"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
  }

  trail_name = "org-actiontrail"
  is_organization_trail = true
  enable_oss_delivery = true
}
```

## 注意事项

- 创建资源前会自动开通 OSS 和 SLS 服务
- 至少应启用一种投递方式（OSS 或 SLS）
- 如果未指定，使用默认服务角色进行 OSS/SLS 写入操作
- 如果未指定 OSS 存储桶名称，默认为 `actiontrail-{account_id}`
- 如果未指定 SLS 项目名称，默认为 `actiontrail-{account_id}`
- 可以追加随机后缀以确保全局唯一性
- 组织跟踪支持跨资源目录的多账号日志记录

