<div align="right">

**English** | [中文](README-CN.md)

</div>

# KMS Component

This component creates and manages Alibaba Cloud Key Management Service (KMS) instances with high availability configuration.

## Features

- Creates KMS instances with high availability
- Optionally creates VPC and VSwitch for KMS instance
- Configures KMS instance specifications and key capacity
- Supports multiple availability zones for high availability

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.267.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| kms_vpc | ../../../modules/vpc | VPC and VSwitch for KMS instance (optional) |
| kms_instance | ../../../modules/kms-instance | KMS instance module |

## Usage

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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_kms_instance` | Whether to create a KMS instance | `bool` | `true` | No | - |
| `kms_instance_name` | The name of the KMS instance | `string` | `"landingzone-central-kms"` | No | - |
| `kms_instance_spec` | The specification of the KMS instance | `string` | `"1000"` | No | - |
| `kms_key_amount` | The number of keys that can be protected in the KMS instance | `number` | `1000` | No | - |
| `product_version` | The product version of the KMS instance | `string` | `"3"` | No | - |
| `vpc_name` | The name of the VPC | `string` | `"kms-vpc"` | No | - |
| `vpc_cidr_block` | The CIDR block for the VPC | `string` | `"10.0.0.0/8"` | No | - |
| `vswitch_cidr_block` | The CIDR block for the VSwitch | `string` | `"10.0.1.0/24"` | No | - |
| `vswitch_name` | The name of the VSwitch | `string` | `"kms-vswitch"` | No | - |
| `zone_ids` | List of zone IDs for high availability (2 zones required) | `list(string)` | - | Yes | The first zone_id will be used for the VSwitch |

## Outputs

| Name | Description |
|------|-------------|
| `kms_instance_id` | The ID of the KMS instance |
| `kms_instance_status` | The status of the KMS instance |
| `kms_instance_name` | The name of the KMS instance |
| `vpc_id` | The ID of the VPC |
| `vswitch_id` | The ID of the VSwitch |
| `vswitch_ids` | The IDs of all VSwitches |
| `zone_ids` | The zone IDs used by the KMS instance |

## Examples

### Basic KMS Instance

```hcl
module "kms" {
  source = "./components/security/kms"

  create_kms_instance = true
  kms_instance_name = "production-kms"
  zone_ids = ["cn-hangzhou-h", "cn-hangzhou-i"]
}
```

### KMS Instance with Custom Configuration

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

## Notes

- KMS instance requires 2 availability zones for high availability
- The first zone in `zone_ids` is used for the VSwitch
- VPC and VSwitch are created automatically when `create_kms_instance = true`
- Instance specification determines the performance and capacity
- Key amount specifies the maximum number of keys that can be protected

