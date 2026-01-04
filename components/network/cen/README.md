<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Component

This component creates and manages Alibaba Cloud CEN (Cloud Enterprise Network) instance and Transit Router for inter-VPC connectivity.

## Features

- Creates CEN instance
- Creates Transit Router
- Automatically enables Transit Router service
- Retrieves system route table ID for Transit Router
- Supports tags for CEN instance and Transit Router

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
| [alicloud_cen_transit_router_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_service) | data source | Transit Router service activation |
| [alicloud_cen_transit_router_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_route_tables) | data source | Transit Router route tables lookup |
| [alicloud_cen_instance.cen](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance) | resource | CEN instance |
| [alicloud_cen_transit_router.cen_tr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource | Transit Router |

## Usage

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name        = "enterprise-cen"
  cen_instance_description = "Enterprise CEN instance"
  transit_router_name      = "enterprise-tr"
  transit_router_description = "Enterprise Transit Router"
  
  cen_instance_tags = {
    Environment = "production"
  }
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_name` | The name of the CEN instance | `string` | `null` | No | 1-128 chars if not null/empty, cannot start with http:// or https:// |
| `cen_instance_description` | The description for the CEN instance | `string` | `null` | No | 1-256 chars if not null/empty, cannot start with http:// or https:// |
| `cen_instance_tags` | Tags to assign to the CEN instance | `map(string)` | `null` | No | - |
| `transit_router_name` | The name of the Transit Router | `string` | `null` | No | 1-128 chars if not null/empty, cannot start with http:// or https:// |
| `transit_router_description` | The description of the Transit Router | `string` | `null` | No | 1-256 chars if not null/empty, cannot start with http:// or https:// |
| `transit_router_tags` | Tags to assign to the Transit Router | `map(string)` | `null` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `cen_instance_id` | The ID of the created CEN instance |
| `transit_router_id` | The ID of the created Transit Router |
| `system_transit_router_route_table_id` | The ID of the system transit router route table |

## Examples

### Basic CEN Configuration

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name = "my-cen"
  transit_router_name = "my-tr"
}
```

### CEN with Tags

```hcl
module "cen" {
  source = "./components/network/cen"

  cen_instance_name        = "enterprise-cen"
  cen_instance_description = "Enterprise CEN"
  transit_router_name      = "enterprise-tr"
  
  cen_instance_tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## Notes

- Transit Router service is automatically enabled before creating resources
- CEN instance and Transit Router are created sequentially (Transit Router depends on CEN instance)
- System route table ID is automatically retrieved for use in VPC attachments
- Names and descriptions cannot start with `http://` or `https://`
- Tags can be applied to both CEN instance and Transit Router for resource management

