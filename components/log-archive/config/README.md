<div align="right">

**English** | [中文](README-CN.md)

</div>

# Config Log Archive Component

This component creates and manages Alibaba Cloud Config log archive configuration, including aggregator creation and delivery channels to OSS and SLS.

## Features

- Creates Config aggregators (RD, FOLDER, or CUSTOM type)
- Configures OSS delivery channel for Config snapshots and change notifications
- Configures SLS delivery channel for Config snapshots and change notifications
- Creates OSS bucket with encryption and redundancy options
- Creates SLS project and logstore for log storage
- Supports using existing aggregators
- Automatically enables required services (Config, OSS, SLS)

## Requirements

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
| enable_config_service | ../../../modules/config-configuration-recorder | Enable Config service |
| oss_bucket | ../../../modules/oss-bucket | OSS bucket for Config delivery (optional) |
| sls_project | ../../../modules/sls-project | SLS project for Config delivery (optional) |
| sls_logstore | ../../../modules/sls-logstore | SLS logstore for Config delivery (optional) |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | Log Service activation |
| [alicloud_oss_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/oss_service) | data source | OSS Service activation |
| [alicloud_config_aggregator.aggregator](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregator) | resource | Config aggregator (optional, when not using existing) |
| [alicloud_config_aggregate_delivery.oss](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_delivery) | resource | OSS aggregate delivery channel (optional) |
| [alicloud_config_aggregate_delivery.sls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_delivery) | resource | SLS aggregate delivery channel (optional) |

## Usage

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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_oss_delivery` | Whether to enable OSS delivery | `bool` | `true` | No | - |
| `enable_sls_delivery` | Whether to enable SLS delivery | `bool` | `true` | No | - |
| `oss_bucket_name` | The name of the OSS bucket | `string` | `null` | No | If null, generated from account ID |
| `append_random_suffix` | Whether to append random suffix to resource names | `bool` | `false` | No | - |
| `random_suffix_length` | Length of random suffix | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | Separator between resource names and suffix | `string` | `"-"` | No | Must be: `"-"`, `"_"`, or `""` |
| `oss_bucket_force_destroy` | Whether to force destroy OSS bucket | `bool` | `false` | No | - |
| `oss_bucket_versioning` | Whether to enable OSS bucket versioning | `bool` | `true` | No | - |
| `oss_bucket_tags` | Tags for OSS bucket | `map(string)` | `{}` | No | - |
| `oss_bucket_storage_class` | OSS bucket storage class | `string` | `"Standard"` | No | - |
| `oss_bucket_acl` | OSS bucket ACL | `string` | `"private"` | No | - |
| `oss_bucket_redundancy_type` | OSS redundancy type | `string` | `"ZRS"` | No | Must be: `LRS` or `ZRS` |
| `oss_bucket_server_side_encryption_enabled` | Whether to enable server-side encryption | `bool` | `true` | No | - |
| `oss_bucket_server_side_encryption_algorithm` | Server-side encryption algorithm | `string` | `"AES256"` | No | Must be: `AES256` or `KMS` |
| `oss_bucket_kms_master_key_id` | KMS master key ID for SSE-KMS | `string` | `null` | No | Required when encryption algorithm is KMS |
| `oss_bucket_kms_data_encryption` | Algorithm to encrypt objects | `string` | `null` | No | Must be: `SM4` (only when SSEAlgorithm is KMS) |
| `oss_delivery_channel_name` | The name of the OSS delivery channel | `string` | `null` | No | - |
| `sls_project_name` | The name of the SLS project | `string` | `null` | No | If null, generated from account ID. 3-63 chars |
| `sls_create_project` | Whether to create a new SLS project | `bool` | `true` | No | - |
| `sls_project_description` | The description of the SLS project | `string` | `"Config delivery project"` | No | - |
| `sls_project_tags` | Tags for SLS project | `map(string)` | `{}` | No | - |
| `sls_logstore_create` | Whether to create the SLS logstore | `bool` | `true` | No | - |
| `sls_logstore_name` | Name of the SLS logstore | `string` | `null` | No | If null, generated from account ID. 2-63 chars |
| `sls_logstore_retention_period` | SLS logstore retention period (days) | `number` | `180` | No | 1-3650 |
| `sls_logstore_shard_count` | SLS logstore shard count | `number` | `2` | No | - |
| `sls_logstore_auto_split` | Whether SLS logstore automatically split shards | `bool` | `true` | No | - |
| `sls_logstore_max_split_shard_count` | Max shards for auto split | `number` | `64` | No | 1-256 |
| `sls_logstore_mode` | Storage mode | `string` | `"standard"` | No | Must be: `standard`, `query`, or `lite` |
| `sls_logstore_metering_mode` | Metering mode | `string` | `null` | No | Must be: `ChargeByFunction` or `ChargeByDataIngest` |
| `sls_logstore_telemetry_type` | Store type | `string` | `null` | No | Empty for log store, `Metrics` for metric store |
| `sls_logstore_hot_ttl` | TTL of hot storage (days) | `number` | `30` | No | >= 30 |
| `sls_logstore_infrequent_access_ttl` | Low-frequency storage time (days) | `number` | `null` | No | - |
| `sls_logstore_append_meta` | Whether to append log meta automatically | `bool` | `true` | No | - |
| `sls_delivery_channel_name` | The name of the SLS delivery channel | `string` | `null` | No | - |
| `use_existing_aggregator` | Whether to use an existing config aggregator | `bool` | `false` | No | - |
| `existing_aggregator_id` | The ID of existing aggregator to use | `string` | `null` | No | Required when `use_existing_aggregator = true` |
| `config_aggregator_name` | The name of the config aggregator | `string` | `"enterprise"` | No | - |
| `config_aggregator_description` | The description of the config aggregator | `string` | `""` | No | 1-256 characters if not empty |
| `config_aggregator_type` | The type of the config aggregator | `string` | `"RD"` | No | Must be: `RD`, `FOLDER`, or `CUSTOM` |
| `config_aggregator_folder_id` | The folder ID for FOLDER type aggregator | `string` | `null` | No | Required when `config_aggregator_type = "FOLDER"` |

## Outputs

| Name | Description |
|------|-------------|
| `oss_bucket_name` | The name of the OSS bucket |
| `oss_extranet_endpoint` | The extranet access endpoint of the OSS bucket |
| `oss_intranet_endpoint` | The intranet access endpoint of the OSS bucket |
| `sls_project_name` | The name of the SLS project |
| `sls_project_description` | The description of the SLS project |
| `sls_logstore_name` | The name of the logstore |
| `sls_retention_period` | The retention period of the logstore |
| `config_aggregator_id` | The ID of the config aggregator |
| `config_aggregator_name` | The name of the config aggregator |
| `config_delivery_channel_ids` | The IDs of the config delivery channels |

## Examples

### Basic Config Log Archive with OSS and SLS

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

### Use Existing Aggregator

```hcl
module "config_log_archive" {
  source = "./components/log-archive/config"

  providers = {
    alicloud.log_archive = alicloud.log_archive
    alicloud.sls         = alicloud.sls
  }

  use_existing_aggregator = true
  existing_aggregator_id  = "ca-xxxxxxxxxxxxxxxxx"
  
  enable_sls_delivery = true
  sls_project_name = "config-delivery-project"
}
```

### OSS Only Delivery

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

## Notes

- Config, OSS, and SLS services are automatically enabled before creating resources
- At least one delivery method (OSS or SLS) should be enabled
- RD type aggregator automatically includes all accounts in the resource directory
- Only one RD type aggregator can exist per account
- OSS bucket name defaults to `config-{account_id}` if not specified
- SLS project name defaults to `config-{account_id}` if not specified
- SLS logstore name defaults to `cloudconfig_{account_id}` if not specified
- SLS logstore retention period defaults to 180 days
- Please refer to `components/guardrails/detective` to avoid duplicate aggregator creation
