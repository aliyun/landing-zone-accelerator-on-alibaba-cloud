<div align="right">

**中文** | [English](README.md)

</div>

# OSS Bucket 模块

该模块用于创建和管理阿里云对象存储服务（OSS）存储桶，提供全面的配置选项，包括加密、版本控制、存储类型和冗余设置。

## 功能特性

- 创建 OSS 存储桶，支持配置名称（支持随机后缀以确保唯一性）
- 配置存储桶 ACL（访问控制列表）
- 启用版本控制支持
- 配置服务端加密（AES256 或 KMS）
- 支持多种存储类型（标准存储、低频访问、归档存储、冷归档存储、深度冷归档存储）
- 配置冗余类型（LRS 或 ZRS）
- 支持删除存储桶时自动删除所有对象

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
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | 存储桶名称的随机后缀（可选） |
| [alicloud_oss_bucket.bucket](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket) | resource | OSS 存储桶 |
| [alicloud_oss_bucket_acl.bucket_acl](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/oss_bucket_acl) | resource | 存储桶 ACL 配置 |

## 使用方法

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

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `bucket_name` | OSS 存储桶名称 | `string` | - | 是 | 3-63 个字符，必须以小写字母或数字开头和结尾，只能包含小写字母、数字和连字符 |
| `append_random_suffix` | 是否在存储桶名称后追加随机后缀以确保全局唯一性 | `bool` | `false` | 否 | - |
| `random_suffix_length` | 随机后缀的长度 | `number` | `6` | 否 | - |
| `random_suffix_separator` | 存储桶名称和随机后缀之间的分隔符 | `string` | `"-"` | 否 | - |
| `force_destroy` | 删除存储桶时，是否自动删除所有对象 | `bool` | `false` | 否 | - |
| `versioning` | 存储桶的版本控制状态 | `bool` | `false` | 否 | - |
| `tags` | 分配给存储桶的标签映射 | `map(string)` | `null` | 否 | - |
| `storage_class` | 存储桶的存储类型 | `string` | `"Standard"` | 否 | 必须为：`Standard`、`IA`、`Archive`、`ColdArchive`、`DeepColdArchive` 之一 |
| `acl` | 应用于存储桶的预设 ACL | `string` | `"private"` | 否 | - |
| `server_side_encryption_enabled` | 是否启用存储桶的服务端加密 | `bool` | `true` | 否 | - |
| `server_side_encryption_algorithm` | 使用的服务端加密算法 | `string` | `"AES256"` | 否 | 必须为 `"AES256"` 或 `"KMS"` |
| `kms_master_key_id` | 用于 SSE-KMS 加密的阿里云 KMS 主密钥 ID | `string` | `null` | 否 | 当 `server_side_encryption_algorithm` 为 `"KMS"` 时必填 |
| `kms_data_encryption` | 用于加密对象的算法（仅在 SSEAlgorithm 为 KMS 时有效） | `string` | `null` | 否 | 必须为 `null` 或 `"SM4"` |
| `redundancy_type` | 启用的冗余类型 | `string` | `"ZRS"` | 否 | 必须为 `"LRS"` 或 `"ZRS"` |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `bucket` | 存储桶名称（如果启用了随机后缀，则包含后缀） |
| `extranet_endpoint` | 存储桶的公网访问端点 |
| `intranet_endpoint` | 存储桶的内网访问端点 |
| `bucket_arn` | 存储桶的 ARN，格式：`acs:oss:oss-{region}:{account_id}:{bucket_name}` |

## 使用示例

### 使用默认设置的基础存储桶

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "my-bucket"
}
```

### 带随机后缀的存储桶（确保唯一性）

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name         = "my-bucket"
  append_random_suffix = true
  random_suffix_length = 8
}
```

### 使用 KMS 加密的存储桶

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

### 启用版本控制和归档存储的存储桶

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name  = "archive-bucket"
  versioning   = true
  storage_class = "Archive"
  redundancy_type = "ZRS"
}
```

### 公共读访问的存储桶

```hcl
module "oss_bucket" {
  source = "./modules/oss-bucket"

  bucket_name = "public-bucket"
  acl         = "public-read"
}
```

## 注意事项

- 存储桶名称必须在所有阿里云账户中全局唯一
- 当可能出现存储桶名称冲突时，使用 `append_random_suffix` 确保唯一性
- 当 `force_destroy` 为 `true` 时，删除存储桶将同时删除存储桶中的所有对象
- 版本控制可以启用或暂停（默认：暂停）
- 默认启用服务端加密，使用 AES256 算法
- 对于 KMS 加密，必须提供有效的 KMS 主密钥 ID
- ZRS（同城冗余存储）比 LRS（本地冗余存储）提供更高的可用性
- 存储类型影响成本和访问模式：
  - **标准存储**：通用目的，频繁访问的数据
  - **低频访问存储（IA）**：访问频率较低的数据，成本更低
  - **归档存储**：很少访问的数据，成本最低，需要恢复时间
  - **冷归档存储**：极少访问的数据，成本最低，恢复时间较长
  - **深度冷归档存储**：几乎不访问的数据，成本最低，恢复时间最长

