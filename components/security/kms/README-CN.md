<div align="right">

**中文** | [English](README.md)

</div>

# KMS 组件

该组件用于创建和管理阿里云密钥管理服务（KMS）实例，支持高可用配置。

## 功能特性

- 创建高可用 KMS 实例
- 可选创建 KMS 实例的 VPC 和交换机
- 配置 KMS 实例规格和密钥容量
- 支持多可用区高可用

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| kms_instance | ../../../modules/kms-instance | KMS 实例模块 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_vpc.kms_vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | KMS 实例的 VPC（可选） |
| [alicloud_vswitch.kms_vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | KMS 实例的交换机（可选） |

## 使用方法

```hcl
module "kms" {
  source = "./components/security/kms"

  create_kms_instance = true
  
  kms_instance_name = "landingzone-central-kms"
  kms_instance_spec = "1000"
  kms_key_amount = 1000
  product_version = "3"
  
  vpc_name = "kms-vpc"
  vpc_cidr_block = "10.0.0.0/8"
  vswitch_cidr_block = "10.0.1.0/24"
  vswitch_name = "kms-vswitch"
  
  zone_ids = ["cn-hangzhou-h", "cn-hangzhou-i"]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_kms_instance` | 是否创建 KMS 实例 | `bool` | `true` | No | - |
| `kms_instance_name` | KMS 实例名称 | `string` | `"landingzone-central-kms"` | No | - |
| `kms_instance_spec` | KMS 实例规格 | `string` | `"1000"` | No | - |
| `kms_key_amount` | KMS 实例可保护的密钥数量 | `number` | `1000` | No | - |
| `product_version` | KMS 实例产品版本 | `string` | `"3"` | No | - |
| `vpc_name` | VPC 名称 | `string` | `"kms-vpc"` | No | - |
| `vpc_cidr_block` | VPC CIDR 网段 | `string` | `"10.0.0.0/8"` | No | - |
| `vswitch_cidr_block` | 交换机 CIDR 网段 | `string` | `"10.0.1.0/24"` | No | - |
| `vswitch_name` | 交换机名称 | `string` | `"kms-vswitch"` | No | - |
| `zone_ids` | 高可用可用区列表（需要 2 个可用区） | `list(string)` | - | Yes | 第一个可用区将用于交换机 |

## 输出参数

| Name | Description |
|------|-------------|
| `kms_instance_id` | KMS 实例 ID |
| `kms_instance_status` | KMS 实例状态 |
| `kms_instance_name` | KMS 实例名称 |
| `vpc_id` | VPC ID |
| `vswitch_id` | 交换机 ID |
| `vswitch_ids` | 所有交换机 ID 列表 |
| `zone_ids` | KMS 实例使用的可用区 ID 列表 |

## 使用示例

### 基础 KMS 实例

```hcl
module "kms" {
  source = "./components/security/kms"

  create_kms_instance = true
  kms_instance_name = "production-kms"
  zone_ids = ["cn-hangzhou-h", "cn-hangzhou-i"]
}
```

### 自定义配置的 KMS 实例

```hcl
module "kms" {
  source = "./components/security/kms"

  create_kms_instance = true
  
  kms_instance_name = "enterprise-kms"
  kms_instance_spec = "2000"
  kms_key_amount = 5000
  product_version = "3"
  
  vpc_name = "kms-production-vpc"
  vpc_cidr_block = "172.16.0.0/16"
  vswitch_cidr_block = "172.16.1.0/24"
  
  zone_ids = ["cn-hangzhou-h", "cn-hangzhou-i"]
}
```

## 注意事项

- KMS 实例需要 2 个可用区以实现高可用
- `zone_ids` 中的第一个可用区将用于交换机
- 当 `create_kms_instance = true` 时，会自动创建 VPC 和交换机
- 实例规格决定性能和容量
- 密钥数量指定可保护的最大密钥数

