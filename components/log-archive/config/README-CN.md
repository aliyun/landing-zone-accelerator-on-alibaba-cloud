<div align="right">

**中文** | [English](README.md)

</div>

# Config Log Archive 组件

该组件用于创建和管理阿里云配置审计日志归档配置，包括聚合器创建和到 OSS 和 SLS 的投递通道。

## 功能特性

- 创建配置聚合器（RD、FOLDER 或 CUSTOM 类型）
- 配置 OSS 投递通道用于配置快照和变更通知
- 配置 SLS 投递通道用于配置快照和变更通知
- 创建 OSS 存储桶，支持加密和冗余选项
- 创建 SLS 项目和日志库用于日志存储
- 支持使用现有聚合器
- 自动开通所需服务（Config、OSS、SLS）

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.log_archive | >= 1.267.0 |
| alicloud.oss | >= 1.267.0 |
| alicloud.sls | >= 1.267.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| enable_config_service | ../../../modules/config-configuration-recorder | 开通配置审计服务 |
| oss_bucket | ../../../modules/oss-bucket | Config 投递的 OSS 存储桶（可选） |
| sls_project | ../../../modules/sls-project | Config 投递的 SLS 项目（可选） |
| sls_logstore | ../../../modules/sls-logstore | Config 投递的 SLS 日志库（可选） |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | 日志服务开通 |
| [alicloud_oss_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/oss_service) | data source | OSS 服务开通 |
| [alicloud_config_aggregator.aggregator](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregator) | resource | 配置聚合器（可选，当不使用现有聚合器时） |
| [alicloud_config_aggregate_delivery.oss](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_delivery) | resource | OSS 聚合投递通道（可选） |
| [alicloud_config_aggregate_delivery.sls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_delivery) | resource | SLS 聚合投递通道（可选） |

## 使用方法

```hcl
module "config_log_archive" {
  source = "./components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  enable_oss_delivery = true
  enable_sls_delivery = true

  oss_bucket_name = "config-delivery-bucket"
  sls_project_name = "config-delivery-project"
  sls_logstore_name = "cloudconfig_logs"

  config_aggregator_name = "enterprise"
  config_aggregator_type = "RD"
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_oss_delivery` | 是否启用 OSS 投递 | `bool` | `true` | No | - |
| `enable_sls_delivery` | 是否启用 SLS 投递 | `bool` | `true` | No | - |
| `oss_bucket_name` | OSS 存储桶名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成 |
| `append_random_suffix` | 是否在资源名称后追加随机后缀 | `bool` | `false` | No | - |
| `random_suffix_length` | 随机后缀长度 | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | 资源名称和后缀之间的分隔符 | `string` | `"-"` | No | 必须是：`"-"`、`"_"` 或 `""` |
| `oss_bucket_force_destroy` | 是否强制删除 OSS 存储桶 | `bool` | `false` | No | - |
| `oss_bucket_versioning` | 是否启用 OSS 存储桶版本控制 | `bool` | `true` | No | - |
| `oss_bucket_tags` | OSS 存储桶标签 | `map(string)` | `{}` | No | - |
| `oss_bucket_storage_class` | OSS 存储桶存储类型 | `string` | `"Standard"` | No | - |
| `oss_bucket_acl` | OSS 存储桶 ACL | `string` | `"private"` | No | - |
| `oss_bucket_redundancy_type` | OSS 冗余类型 | `string` | `"ZRS"` | No | 必须是：`LRS` 或 `ZRS` |
| `oss_bucket_server_side_encryption_enabled` | 是否启用服务端加密 | `bool` | `true` | No | - |
| `oss_bucket_server_side_encryption_algorithm` | 服务端加密算法 | `string` | `"AES256"` | No | 必须是：`AES256` 或 `KMS` |
| `oss_bucket_kms_master_key_id` | SSE-KMS 的 KMS 主密钥 ID | `string` | `null` | No | 当加密算法为 KMS 时必需 |
| `oss_bucket_kms_data_encryption` | 加密对象的算法 | `string` | `null` | No | 必须是：`SM4`（仅在 SSEAlgorithm 为 KMS 时） |
| `oss_delivery_channel_name` | OSS 投递通道名称 | `string` | `null` | No | - |
| `sls_project_name` | SLS 项目名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成。3-63 个字符 |
| `sls_create_project` | 是否创建新的 SLS 项目 | `bool` | `true` | No | - |
| `sls_project_description` | SLS 项目描述 | `string` | `"Config delivery project"` | No | - |
| `sls_project_tags` | SLS 项目标签 | `map(string)` | `{}` | No | - |
| `sls_logstore_create` | 是否创建 SLS 日志库 | `bool` | `true` | No | - |
| `sls_logstore_name` | SLS 日志库名称 | `string` | `null` | No | 如果为 null，则从账号 ID 生成。2-63 个字符 |
| `sls_logstore_retention_period` | SLS 日志库保留期（天） | `number` | `180` | No | 1-3650 |
| `sls_logstore_shard_count` | SLS 日志库分片数 | `number` | `2` | No | - |
| `sls_logstore_auto_split` | SLS 日志库是否自动分裂分片 | `bool` | `true` | No | - |
| `sls_logstore_max_split_shard_count` | 自动分裂的最大分片数 | `number` | `64` | No | 1-256 |
| `sls_logstore_mode` | 存储模式 | `string` | `"standard"` | No | 必须是：`standard`、`query` 或 `lite` |
| `sls_logstore_metering_mode` | 计费模式 | `string` | `null` | No | 必须是：`ChargeByFunction` 或 `ChargeByDataIngest` |
| `sls_logstore_telemetry_type` | 存储类型 | `string` | `null` | No | 空表示日志库，`Metrics` 表示指标库 |
| `sls_logstore_hot_ttl` | 热存储 TTL（天） | `number` | `30` | No | >= 30 |
| `sls_logstore_infrequent_access_ttl` | 低频存储时间（天） | `number` | `null` | No | - |
| `sls_logstore_append_meta` | 是否自动追加日志元数据 | `bool` | `true` | No | - |
| `sls_delivery_channel_name` | SLS 投递通道名称 | `string` | `null` | No | - |
| `use_existing_aggregator` | 是否使用现有配置聚合器 | `bool` | `false` | No | - |
| `existing_aggregator_id` | 要使用的现有聚合器 ID | `string` | `null` | No | 当 `use_existing_aggregator = true` 时必需 |
| `config_aggregator_name` | 配置聚合器名称 | `string` | `"enterprise"` | No | - |
| `config_aggregator_description` | 配置聚合器描述 | `string` | `""` | No | 非空时 1-256 个字符 |
| `config_aggregator_type` | 配置聚合器类型 | `string` | `"RD"` | No | 必须是：`RD`、`FOLDER` 或 `CUSTOM` |
| `config_aggregator_folder_id` | FOLDER 类型聚合器的文件夹 ID | `string` | `null` | No | 当 `config_aggregator_type = "FOLDER"` 时必需 |

## 输出参数

| Name | Description |
|------|-------------|
| `oss_bucket_name` | OSS 存储桶名称 |
| `oss_extranet_endpoint` | OSS 存储桶外网访问端点 |
| `oss_intranet_endpoint` | OSS 存储桶内网访问端点 |
| `sls_project_name` | SLS 项目名称 |
| `sls_project_description` | SLS 项目描述 |
| `sls_logstore_name` | 日志库名称 |
| `sls_retention_period` | 日志库保留期 |
| `config_aggregator_id` | 配置聚合器 ID |
| `config_aggregator_name` | 配置聚合器名称 |
| `config_delivery_channel_ids` | 配置投递通道 ID 列表 |

## 使用示例

### 基础 Config 日志归档配置 OSS 和 SLS

```hcl
module "config_log_archive" {
  source = "./components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
    alicloud.sls         = alicloud.sls
  }

  enable_oss_delivery = true
  enable_sls_delivery = true

  oss_bucket_name = "config-delivery-bucket"
  sls_project_name = "config-delivery-project"
}
```

### 使用现有聚合器

```hcl
module "config_log_archive" {
  source = "./components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.sls         = alicloud.sls
  }

  use_existing_aggregator = true
  existing_aggregator_id  = "ca-2ze0xxxxxxxxxxxxxxxxx"
  
  enable_sls_delivery = true
  sls_project_name = "config-delivery-project"
}
```

### 仅 OSS 投递

```hcl
module "config_log_archive" {
  source = "./components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.oss         = alicloud.oss
  }

  enable_oss_delivery = true
  enable_sls_delivery = false

  oss_bucket_name = "config-delivery-bucket"
  oss_bucket_redundancy_type = "ZRS"
}
```

## 注意事项

- 创建资源前会自动开通 Config、OSS 和 SLS 服务
- 至少应启用一种投递方式（OSS 或 SLS）
- RD 类型聚合器自动包含资源目录中的所有账号
- 每个账号只能有一个 RD 类型聚合器
- 如果未指定 OSS 存储桶名称，默认为 `config-{account_id}`
- 如果未指定 SLS 项目名称，默认为 `config-{account_id}`
- 如果未指定 SLS 日志库名称，默认为 `cloudconfig_{account_id}`
- SLS 日志库保留期默认为 180 天
- 请参考 `components/guardrails/detective` 以避免重复创建聚合器

