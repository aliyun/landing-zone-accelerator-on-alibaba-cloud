<div align="right">

**English** | [中文](README-CN.md)

</div>

# SLS Logstore Module

This module creates and manages Alibaba Cloud Simple Log Service (SLS) logstores within an existing SLS project. It supports both creating new logstores and referencing existing ones.

## Features

- Creates new logstore or references existing logstore
- Configures data retention period (1-3650 days)
- Configures shard count and auto-split settings
- Supports multiple storage modes (standard, query, lite)
- Configures metering mode (ChargeByFunction or ChargeByDataIngest)
- Supports metric store configuration
- Configures hot storage and infrequent access TTL
- Validates existing logstore existence when referencing

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
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_regions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source | Current region information |
| [alicloud_log_stores.existing](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_stores) | data source | Existing logstore lookup (when create_logstore = false) |
| [alicloud_log_store.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource | SLS logstore (when create_logstore = true) |
| [null_resource.assert_existing_logstore_found](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource | Validation resource to ensure existing logstore exists |

## Usage

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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `project_name` | Name of the destination SLS project to host the logstore | `string` | - | Yes | 3-63 characters, start/end with lowercase letter or digit, only lowercase letters, digits and hyphens |
| `create_logstore` | Whether to create the logstore (true) or use an existing one (false) | `bool` | `true` | No | - |
| `logstore_name` | Name of the logstore to create or reference | `string` | - | Yes | 2-63 characters, start/end with lowercase letter or digit, only lowercase letters, digits, hyphens and underscores |
| `retention_period` | Data retention time in days | `number` | `30` | No | Must be between 1 and 3650 days |
| `shard_count` | Number of shards | `number` | `2` | No | - |
| `auto_split` | Whether to automatically split a shard | `bool` | `false` | No | - |
| `max_split_shard_count` | Maximum number of shards for auto split | `number` | `null` | No | Must be 1-256 when `auto_split` is true |
| `mode` | Storage mode | `string` | `"standard"` | No | Must be one of: `standard`, `query`, `lite` |
| `metering_mode` | Metering mode | `string` | `null` | No | Must be `ChargeByFunction` or `ChargeByDataIngest` when not null |
| `telemetry_type` | Store type: empty for log store, Metrics for metric store | `string` | `null` | No | - |
| `hot_ttl` | TTL of hot storage in days | `number` | `30` | No | Must be >= 30 and <= retention_period |
| `infrequent_access_ttl` | Low-frequency storage time in days | `number` | `null` | No | - |
| `append_meta` | Whether to append log meta automatically | `bool` | `true` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `logstore_name` | The name of the logstore |
| `logstore_arn` | The ARN of the logstore in format: `acs:log:{region}:{account_id}:project/{project_name}/logstore/{logstore_name}` |

## Examples

### Create New Logstore

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

### Reference Existing Logstore

```hcl
module "sls_logstore" {
  source = "./modules/sls-logstore"

  project_name    = "my-log-project"
  create_logstore = false
  logstore_name   = "existing-logstore"
}
```

### Logstore with Query Mode

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

### Metric Store

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

### Logstore with Auto-Split

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

## Notes

- The project specified in `project_name` must exist before creating the logstore
- When `create_logstore = false`, the module validates that the logstore exists in the specified project
- `max_split_shard_count` is required when `auto_split` is `true`
- `hot_ttl` must be at least 30 days and cannot exceed `retention_period`
- Storage modes:
  - **standard**: Standard log storage mode
  - **query**: Optimized for query performance
  - **lite**: Lightweight storage mode with reduced features
- Metering modes:
  - **ChargeByFunction**: Pay by function calls
  - **ChargeByDataIngest**: Pay by data ingestion volume
- When `telemetry_type` is set to `"Metrics"`, the logstore becomes a metric store

