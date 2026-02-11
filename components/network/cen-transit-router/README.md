<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Transit Router Component

This component creates and manages Alibaba Cloud CEN Transit Router and retrieves the system route table ID.

## Features

- Creates Transit Router within a CEN instance
- Retrieves system route table ID for Transit Router
- Supports tags for Transit Router
- Allocates CIDR blocks to Transit Router (optional, up to 5 CIDR blocks)

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
| [alicloud_cen_transit_router_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_route_tables) | data source | Transit Router route tables lookup |
| [alicloud_cen_transit_router.transit_router](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource | Transit Router |
| [alicloud_cen_transit_router_cidr.transit_router_cidr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_cidr) | resource | Transit Router CIDR blocks (optional) |

## Usage

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name       = "enterprise-tr"
  transit_router_description = "Enterprise Transit Router"
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance | `string` | - | Yes | - |
| `transit_router_name` | The name of the Transit Router | `string` | `null` | No | 1-128 chars if not null/empty, cannot start with http:// or https:// |
| `transit_router_description` | The description of the Transit Router | `string` | `null` | No | 1-256 chars if not null/empty, cannot start with http:// or https:// |
| `transit_router_tags` | Tags to assign to the Transit Router | `map(string)` | `null` | No | - |
| `transit_router_cidrs` | List of CIDR blocks to allocate to the Transit Router | `list(object)` | `[]` | No | See Transit Router CIDR Object Structure below |

### Transit Router CIDR Object Structure

Each CIDR configuration in `transit_router_cidrs` must have the following structure:

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `cidr` | `string` | - | Yes | CIDR block to allocate (subnet mask must be between /16 and /24 inclusive) |
| `description` | `string` | `null` | No | Description of the CIDR block (1-256 chars, cannot start with http:// or https://) |
| `publish_cidr_route` | `bool` | `true` | No | Whether to automatically add a route pointing to the CIDR block |
| `transit_router_cidr_name` | `string` | `null` | No | Name of the CIDR block (1-128 chars, cannot start with http:// or https://) |

## Outputs

| Name | Description |
|------|-------------|
| `transit_router_id` | The ID of the created Transit Router |
| `transit_router_region_id` | The region ID of the created Transit Router |
| `system_transit_router_route_table_id` | The ID of the system transit router route table |
| `transit_router_cidrs` | List of Transit Router CIDR blocks with their details |
| `transit_router_cidr_ids` | Map of CIDR blocks to their Transit Router CIDR IDs |

## Examples

### Basic Transit Router

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id      = "cen-xxxxxxxxxxxxx"
  transit_router_name = "my-tr"
}
```

### Transit Router with Tags

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name        = "enterprise-tr"
  transit_router_description = "Enterprise Transit Router"
  
  transit_router_tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
}
```

### Transit Router with CIDR Blocks

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name        = "enterprise-tr"
  transit_router_description = "Enterprise Transit Router"
  
  transit_router_cidrs = [
    {
      cidr                     = "192.168.0.0/24"
      description              = "Primary CIDR block for VPN gateway IPs"
      publish_cidr_route       = true
      transit_router_cidr_name = "tr-cidr-primary"
    },
    {
      cidr                     = "192.168.1.0/24"
      description              = "Secondary CIDR block"
      publish_cidr_route       = false
      transit_router_cidr_name = "tr-cidr-secondary"
    }
  ]
}
```

## Notes

- Transit Router must be created within an existing CEN instance
- System route table ID is automatically retrieved for use in VPC attachments
- Names and descriptions cannot start with `http://` or `https://`
- Tags can be applied to Transit Router for resource management

### Transit Router CIDR Blocks

When configuring `transit_router_cidrs`, please note the following restrictions:

- **Maximum 5 CIDR blocks** per Transit Router
- **Subnet mask range**: Each CIDR must have a subnet mask between /16 and /24 (inclusive)
- **CIDR uniqueness**: Each CIDR block must be unique (no duplicates allowed)
- **CIDR overlap**: CIDR blocks must not overlap with each other. Alibaba Cloud API will validate overlap at resource creation time
- **Prohibited CIDR ranges**: The following CIDR ranges and their subnets are not supported:
  - `100.64.0.0/10`
  - `224.0.0.0/4`
  - `127.0.0.0/8`
  - `169.254.0.0/16`
