<div align="right">

**中文** | [English](README.md)

</div>

# SLS Logstore 模块

该模块用于在现有的阿里云日志服务（SLS）项目中创建和管理日志库（Logstore）。支持创建新的日志库或引用现有的日志库。

## 功能特性

- 创建新日志库或引用现有日志库
- 配置数据保留期（1-3650 天）
- 配置分片数量和自动分裂设置
- 支持多种存储模式（标准、查询、轻量）
- 配置计费模式（按函数调用或按数据写入量）
- 支持指标库配置
- 配置热存储和低频访问 TTL
- 引用现有日志库时验证其存在性

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
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_regions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source | 当前地域信息 |
| [alicloud_log_stores.existing](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_stores) | data source | 现有日志库查询（当 create_logstore = false 时） |
| [alicloud_log_store.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource | SLS 日志库（当 create_logstore = true 时） |
| [null_resource.assert_existing_logstore_found](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | 验证资源，确保现有日志库存在 |

## 使用方法

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name = "my-log-project"
  logstore_name = "my-logstore"
  
  retention_period = 30
  shard_count = 2
  auto_split = false
  mode = "standard"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `project_name` | 承载日志库的目标 SLS 项目名称 | `string` | - | 是 | 3-63 个字符，必须以小写字母或数字开头和结尾，只能包含小写字母、数字和连字符 |
| `create_logstore` | 是否创建日志库（true）或使用现有日志库（false） | `bool` | `true` | 否 | - |
| `logstore_name` | 要创建或引用的日志库名称 | `string` | - | 是 | 2-63 个字符，必须以小写字母或数字开头和结尾，只能包含小写字母、数字、连字符和下划线 |
| `retention_period` | 数据保留时间（天） | `number` | `30` | 否 | 必须为 1-3650 天 |
| `shard_count` | 分片数量 | `number` | `2` | 否 | - |
| `auto_split` | 是否自动分裂分片 | `bool` | `false` | 否 | - |
| `max_split_shard_count` | 自动分裂的最大分片数 | `number` | `null` | 否 | 当 `auto_split` 为 true 时必须为 1-256 |
| `mode` | 存储模式 | `string` | `"standard"` | 否 | 必须为：`standard`、`query`、`lite` 之一 |
| `metering_mode` | 计费模式 | `string` | `null` | 否 | 不为 null 时必须为 `ChargeByFunction` 或 `ChargeByDataIngest` |
| `telemetry_type` | 存储类型：空值表示日志库，Metrics 表示指标库 | `string` | `null` | 否 | - |
| `hot_ttl` | 热存储 TTL（天） | `number` | `30` | 否 | 必须 >= 30 且 <= retention_period |
| `infrequent_access_ttl` | 低频存储时间（天） | `number` | `null` | 否 | - |
| `append_meta` | 是否自动追加日志元数据 | `bool` | `true` | 否 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `logstore_name` | 日志库名称 |
| `logstore_arn` | 日志库的 ARN，格式：`acs:log:{region}:{account_id}:project/{project_name}/logstore/{logstore_name}` |

## 使用示例

### 创建新日志库

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name  = "my-log-project"
  logstore_name = "application-logs"
  
  retention_period = 90
  shard_count      = 4
  auto_split       = true
  max_split_shard_count = 16
  mode             = "standard"
}
```

### 引用现有日志库

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name    = "my-log-project"
  create_logstore = false
  logstore_name   = "existing-logstore"
}
```

### 查询模式日志库

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name  = "my-log-project"
  logstore_name = "query-logs"
  
  mode            = "query"
  retention_period = 180
  hot_ttl         = 60
}
```

### 指标库

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name  = "my-log-project"
  logstore_name = "metrics"
  
  telemetry_type = "Metrics"
  mode           = "standard"
  retention_period = 365
}
```

### 带自动分裂的日志库

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name  = "my-log-project"
  logstore_name = "high-volume-logs"
  
  shard_count         = 2
  auto_split          = true
  max_split_shard_count = 32
  retention_period    = 30
}
```

## 注意事项

- `project_name` 中指定的项目必须在创建日志库之前存在
- 当 `create_logstore = false` 时，模块会验证日志库是否存在于指定项目中
- 当 `auto_split` 为 `true` 时，必须提供 `max_split_shard_count`
- `hot_ttl` 必须至少为 30 天，且不能超过 `retention_period`
- 存储模式：
  - **standard**：标准日志存储模式
  - **query**：针对查询性能优化
  - **lite**：轻量级存储模式，功能较少
- 计费模式：
  - **ChargeByFunction**：按函数调用计费
  - **ChargeByDataIngest**：按数据写入量计费
- 当 `telemetry_type` 设置为 `"Metrics"` 时，日志库将变为指标库

