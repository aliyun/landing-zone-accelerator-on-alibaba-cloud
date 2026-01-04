<div align="right">

**English** | [中文](README-CN.md)

</div>

# OSS Bucket Module

This module creates and manages Alibaba Cloud Object Storage Service (OSS) buckets with comprehensive configuration options including encryption, versioning, storage classes, and redundancy settings.

## Features

- Creates OSS bucket with configurable name (supports random suffix for uniqueness)
- Configures bucket ACL (Access Control List)
- Enables versioning support
- Configures server-side encryption (AES256 or KMS)
- Supports multiple storage classes (Standard, IA, Archive, ColdArchive, DeepColdArchive)
- Configures redundancy type (LRS or ZRS)
- Supports automatic object deletion on bucket deletion

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| random | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_regions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source | Current region information |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | Random suffix for bucket name (optional) |
| [alicloud_oss_bucket.bucket](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket) | resource | OSS bucket |
| [alicloud_oss_bucket_acl.bucket_acl](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket_acl) | resource | Bucket ACL configuration |

## Usage

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "my-example-bucket"
  
  versioning = true
  storage_class = "Standard"
  redundancy_type = "ZRS"
  
  server_side_encryption_enabled = true
  server_side_encryption_algorithm = "AES256"
  
  tags = {
    Environment = "production"
    Project     = "example"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bucket_name` | The name of the OSS bucket | `string` | - | Yes | 3-63 characters, start and end with lowercase letter or digit, only lowercase letters, digits and hyphens |
| `append_random_suffix` | Whether to append a random suffix to the bucket name to ensure global uniqueness | `bool` | `false` | No | - |
| `random_suffix_length` | Length of the random suffix for the bucket name | `number` | `6` | No | - |
| `random_suffix_separator` | Separator between the bucket name and random suffix | `string` | `"-"` | No | - |
| `force_destroy` | When deleting a bucket, automatically delete all objects | `bool` | `false` | No | - |
| `versioning` | The versioning status of the bucket | `bool` | `false` | No | - |
| `tags` | A mapping of tags to assign to the bucket | `map(string)` | `null` | No | - |
| `storage_class` | The storage class of the bucket | `string` | `"Standard"` | No | Must be one of: `Standard`, `IA`, `Archive`, `ColdArchive`, `DeepColdArchive` |
| `acl` | The canned ACL to apply to the bucket | `string` | `"private"` | No | - |
| `server_side_encryption_enabled` | Specifies whether to enable server-side encryption for the bucket | `bool` | `true` | No | - |
| `server_side_encryption_algorithm` | The server-side encryption algorithm to use | `string` | `"AES256"` | No | Must be `"AES256"` or `"KMS"` |
| `kms_master_key_id` | The Alibaba Cloud KMS master key ID used for SSE-KMS encryption | `string` | `null` | No | Required when `server_side_encryption_algorithm` is `"KMS"` |
| `kms_data_encryption` | The algorithm used to encrypt objects (valid only when SSEAlgorithm is KMS) | `string` | `null` | No | Must be `null` or `"SM4"` |
| `redundancy_type` | The redundancy type to enable | `string` | `"ZRS"` | No | Must be `"LRS"` or `"ZRS"` |

## Outputs

| Name | Description |
|------|-------------|
| `bucket` | The name of the bucket (with random suffix if enabled) |
| `extranet_endpoint` | The extranet access endpoint of the bucket |
| `intranet_endpoint` | The intranet access endpoint of the bucket |
| `bucket_arn` | The ARN of the bucket in format: `acs:oss:oss-{region}:{account_id}:{bucket_name}` |

## Examples

### Basic Bucket with Default Settings

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "my-bucket"
}
```

### Bucket with Random Suffix for Uniqueness

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name         = "my-bucket"
  append_random_suffix = true
  random_suffix_length = 8
}
```

### Bucket with KMS Encryption

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "secure-bucket"
  
  server_side_encryption_enabled = true
  server_side_encryption_algorithm = "KMS"
  kms_master_key_id = "alias/oss-key"
  kms_data_encryption = "SM4"
}
```

### Bucket with Versioning and Archive Storage

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name  = "archive-bucket"
  versioning   = true
  storage_class = "Archive"
  redundancy_type = "ZRS"
}
```

### Bucket with Public Read Access

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "public-bucket"
  acl         = "public-read"
}
```

## Notes

- Bucket names must be globally unique across all Alibaba Cloud accounts
- Use `append_random_suffix` to ensure uniqueness when bucket name conflicts are possible
- When `force_destroy` is `true`, all objects in the bucket will be deleted when the bucket is destroyed
- Versioning can be enabled or suspended (default: suspended)
- Server-side encryption is enabled by default with AES256 algorithm
- For KMS encryption, you must provide a valid KMS master key ID
- ZRS (Zone-Redundant Storage) provides higher availability than LRS (Locally Redundant Storage)
- Storage classes affect cost and access patterns:
  - **Standard**: General purpose, frequently accessed data
  - **IA (Infrequent Access)**: Less frequently accessed data, lower cost
  - **Archive**: Rarely accessed data, lowest cost, requires restore time
  - **ColdArchive**: Very rarely accessed data, lowest cost, longer restore time
  - **DeepColdArchive**: Extremely rarely accessed data, lowest cost, longest restore time

