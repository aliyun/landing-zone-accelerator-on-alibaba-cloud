<div align="right">

**English** | [中文](README-CN.md)

</div>

# DMZ VPC Egress Module

This module configures internet egress routing from a VPC through a DMZ VPC using CEN transit router and NAT Gateway.

## Features

- Configures VPC route table to route internet traffic to transit router
- Configures DMZ VPC route table to route VPC CIDR to transit router
- Configures NAT Gateway SNAT entries for internet egress
- Automatically discovers system route tables if not specified
- Supports multiple EIP addresses for SNAT

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.dmz | >= 1.267.0 |
| alicloud.vpc | >= 1.267.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/route_tables) | data source | VPC route tables lookup (for system route table) |
| [alicloud_route_tables.dmz_route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/route_tables) | data source | DMZ VPC route tables lookup (for system route table) |
| [alicloud_nat_gateways.nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/nat_gateways) | data source | NAT Gateway lookup (for EIP addresses and SNAT table ID) |
| [alicloud_route_entry.route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | Route entry in VPC route table (0.0.0.0/0 -> transit router) |
| [alicloud_route_entry.dmz_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | Route entry in DMZ VPC route table (VPC CIDR -> transit router) |
| [alicloud_snat_entry.snat](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/snat_entry) | resource | SNAT entry in DMZ NAT Gateway |

## Usage

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-uf6v10ktt3tnxxxxxxxx"
  vpc_tr_attachment_id = "tr-attach-2ze0xxxxxxxxxxxxxxxx"
  vpc_cidr_block       = "192.168.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-2ze0xxxxxxxxxxxxxxxx"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-2ze0xxxxxxxxxxxxxxxx"
  dmz_nat_gateway_id         = "ngw-uf6hg6eaaqz70xxxxxx"
  dmz_eip_addresses         = ["47.96.XX.XX", "47.96.XX.YY"]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `vpc_id` | The ID of the VPC that requires internet egress | `string` | - | Yes | - |
| `vpc_route_table_id` | The ID of the route table in the VPC | `string` | `null` | No | If not specified, system route table will be used |
| `vpc_tr_attachment_id` | The ID of the VPC transit router attachment | `string` | - | Yes | - |
| `vpc_route_entry_destination_cidrblock` | The destination CIDR block for the VPC route entry | `string` | `"0.0.0.0/0"` | No | Valid IPv4 CIDR block. Defaults to 0.0.0.0/0 for Internet egress |
| `vpc_cidr_block` | The CIDR block routed from VPC to DMZ | `string` | - | Yes | Valid IPv4 CIDR block |
| `dmz_vpc_id` | The ID of the DMZ VPC | `string` | - | Yes | - |
| `dmz_route_table_id` | The ID of the route table in the DMZ VPC | `string` | `null` | No | If not specified, system route table will be used |
| `dmz_vpc_tr_attachment_id` | The ID of the DMZ VPC transit router attachment | `string` | - | Yes | - |
| `dmz_nat_gateway_id` | The ID of the NAT Gateway in the DMZ VPC | `string` | - | Yes | - |
| `dmz_snat_table_id` | The ID of the SNAT table | `string` | `null` | No | If not specified, first SNAT table will be used |
| `dmz_eip_addresses` | List of EIP addresses for SNAT | `list(string)` | `[]` | No | Valid IPv4 addresses. If empty, uses EIPs associated with NAT Gateway |

## Outputs

| Name | Description |
|------|-------------|
| `nat_gateway_snat_entry_id` | The ID of the SNAT entry |
| `route_table_id` | The ID of the VPC route table used |
| `dmz_route_table_id` | The ID of the DMZ VPC route table used |
| `snat_table_id` | The ID of the SNAT table used |
| `eip_addresses` | The EIP addresses used for SNAT |

## Examples

### Basic DMZ Egress Configuration

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  dmz_eip_addresses         = ["47.96.1.1", "47.96.1.2"]
}
```

### Using System Route Tables

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  # vpc_route_table_id and dmz_route_table_id not specified - will use system route tables
}
```

### Auto-Discover EIPs from NAT Gateway

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  # dmz_eip_addresses not specified - will use EIPs associated with NAT Gateway
}
```

## Notes

- Requires two providers: `alicloud.vpc` for VPC resources and `alicloud.dmz` for DMZ VPC resources
- System route tables are automatically discovered if route table IDs are not specified
- EIP addresses are automatically discovered from NAT Gateway if not specified
- SNAT table ID is automatically discovered from NAT Gateway if not specified
- The module routes all internet traffic (0.0.0.0/0) from VPC to transit router
- The module routes VPC CIDR from DMZ VPC to transit router for return traffic
- SNAT entry allows VPC resources to access internet through DMZ NAT Gateway
