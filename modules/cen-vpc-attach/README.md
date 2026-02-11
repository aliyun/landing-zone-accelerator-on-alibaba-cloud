<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN VPC Attachment Module

This module attaches a VPC to an Alibaba Cloud Cloud Enterprise Network (CEN) transit router, enabling network connectivity across VPCs and regions.

## Features

- Attaches VPC to CEN transit router
- Supports cross-account VPC attachment (requires explicit grant configuration)
- Configures multiple vSwitches (at least 2) for high availability
- Supports route table association and propagation
- Creates route entries in VPC system route table with Transit Router as next hop
- Automatically creates service-linked role if needed

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.cen_tr | >= 1.267.0 |
| alicloud.vpc | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.cen_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | CEN account information |
| [alicloud_account.vpc_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | VPC account information |
| [alicloud_resource_manager_service_linked_role.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | CEN service-linked role |
| [alicloud_cen_instance_grant.cen_instance_grant](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance_grant) | resource | Cross-account CEN instance grant |
| [alicloud_cen_transit_router_vpc_attachment.vpc_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource | VPC attachment to transit router |
| [alicloud_cen_transit_router_route_table_association.route_table_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | Route table association (optional) |
| [alicloud_cen_transit_router_route_table_propagation.route_table_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | Route table propagation (optional) |
| [alicloud_route_entry.vpc_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | VPC route entries with Transit Router as next hop (optional) |

## Usage

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-jhwbspfj5lnxxxxxxxx"
  cen_tr_id = "tr-uf6e6h5vv5eigxxxxxx"
  vpc_id                = "vpc-uf6v10ktt3tnxxxxxxxx"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-uf62k55n02gqxxxxxxxx"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-uf62w4c2ofg6xxxxxxxx"
      zone_id    = "cn-hangzhou-i"
    }
  ]
  
  cen_tr_route_table_association_enabled = true
  cen_tr_route_table_propagation_enabled = true
  cen_tr_route_table_id    = "vtb-uf6edldu59p7vyxxxxx"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance to which the VPC will be attached | `string` | - | Yes | - |
| `cen_tr_id` | The ID of the CEN transit router where the VPC attachment will be created | `string` | - | Yes | - |
| `vpc_id` | The ID of the VPC to attach to the CEN transit router | `string` | - | Yes | - |
| `vpc_attachment_vswitches` | List of vSwitch information for the VPC attachment | `list(object)` | - | Yes | At least 2 vSwitches required. Each object must contain `vswitch_id`. `zone_id` is optional and will be automatically queried if not provided |
| `cen_tr_route_table_id` | The ID of the transit router route table for association and propagation | `string` | `""` | No | Required when route table features are enabled |
| `cen_tr_attachment_name` | The name of the transit router VPC attachment | `string` | `""` | No | 2-128 characters, letters/digits/underscores/hyphens only, must start with a letter |
| `cen_tr_attachment_description` | The description of the transit router VPC attachment | `string` | `""` | No | 2-256 characters, must start with a letter, cannot start with http:// or https:// |
| `cen_tr_route_table_association_enabled` | Whether to enable route table association for the VPC attachment | `bool` | `false` | No | - |
| `cen_tr_route_table_propagation_enabled` | Whether to enable route table propagation for the VPC attachment | `bool` | `false` | No | - |
| `cen_tr_attachment_auto_publish_route_enabled` | Whether to enable the Enterprise Edition transit router to automatically advertise routes to VPCs | `bool` | `false` | No | - |
| `cen_tr_attachment_force_delete` | Whether to forcibly delete the VPC connection. When true, all related dependencies are deleted by default | `bool` | `false` | No | - |
| `cen_tr_attachment_payment_type` | The billing method | `string` | `"PayAsYouGo"` | No | Must be PayAsYouGo |
| `cen_tr_attachment_tags` | The tags of the VPC attachment resource | `map(string)` | `{}` | No | - |
| `cen_tr_attachment_options` | TransitRouterVpcAttachmentOptions for the VPC attachment | `map(string)` | `{}` | No | - |
| `cen_tr_attachment_resource_type` | The resource type of the transit router vpc attachment | `string` | `"VPC"` | No | Must be VPC |
| `cen_service_linked_role_exists` | Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role | `bool` | `false` | No | - |
| `create_cen_instance_grant` | Whether to create CEN instance grant for cross-account attachment. **Must be set to `true` when CEN and VPC are in different accounts, and `false` when they are in the same account.**  | `bool` | `false` | No | - |

### VSwitch Object Structure

Each element in `vpc_attachment_vswitches` must have the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `vswitch_id` | `string` | Yes | The ID of the vSwitch |
| `zone_id` | `string` | No | The availability zone ID where the vSwitch is located. If not provided, it will be automatically queried using the vSwitch ID |

### Route Entry Object Structure

Each element in `vpc_route_entries` must have the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `destination_cidrblock` | `string` | Yes | The destination CIDR block for the route entry (valid IPv4 CIDR) |
| `name` | `string` | No | The name of the route entry (1-128 characters, cannot start with http:// or https://) |
| `description` | `string` | No | The description of the route entry (1-256 characters, cannot start with http:// or https://) |

**Note:** All route entries will automatically use the Transit Router attachment as the next hop (`nexthop_type` is fixed to `Attachment`).

## Outputs

| Name | Description |
|------|-------------|
| `transit_router_attachment_id` | The ID of the CEN transit router VPC attachment |
| `route_table_association_id` | The ID of the route table association resource (if enabled) |
| `route_table_propagation_id` | The ID of the route table propagation resource (if enabled) |
| `vpc_route_entry_ids` | List of VPC route entry IDs created for Transit Router attachment |

## Examples

### Basic VPC Attachment

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    }
  ]

  # Alternative: zone_id can be omitted and will be auto-queried
  # vpc_attachment_vswitches = [
  #   {
  #     vswitch_id = "vsw-primary"
  #   },
  #   {
  #     vswitch_id = "vsw-secondary"
  #   }
  # ]
}
```

### With Route Table Features

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    },
    {
      vswitch_id = "vsw-tertiary"
      zone_id    = "cn-hangzhou-j"
    }
  ]
  
  cen_tr_route_table_id    = "vtb-route-table"
  cen_tr_route_table_association_enabled  = true
  cen_tr_route_table_propagation_enabled  = true
  
  cen_tr_attachment_name        = "production-vpc-attachment"
  cen_tr_attachment_description = "Production VPC attachment to CEN"
}
```

### With VPC Route Entries

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    }
  ]
  
  # Route entries will use Transit Router attachment as next hop
  vpc_route_table_id = "vtb-uf6edldu59p7vyxxxxx"
  vpc_route_entries = [
    {
      destination_cidrblock = "10.10.0.0/14"
      name                  = "route-to-tr"
      description           = "Route to Transit Router"
    }
  ]
}
```

## Notes

- Requires two providers: `alicloud.cen_tr` for CEN resources and `alicloud.vpc` for VPC resources
- Cross-account attachment is automatically handled when CEN and VPC are in different accounts
- At least 2 vSwitches are required, and they should be in different availability zones for high availability
- Route table association and propagation require `cen_tr_route_table_id` to be specified
- VPC route entries require `vpc_route_table_id` to be specified when `vpc_route_entries` is not empty
- VPC route entries are added to the specified VPC route table with Transit Router attachment as the next hop (`nexthop_type` is fixed to `Attachment`)
- Attachment creation may take up to 15 minutes, deletion up to 30 minutes
