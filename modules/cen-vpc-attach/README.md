<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN VPC Attachment Module

This module attaches a VPC to an Alibaba Cloud Cloud Enterprise Network (CEN) transit router, enabling network connectivity across VPCs and regions.

## Features

- Attaches VPC to CEN transit router
- Supports cross-account VPC attachment (automatically handles authorization)
- Configures primary and secondary vSwitches for high availability
- Supports route table association and propagation
- Automatically creates service-linked role if needed

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| alicloud.cen | >= 1.262.1 |
| alicloud.vpc | >= 1.262.1 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.cen_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | CEN account information |
| [alicloud_account.vpc_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | VPC account information |
| [alicloud_ram_roles.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/ram_roles) | data source | CEN service-linked role lookup |
| [alicloud_resource_manager_service_linked_role.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | CEN service-linked role |
| [alicloud_cen_instance_grant.cen_instance_grant](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance_grant) | resource | Cross-account CEN instance grant |
| [alicloud_cen_transit_router_vpc_attachment.vpc_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource | VPC attachment to transit router |
| [alicloud_cen_transit_router_route_table_association.route_table_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | Route table association (optional) |
| [alicloud_cen_transit_router_route_table_propagation.route_table_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | Route table propagation (optional) |

## Usage

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-1234567890abcdef0"
  cen_transit_router_id = "tr-1234567890abcdef0"
  vpc_id                = "vpc-1234567890abcdef0"
  
  primary_vswitch = {
    vswitch_id = "vsw-abc123"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-xyz789"
    zone_id    = "cn-hangzhou-i"
  }
  
  route_table_association_enabled = true
  route_table_propagation_enabled = true
  transit_router_route_table_id   = "vtb-1234567890abcdef0"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance to which the VPC will be attached | `string` | - | Yes | - |
| `cen_transit_router_id` | The ID of the CEN transit router where the VPC attachment will be created | `string` | - | Yes | - |
| `vpc_id` | The ID of the VPC to attach to the CEN transit router | `string` | - | Yes | - |
| `primary_vswitch` | Primary vSwitch information for the VPC attachment | `object` | - | Yes | Must contain `vswitch_id` and `zone_id` |
| `secondary_vswitch` | Secondary vSwitch information for the VPC attachment | `object` | - | Yes | Must contain `vswitch_id` and `zone_id` |
| `transit_router_route_table_id` | The ID of the transit router route table for association and propagation | `string` | `""` | No | Required when route table features are enabled |
| `transit_router_attachment_name` | The name of the transit router VPC attachment | `string` | `""` | No | - |
| `transit_router_attachment_description` | The description of the transit router VPC attachment | `string` | `""` | No | - |
| `route_table_association_enabled` | Whether to enable route table association for the VPC attachment | `bool` | `false` | No | - |
| `route_table_propagation_enabled` | Whether to enable route table propagation for the VPC attachment | `bool` | `false` | No | - |

### VSwitch Object Structure

Both `primary_vswitch` and `secondary_vswitch` must have the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vswitch_id` | `string` | Yes | The ID of the vSwitch |
| `zone_id` | `string` | Yes | The availability zone ID where the vSwitch is located |

## Outputs

| Name | Description |
|------|-------------|
| `transit_router_attachment_id` | The ID of the CEN transit router VPC attachment |
| `route_table_association_id` | The ID of the route table association resource (if enabled) |
| `route_table_propagation_id` | The ID of the route table propagation resource (if enabled) |

## Examples

### Basic VPC Attachment

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-abc123"
  cen_transit_router_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  primary_vswitch = {
    vswitch_id = "vsw-primary"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-secondary"
    zone_id    = "cn-hangzhou-i"
  }
}
```

### With Route Table Features

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-abc123"
  cen_transit_router_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  primary_vswitch = {
    vswitch_id = "vsw-primary"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-secondary"
    zone_id    = "cn-hangzhou-i"
  }
  
  transit_router_route_table_id   = "vtb-route-table"
  route_table_association_enabled = true
  route_table_propagation_enabled = true
  
  transit_router_attachment_name        = "production-vpc-attachment"
  transit_router_attachment_description = "Production VPC attachment to CEN"
}
```

## Notes

- Requires two providers: `alicloud.cen` for CEN resources and `alicloud.vpc` for VPC resources
- Cross-account attachment is automatically handled when CEN and VPC are in different accounts
- Primary and secondary vSwitches should be in different availability zones for high availability
- Route table association and propagation require `transit_router_route_table_id` to be specified
- Attachment creation may take up to 15 minutes, deletion up to 30 minutes
