<div align="right">

**English** | [中文](README-CN.md)

</div>

# ActionTrail Component

This component creates and manages Alibaba Cloud ActionTrail trails for operational auditing, with optional OSS and SLS delivery for log storage.

## Features

- Creates ActionTrail trails for operational auditing
- Supports OSS delivery for log storage
- Supports SLS delivery for log storage
- Configures OSS bucket with encryption and redundancy options
- Configures SLS project for log collection
- Supports multi-account trails (organization trails)
- Automatically enables required services (OSS, SLS)

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
| oss_bucket | ../../../modules/oss-bucket | OSS bucket for ActionTrail logs (optional) |
| sls_project | ../../../modules/sls-project | SLS project for ActionTrail logs (optional) |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_log_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/log_service) | data source | Log Service activation |
| [alicloud_oss_service.open](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/oss_service) | data source | OSS Service activation |
| [alicloud_actiontrail_trail.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/actiontrail_trail) | resource | ActionTrail trail |

## Usage

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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_oss_delivery` | Whether to enable OSS delivery | `bool` | `false` | No | - |
| `enable_sls_delivery` | Whether to enable SLS delivery | `bool` | `false` | No | - |
| `trail_name` | The name of the ActionTrail trail | `string` | `"landingzone-actiontrail"` | No | - |
| `trail_status` | The status of the trail | `string` | `"Enable"` | No | Must be: `Enable` or `Disable` |
| `event_type` | The types of events to be recorded | `string` | `"Write"` | No | Must be: `Write`, `Read`, or `All` |
| `trail_region` | The regions to which the trail belongs | `string` | `"All"` | No | Use `All` for global trail |
| `is_organization_trail` | Whether to create a multi-account trail | `bool` | `false` | No | - |
| `oss_bucket_name` | The name of the OSS bucket | `string` | `null` | No | If null, generated from account ID |
| `append_random_suffix` | Whether to append random suffix to resource names | `bool` | `false` | No | - |
| `random_suffix_length` | Length of random suffix | `number` | `6` | No | 3-16 |
| `random_suffix_separator` | Separator between resource names and suffix | `string` | `"-"` | No | Must be: `"-"`, `"_"`, or `""` |
| `oss_server_side_encryption_enabled` | Whether to enable server-side encryption for OSS | `bool` | `true` | No | - |
| `oss_server_side_encryption_algorithm` | Server-side encryption algorithm | `string` | `"AES256"` | No | Must be: `AES256` or `KMS` |
| `oss_write_role_arn` | RAM role ARN for ActionTrail to write to OSS | `string` | `null` | No | If null, uses default service role |
| `oss_force_destroy` | Whether to force destroy OSS bucket | `bool` | `true` | No | - |
| `oss_kms_master_key_id` | KMS master key ID for SSE-KMS encryption | `string` | `null` | No | Required when encryption algorithm is KMS |
| `oss_kms_data_encryption` | Algorithm to encrypt objects | `string` | `null` | No | Must be: `SM4` (only when SSEAlgorithm is KMS) |
| `oss_redundancy_type` | OSS redundancy type | `string` | `"ZRS"` | No | Must be: `LRS` or `ZRS` |
| `sls_project_name` | The name of the SLS project | `string` | `null` | No | If null, generated from account ID. 3-63 chars |
| `sls_create_project` | Whether to create a new SLS project | `bool` | `true` | No | - |
| `sls_project_description` | The description of the SLS project | `string` | `"ActionTrail logs storage"` | No | - |
| `sls_write_role_arn` | RAM role ARN for ActionTrail to write to SLS | `string` | `null` | No | If null, uses default service role |
| `tags` | Tags to assign to all resources | `map(string)` | `{}` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `trail_name` | The name of the ActionTrail trail |
| `trail_id` | The ID of the ActionTrail trail |
| `oss_bucket_name` | The name of the OSS bucket (if enabled) |
| `sls_project_name` | The name of the SLS project (if enabled) |

## Examples

### Basic ActionTrail with OSS Delivery

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

### ActionTrail with Both OSS and SLS Delivery

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

### Organization Trail

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

## Notes

- OSS and SLS services are automatically enabled before creating resources
- At least one delivery method (OSS or SLS) should be enabled
- Default service roles are used for OSS/SLS write operations if not specified
- OSS bucket name defaults to `actiontrail-{account_id}` if not specified
- SLS project name defaults to `actiontrail-{account_id}` if not specified
- Random suffix can be appended to ensure global uniqueness
- Organization trails enable multi-account logging across resource directory
