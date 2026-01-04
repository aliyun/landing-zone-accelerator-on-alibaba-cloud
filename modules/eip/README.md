<div align="right">

**English** | [中文](README-CN.md)

</div>

# EIP Module

This module creates and manages Alibaba Cloud Elastic IP (EIP) addresses with optional common bandwidth package support.

## Features

- Creates multiple EIP instances
- Associates EIPs with instances (ECS, SLB, NAT Gateway, etc.)
- Optional common bandwidth package for shared bandwidth
- Supports both PayAsYouGo and Subscription payment types

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
| [alicloud_eip_address.eip_address](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address) | resource | EIP addresses |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP associations with instances (optional) |
| [alicloud_common_bandwidth_package.bandwidth_package](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package) | resource | Common bandwidth package (optional) |
| [alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package_attachment) | resource | EIP attachments to bandwidth package (optional) |

## Usage

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-1"
    },
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-2"
    }
  ]
  
  eip_associate_instance_id = "nat-1234567890abcdef0"
  
  enable_common_bandwidth_package = true
  common_bandwidth_package_name   = "shared-bandwidth"
  common_bandwidth_package_bandwidth = "100"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `eip_instances` | List of EIP instance configurations | `list(object)` | - | Yes | See EIP instance structure below |
| `eip_associate_instance_id` | The ID of the instance to associate EIPs with | `string` | `""` | No | ECS, SLB, NAT Gateway, NetworkInterface, or HaVip ID |
| `enable_common_bandwidth_package` | Whether to enable common bandwidth package | `bool` | `false` | No | - |
| `common_bandwidth_package_name` | The name of the common bandwidth package | `string` | `null` | No | 2-256 characters, start with letter, cannot start with http:// or https:// |
| `common_bandwidth_package_bandwidth` | The bandwidth of the common bandwidth package (Mbps) | `string` | `"5"` | No | Integer between 1 and 1000 |
| `common_bandwidth_package_internet_charge_type` | The billing method of the common bandwidth package | `string` | `"PayByBandwidth"` | No | Must be: `PayByBandwidth`, `PayBy95`, `PayByDominantTraffic` |
| `common_bandwidth_package_ratio` | The ratio for PayBy95 billing method | `number` | `20` | No | Must be 20 |

### EIP Instance Object Structure

Each EIP instance in `eip_instances` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `payment_type` | `string` | `"PayAsYouGo"` | No | Payment type | Must be: `Subscription` or `PayAsYouGo` |
| `period` | `number` | `null` | No | Subscription period in months | Required when `payment_type = "Subscription"` |
| `eip_address_name` | `string` | `null` | No | EIP address name | 1-128 characters, start with letter, only letters, digits, periods, underscores, hyphens |
| `tags` | `object` | `{}` | No | Tags for the EIP | - |

## Outputs

| Name | Description |
|------|-------------|
| `eip_instances` | List of EIP instances with details (id, ip_address, address_name, payment_type, status, association_id, bandwidth_package_attachment_id) |
| `common_bandwidth_package_id` | ID of the common bandwidth package (if enabled) |

## Examples

### Basic EIP Creation

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "production-eip"
    }
  ]
}
```

### EIP with Association

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "nat-eip"
    }
  ]
  
  eip_associate_instance_id = "ngw-1234567890abcdef0"
}
```

### EIP with Common Bandwidth Package

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-1"
    },
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-2"
    }
  ]
  
  enable_common_bandwidth_package = true
  common_bandwidth_package_name   = "shared-bandwidth"
  common_bandwidth_package_bandwidth = "200"
  common_bandwidth_package_internet_charge_type = "PayByBandwidth"
}
```

### Subscription EIP

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "Subscription"
      period           = 12
      eip_address_name = "subscription-eip"
    }
  ]
}
```

## Notes

- EIP instances can be associated with ECS, SLB, NAT Gateway, NetworkInterface, or HaVip instances
- Common bandwidth package allows multiple EIPs to share bandwidth, reducing costs
- When `enable_common_bandwidth_package = true`, all EIPs are automatically attached to the bandwidth package
- `PayBy95` billing method requires `common_bandwidth_package_ratio = 20`
- EIP names must start with a letter and can contain letters, digits, periods, underscores, and hyphens
