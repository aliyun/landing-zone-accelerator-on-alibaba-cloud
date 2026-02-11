<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Bandwidth Package Module

This module creates and manages Alibaba Cloud CEN (Cloud Enterprise Network) bandwidth packages and attaches them to CEN instances.

## Features

- Creates a new CEN bandwidth package or uses an existing one
- Attaches the bandwidth package to a CEN instance

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_bandwidth_package.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_bandwidth_package) | resource | CEN bandwidth package (conditional) |
| [alicloud_cen_bandwidth_package_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_bandwidth_package_attachment) | resource | CEN bandwidth package attachment |

## Usage

### Create New Bandwidth Package

```hcl
module "cen_bandwidth_package" {
  source = "./modules/cen-bandwidth-package"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  bandwidth                  = 10
  cen_bandwidth_package_name = "cross-region-bwp"
  description                = "Cross-region bandwidth package"
  geographic_region_a_id     = "China"
  geographic_region_b_id     = "China"
  payment_type               = "PrePaid"
  pricing_cycle              = "Month"
  period                     = 1
}
```

### Use Existing Bandwidth Package

```hcl
module "cen_bandwidth_package" {
  source = "./modules/cen-bandwidth-package"

  cen_instance_id                = "cen-xxxxxxxxxxxxx"
  use_existing_bandwidth_package = true
  existing_bandwidth_package_id  = "cenbwp-xxxxxxxxxxxxx"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance to attach the bandwidth package to | `string` | - | Yes | - |
| `use_existing_bandwidth_package` | Whether to use an existing bandwidth package instead of creating a new one | `bool` | `false` | No | - |
| `existing_bandwidth_package_id` | The ID of an existing CEN bandwidth package to attach | `string` | `null` | No | Required when use_existing_bandwidth_package is true |
| `bandwidth` | The bandwidth in Mbps of the bandwidth package | `number` | `null` | No | 2-10000. Required when creating a new bandwidth package |
| `cen_bandwidth_package_name` | The name of the bandwidth package | `string` | `null` | No | 1-128 chars, cannot start with http:// or https:// |
| `description` | The description of the bandwidth package | `string` | `null` | No | 1-256 chars, cannot start with http:// or https:// |
| `geographic_region_a_id` | The area A to which the network instance belongs | `string` | `null` | No | Must be: China, North-America, Asia-Pacific, Europe, Australia. Required when creating a new bandwidth package |
| `geographic_region_b_id` | The area B to which the network instance belongs | `string` | `null` | No | Must be: China, North-America, Asia-Pacific, Europe, Australia. Required when creating a new bandwidth package |
| `payment_type` | The billing method of the bandwidth package | `string` | `"PrePaid"` | No | Must be: PrePaid, PostPaid |
| `pricing_cycle` | The billing cycle of the bandwidth package | `string` | `"Month"` | No | Must be: Month, Year. Only valid when payment_type is PrePaid |
| `period` | The subscription period of the bandwidth package | `number` | `null` | No | When pricing_cycle is Month: 1, 2, 3, 6. When pricing_cycle is Year: 1, 2, 3. Required when payment_type is PrePaid |

## Outputs

| Name | Description |
|------|-------------|
| `bandwidth_package_id` | The ID of the CEN bandwidth package |
| `bandwidth_package_created` | Whether a new bandwidth package was created |
| `cen_instance_id` | The ID of the CEN instance the bandwidth package is attached to |

## Notes

- When `use_existing_bandwidth_package` is true, the module will only attach the existing bandwidth package to the CEN instance
- When creating a new bandwidth package, `bandwidth`, `geographic_region_a_id`, and `geographic_region_b_id` are required
- For cross-region connectivity within China, set both `geographic_region_a_id` and `geographic_region_b_id` to "China"
- The bandwidth package must be attached to a CEN instance before it can be used for cross-region bandwidth allocation
- If `payment_type` is set to PrePaid, the bandwidth package cannot be deleted before the subscription expires
