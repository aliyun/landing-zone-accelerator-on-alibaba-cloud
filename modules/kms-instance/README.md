<div align="right">

**English** | [中文](README-CN.md)

</div>

# KMS Instance Module

This module creates and manages Alibaba Cloud Key Management Service (KMS) instances with high availability configuration.

## Features

- Creates KMS instance with high availability (multi-zone support)
- Configures instance specifications and key capacity
- Supports custom product version
- Configures VPC and VSwitch bindings

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_kms_instance.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/kms_instance) | resource | KMS instance with high availability |

## Usage

```hcl
module "kms_instance" {
  source = "./modules/kms-instance"

  instance_name   = "my-kms-instance"
  product_version = "3"
  vpc_id          = "vpc-uf6v10ktt3tnxxxxxxxx"
  zone_ids        = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_ids     = ["vsw-uf62k55n02gqxxxxxxxx"]
  
  key_num = 1000
  spec    = "1000"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `instance_name` | The name of the KMS instance | `string` | - | Yes | - |
| `product_version` | The product version of the KMS instance | `string` | `"3"` | No | - |
| `vpc_id` | The ID of the VPC | `string` | - | Yes | - |
| `zone_ids` | List of zone IDs for high availability | `list(string)` | - | Yes | 2 zones required for high availability |
| `vswitch_ids` | List of VSwitch IDs | `list(string)` | - | Yes | 1 vswitch required |
| `key_num` | The number of keys that can be protected in the KMS instance | `number` | `1000` | No | - |
| `spec` | The specification of the KMS instance | `string` | `"1000"` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `kms_instance_id` | The ID of the KMS instance |
| `kms_instance_status` | The status of the KMS instance |
| `kms_instance_name` | The name of the KMS instance |

## Examples

### Basic KMS Instance

```hcl
module "kms_instance" {
  source = "./modules/kms-instance"

  instance_name = "production-kms"
  vpc_id        = "vpc-abc123"
  zone_ids      = ["cn-hangzhou-h", "cn-hangzhou-i"]
  vswitch_ids   = ["vsw-xyz789"]
}
```

### KMS Instance with Custom Specifications

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

## Notes

- High availability requires 2 zones to be specified in `zone_ids`
- The `key_num` parameter defines the maximum number of keys that can be protected
- The `spec` parameter defines the instance specification, typically matching `key_num`
- Instance deletion may take up to 20 minutes

