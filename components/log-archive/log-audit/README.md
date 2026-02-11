<div align="right">

**English** | [中文](README-CN.md)

</div>

# Log Audit Component

This component creates and manages Alibaba Cloud SLS (Simple Log Service) log audit collection policies for centralized log collection from various cloud products.

## Features

- Creates SLS project for log storage
- Creates logstores for collection policies
- Creates collection policies for various cloud products
- Supports multi-account collection via Resource Directory
- Configures centralized log transfer to SLS
- Supports different resource collection modes (all, attributeMode, instanceMode)

## Important Notes

### Provider Region Restriction

When using the `alicloud.log_audit` provider, **the region can only be set to one of the following two regions**:
- China East 2 (Shanghai): `cn-shanghai`
- Singapore: `ap-southeast-1`

This is because Alibaba Cloud SLS Log Audit service currently only supports these two regions.

### Region Restriction Impact

- **Provider Region Restriction**: Only affects the `alicloud.log_audit` provider configuration
- **Project Region**: Not affected, SLS projects can be created in any supported region
- **Log Collection Scope**: Can collect logs from cloud products across all regions, not limited by this restriction

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.log_audit | >= 1.267.0 (region must be `cn-shanghai` or `ap-southeast-1`) |
| alicloud.sls_project | >= 1.267.0 |
| random | >= 3.1.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| sls_project | ../../../modules/sls-project | SLS project for log storage |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | Log Service activation |
| [alicloud_log_projects.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_projects) | data source | Current SLS project lookup |
| [alicloud_log_store.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/log_store) | resource | Logstores for collection policies |
| [alicloud_sls_collection_policy.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sls_collection_policy) | resource | Collection policies for cloud products |

## Usage

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit  # Must use cn-shanghai or ap-southeast-1
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "log-audit-project"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
        instance_ids  = null
        regions       = null
        resource_tags = null
      }
      logstore = {
        create            = true
        retention_period  = 180
        shard_count       = 2
        auto_split        = true
        max_split_shard_count = 64
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `project_name` | Name of the destination SLS project | `string` | - | Yes | 3-63 chars, start/end with lowercase letter or digit |
| `create_project` | Whether to create the SLS project | `bool` | `false` | No | - |
| `project_description` | Description used when creating the SLS project | `string` | `null` | No | - |
| `project_tags` | Tags to apply when creating the SLS project | `map(string)` | `null` | No | - |
| `append_random_suffix` | Whether to append random suffix to project name | `bool` | `false` | No | Only when `create_project = true` |
| `random_suffix_length` | Length of random suffix | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | Separator between project name and suffix | `string` | `"-"` | No | Must be: `"-"`, `"_"`, or `""` |
| `collection_policies` | Collection policies to create | `list(object)` | `[]` | No | See collection policy structure below |

### Collection Policy Object Structure

Each policy in `collection_policies` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `policy_name` | `string` | - | Yes | Policy name | 3-63 chars, start with letter, only [a-z0-9_-] |
| `product_code` | `string` | - | Yes | Product code | See Alibaba Cloud documentation |
| `enabled` | `bool` | - | Yes | Whether policy is enabled | - |
| `data_code` | `string` | - | Yes | Log type encoding | See Alibaba Cloud documentation |
| `policy_config` | `object` | - | Yes | Policy configuration | See policy_config structure |
| `data_config` | `object` | `null` | No | Data configuration | Required for specific product_code/data_code combinations |
| `resource_directory` | `object` | See below | No | Resource directory configuration | - |
| `logstore` | `object` | - | Yes | Logstore configuration | See logstore structure |

#### Policy Config Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `resource_mode` | `string` | - | Yes | Resource collection mode | Must be: `all`, `attributeMode`, or `instanceMode` |
| `instance_ids` | `list(string)` | `null` | No | Instance IDs to collect | Required when `resource_mode = "instanceMode"` |
| `regions` | `list(string)` | `null` | No | Regions to collect | Required when `resource_mode = "attributeMode"` |
| `resource_tags` | `map(string)` | `null` | No | Resource tags | Valid when `resource_mode = "attributeMode"` |

#### Resource Directory Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `enabled` | `bool` | `true` | No | Whether to enable multi-account collection | - |
| `account_group_type` | `string` | `"all"` | No | Account group type | Must be: `all` or `custom` |
| `members` | `list(string)` | `[]` | No | Member account list | Required when `account_group_type = "custom"` |

#### Logstore Object Structure

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | `null` | No | Logstore name | Auto-generated if null. 2-63 chars |
| `create` | `bool` | `true` | No | Whether to create logstore | `name` required when `create = false` |
| `retention_period` | `number` | `30` | No | Data retention time (days) | 1-3650 |
| `shard_count` | `number` | `2` | No | Number of shards | - |
| `auto_split` | `bool` | `true` | No | Whether to auto-split shards | - |
| `max_split_shard_count` | `number` | `64` | No | Max shards for auto split | 1-256, required when `auto_split = true` |
| `mode` | `string` | `"standard"` | No | Storage mode | Must be: `standard`, `query`, or `lite` |
| `metering_mode` | `string` | `null` | No | Metering mode | Must be: `ChargeByFunction` or `ChargeByDataIngest` |
| `telemetry_type` | `string` | `null` | No | Store type | Empty for log store, `Metrics` for metric store |
| `hot_ttl` | `number` | `30` | No | TTL of hot storage (days) | >= 30, must be <= retention_period |
| `infrequent_access_ttl` | `number` | `null` | No | Low-frequency storage time (days) | - |
| `append_meta` | `bool` | `true` | No | Whether to append log meta automatically | - |

## Outputs

| Name | Description |
|------|-------------|
| `project_name` | Name of the SLS project |
| `logstore_names` | Names of created logstores (map by policy_name) |
| `collection_policy_names` | Names of created collection policies (map by policy_name) |
| `collection_policy_ids` | IDs of created collection policies (map by policy_name) |
| `collection_policy_status` | Status of collection policies (map by policy_name) |
| `collection_policies_summary` | Summary of collection policies grouped by product_code |

## Examples

### Basic Log Audit Configuration

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit  # cn-shanghai or ap-southeast-1
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
      }
      logstore = {
        create           = true
        retention_period = 180
      }
    }
  ]
}
```

### Multi-Account Collection

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "ecs-audit"
      product_code = "ecs"
      enabled      = true
      data_code    = "audit_log"
      policy_config = {
        resource_mode = "all"
      }
      resource_directory = {
        enabled            = true
        account_group_type = "all"  # Collect from all accounts
      }
      logstore = {
        create           = true
        retention_period = 180
      }
    }
  ]
}
```

### Attribute Mode Collection

```hcl
module "log_audit" {
  source = "./components/log-archive/log-audit"

  providers = {
    alicloud.log_audit = alicloud.log_audit
    alicloud.sls_project = alicloud.sls_project
  }

  project_name = "central-log-audit"
  create_project = true

  collection_policies = [
    {
      policy_name  = "waf-access"
      product_code = "waf"
      enabled      = true
      data_code    = "access_log"
      policy_config = {
        resource_mode = "attributeMode"
        regions       = ["cn-hangzhou", "cn-shanghai"]
        resource_tags = {
          Environment = "production"
        }
      }
      logstore = {
        create           = true
        retention_period = 90
      }
    }
  ]
}
```

## Notes

- **Provider Region Restriction**: `alicloud.log_audit` provider must use `cn-shanghai` or `ap-southeast-1` region
- SLS project can be created in any supported region (not limited by log_audit provider region)
- Log collection can cover all regions, not limited by provider region
- Policy names must be unique within the project
- Logstore names must be unique within the project
- For product_code and data_code values, refer to [Alibaba Cloud documentation](https://www.alibabacloud.com/help/en/sls/cloud-product-configuration-considerations)
- Some product_code/data_code combinations have specific requirements (e.g., resource_mode must be `all` or `attributeMode`)
- When `resource_mode = "attributeMode"`, `regions` is required
- When `resource_mode = "instanceMode"`, `instance_ids` is required
- Logstore name defaults to `central-{productCode}-{dataCode}-{policyName}` if not specified
- Collection policies support centralized log transfer to SLS
