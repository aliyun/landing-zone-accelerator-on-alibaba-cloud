<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Instance Component

This component creates and manages Alibaba Cloud CEN (Cloud Enterprise Network) instance.

## Features

- Creates CEN instance
- Automatically enables Transit Router service
- Supports tags for CEN instance
- Creates and attaches multiple CEN bandwidth packages

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

| Name | Source | Description |
|------|--------|-------------|
| cen_bandwidth_package | ../../../modules/cen-bandwidth-package | CEN bandwidth packages |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_transit_router_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_service) | data source | Transit Router service activation |
| [alicloud_cen_instance.cen](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance) | resource | CEN instance |

## Usage

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "enterprise-cen"
  description       = "Enterprise CEN instance"
  
  tags = {
    Environment = "production"
  }

  bandwidth_packages = [
    {
      bandwidth                  = 10
      cen_bandwidth_package_name = "cross-region-bwp"
      geographic_region_a_id     = "China"
      geographic_region_b_id     = "China"
      payment_type               = "PrePaid"
      pricing_cycle              = "Month"
      period                     = 1
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_name` | The name of the CEN instance | `string` | `null` | No | 1-128 chars if not null/empty, cannot start with http:// or https:// |
| `description` | The description of the CEN instance | `string` | `null` | No | 1-256 chars if not null/empty, cannot start with http:// or https:// |
| `tags` | The tags of the CEN instance | `map(string)` | `null` | No | - |
| `protection_level` | The level of CIDR block overlapping | `string` | `null` | No | Valid values: REDUCED |
| `resource_group_id` | The ID of the resource group | `string` | `null` | No | - |
| `bandwidth_packages` | List of CEN bandwidth package configurations | `list(object)` | `[]` | No | See bandwidth package object structure |

### Bandwidth Package Object Structure

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `bandwidth` | `number` | - | Yes | Bandwidth in Mbps (2-10000) |
| `geographic_region_a_id` | `string` | - | Yes | Geographic region A (China, North-America, Asia-Pacific, Europe, Australia) |
| `geographic_region_b_id` | `string` | - | Yes | Geographic region B (China, North-America, Asia-Pacific, Europe, Australia) |
| `cen_bandwidth_package_name` | `string` | `null` | No | Name of the bandwidth package |
| `description` | `string` | `null` | No | Description of the bandwidth package |
| `payment_type` | `string` | `"PrePaid"` | No | Payment type (PrePaid, PostPaid) |
| `pricing_cycle` | `string` | `"Month"` | No | Pricing cycle (Month, Year) |
| `period` | `number` | `1` | No | Subscription period |

## Outputs

| Name | Description |
|------|-------------|
| `cen_instance_id` | The ID of the created CEN instance |
| `bandwidth_package_ids` | List of bandwidth package IDs attached to this CEN instance |
| `bandwidth_packages` | List of bandwidth packages attached to this CEN instance (each item contains input parameters and bandwidth_package_id) |
| `bandwidth_packages_map` | Map of bandwidth packages attached to this CEN instance (key format: "RegionA:RegionB", e.g., "China:China") |

## Examples

### Basic CEN Instance

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "my-cen"
}
```

### CEN Instance with Bandwidth Package

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "enterprise-cen"
  description       = "Enterprise CEN"
  
  tags = {
    Environment = "production"
    Project     = "landing-zone"
  }

  bandwidth_packages = [
    {
      bandwidth                  = 10
      cen_bandwidth_package_name = "china-cross-region"
      geographic_region_a_id     = "China"
      geographic_region_b_id     = "China"
      payment_type               = "PrePaid"
      pricing_cycle              = "Month"
      period                     = 1
    }
  ]
}
```

## Notes

- Transit Router service is automatically enabled before creating CEN instance
- Names and descriptions cannot start with `http://` or `https://`
- Tags can be applied to CEN instance for resource management
- Bandwidth packages are used for cross-region connectivity
- The key format in `bandwidth_packages_map` uses colon (`:`) to join geographic regions (e.g., `"China:China"`, `"China:Asia-Pacific"`)
- Geographic regions in the key are sorted to ensure consistency regardless of A/B order

