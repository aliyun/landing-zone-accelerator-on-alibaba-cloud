<div align="right">

**中文** | [English](README.md)

</div>

# KMS Instance 模块

该模块用于创建和管理阿里云密钥管理服务（KMS）实例，支持高可用配置。

## 功能特性

- 创建高可用 KMS 实例（支持多可用区）
- 配置实例规格和密钥容量
- 支持自定义产品版本
- 配置 VPC 和交换机绑定

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_kms_instance.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/kms_instance) | resource | 高可用 KMS 实例 |

## 使用方法

```hcl
module "kms_instance" {
  source = "./modules/kms-instance"

  instance_name   = "my-kms-instance"
  product_version = "3"
  vpc_id          = "vpc-1234567890abcdef0"
  zone_ids        = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_ids     = ["vsw-1234567890abcdef0"]
  
  key_num = 1000
  spec    = "1000"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `instance_name` | KMS 实例名称 | `string` | - | 是 | - |
| `product_version` | KMS 实例产品版本 | `string` | `"3"` | 否 | - |
| `vpc_id` | VPC ID | `string` | - | 是 | - |
| `zone_ids` | 高可用可用区 ID 列表 | `list(string)` | - | 是 | 高可用需要 2 个可用区 |
| `vswitch_ids` | 交换机 ID 列表 | `list(string)` | - | 是 | 需要 1 个交换机 |
| `key_num` | KMS 实例可保护的密钥数量 | `number` | `1000` | 否 | - |
| `spec` | KMS 实例规格 | `string` | `"1000"` | 否 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `kms_instance_id` | KMS 实例 ID |
| `kms_instance_status` | KMS 实例状态 |
| `kms_instance_name` | KMS 实例名称 |

## 使用示例

### 基础 KMS 实例

```hcl
module "kms_instance" {
  source = "./modules/kms-instance"

  instance_name = "production-kms"
  vpc_id        = "vpc-abc123"
  zone_ids      = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_ids   = ["vsw-xyz789"]
}
```

### 自定义规格的 KMS 实例

```hcl
module "kms_instance" {
  source = "./modules/kms-instance"

  instance_name   = "high-capacity-kms"
  product_version = "3"
  vpc_id          = "vpc-abc123"
  zone_ids        = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_ids     = ["vsw-xyz789"]
  
  key_num = 5000
  spec    = "5000"
}
```

## 注意事项

- 高可用需要指定 2 个可用区
- `key_num` 参数定义可保护的最大密钥数量
- `spec` 参数定义实例规格，通常与 `key_num` 匹配
- 实例删除可能需要最多 20 分钟

