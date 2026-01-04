<div align="right">

**English** | [中文](README-CN.md)

</div>

# DMZ VPC Component

This component creates and manages a DMZ (Demilitarized Zone) VPC for secure outbound internet connectivity, including VPC, vSwitches, NAT Gateway, EIPs, and CEN integration.

## Features

- Creates DMZ VPC with configurable CIDR
- Creates vSwitches for Transit Router (primary and secondary)
- Creates vSwitch for NAT Gateway
- Creates additional vSwitches as needed
- Creates EIP instances with optional common bandwidth package
- Creates NAT Gateway for outbound internet access
- Attaches DMZ VPC to CEN Transit Router
- Configures outbound route entry (0.0.0.0/0) in Transit Router

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
| alicloud.dmz | >= 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| dmz_eip | ../../../modules/eip | EIP instances for NAT Gateway |
| dmz_nat_gateway | ../../../modules/nat-gateway | NAT Gateway for outbound access |
| dmz_vpc_attach_to_cen | ../../../modules/cen-vpc-attach | VPC attachment to CEN Transit Router |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_vpc.dmz_vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | DMZ VPC |
| [alicloud_vswitch.dmz_vswitch_for_tr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | vSwitches for Transit Router (2 required) |
| [alicloud_vswitch.dmz_vswitch_for_nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | vSwitch for NAT Gateway |
| [alicloud_vswitch.dmz_vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | Additional vSwitches |
| [alicloud_cen_transit_router_route_entry.dmz_vpc_outbound](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | Outbound route entry (0.0.0.0/0) |

## Usage

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_name        = "dmz-vpc"
  dmz_vpc_cidr        = "10.0.0.0/16"
  dmz_vpc_description = "DMZ VPC for outbound access"

  dmz_vswitch_for_tr = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "Primary vSwitch for TR"
      vswitch_cidr        = "10.0.1.0/29"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "Secondary vSwitch for TR"
      vswitch_cidr        = "10.0.1.8/29"
    }
  ]

  dmz_vswitch_for_nat_gateway = {
    zone_id             = "cn-hangzhou-h"
    vswitch_name        = "dmz-nat"
    vswitch_description = "vSwitch for NAT Gateway"
    vswitch_cidr        = "10.0.2.0/24"
  }

  dmz_egress_nat_gateway_name = "dmz-nat-gateway"
  dmz_egress_eip_instances = [
    {
      payment_type = "PayAsYouGo"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance | `string` | - | Yes | - |
| `cen_transit_router_id` | The ID of the Transit Router | `string` | - | Yes | - |
| `transit_router_route_table_id` | The ID of the Transit Router route table | `string` | - | Yes | - |
| `dmz_vpc_name` | The name of DMZ VPC | `string` | `null` | No | 1-128 chars if not null, cannot start with http:// or https:// |
| `dmz_vpc_description` | The description of DMZ VPC | `string` | `null` | No | 1-256 chars if not null, cannot start with http:// or https:// |
| `dmz_vpc_cidr` | DMZ VPC CIDR block | `string` | - | Yes | Valid IPv4 CIDR block |
| `dmz_vpc_tags` | Tags for DMZ VPC | `map(string)` | `{}` | No | - |
| `dmz_vswitch_for_tr` | vSwitches for Transit Router | `list(object)` | - | Yes | Must contain exactly 2 vSwitches |
| `dmz_vswitch_for_nat_gateway` | vSwitch for NAT Gateway | `object` | - | Yes | See vSwitch object structure |
| `dmz_vswitch` | Additional vSwitches | `list(object)` | `[]` | No | See vSwitch object structure |
| `dmz_egress_nat_gateway_name` | The name of NAT Gateway | `string` | `null` | No | 2-128 chars if not null |
| `dmz_egress_nat_gateway_tags` | Tags for NAT Gateway | `map(string)` | `{}` | No | - |
| `dmz_egress_eip_instances` | List of EIP instance configs | `list(object)` | `[]` | No | See EIP instance structure |
| `dmz_enable_common_bandwidth_package` | Whether to enable common bandwidth package | `bool` | `true` | No | - |
| `dmz_common_bandwidth_package_name` | The name of common bandwidth package | `string` | `null` | No | 2-256 chars if not null, must start with letter |
| `dmz_common_bandwidth_package_bandwidth` | Bandwidth for common bandwidth package (Mbps) | `string` | `"5"` | No | 1-1000 |
| `dmz_common_bandwidth_package_internet_charge_type` | Billing method | `string` | `"PayByBandwidth"` | No | Must be: `PayByBandwidth`, `PayBy95`, or `PayByDominantTraffic` |
| `dmz_common_bandwidth_package_ratio` | Ratio for PayBy95 billing | `number` | `20` | No | Must be 20 |
| `dmz_tr_attachment_name` | Transit Router VPC attachment name | `string` | `""` | No | 2-128 chars if not empty |
| `dmz_tr_attachment_description` | Transit Router VPC attachment description | `string` | `""` | No | 1-256 chars if not empty |
| `dmz_outbound_route_entry_name` | Name of outbound route entry | `string` | `null` | No | 2-128 chars if not null, must start with letter |
| `dmz_outbound_route_entry_description` | Description of outbound route entry | `string` | `null` | No | 1-256 chars if not null |

### vSwitch Object Structure

Each vSwitch object must have the following structure:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `zone_id` | `string` | Yes | Availability zone ID | - |
| `vswitch_name` | `string` | Yes | vSwitch name | - |
| `vswitch_description` | `string` | Yes | vSwitch description | - |
| `vswitch_cidr` | `string` | Yes | vSwitch CIDR block | Valid IPv4 CIDR block |
| `tags` | `map(string)` | No | Tags for the vSwitch | - |

**Note**: For `dmz_vswitch_for_tr`, exactly 2 vSwitches are required (primary and secondary). Recommend /29 CIDR blocks.

### EIP Instance Object Structure

Each EIP instance object must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `payment_type` | `string` | `"PayAsYouGo"` | No | Payment type | Must be: `Subscription` or `PayAsYouGo` |
| `period` | `number` | `null` | No | Subscription period | Required when `payment_type = "Subscription"` |
| `eip_address_name` | `string` | `null` | No | EIP address name | 1-128 chars if not null, must start with letter |
| `tags` | `map(string)` | `{}` | No | Tags | - |

## Outputs

| Name | Description |
|------|-------------|
| `dmz_vpc_id` | The ID of the DMZ VPC |
| `dmz_route_table_id` | The ID of the DMZ VPC route table |
| `nat_gateway_id` | The ID of the NAT Gateway |
| `dmz_vswitch_for_tr` | List of vSwitches for Transit Router |
| `dmz_vswitch_for_nat_gateway` | vSwitch for NAT Gateway |
| `dmz_vswitch` | List of additional vSwitches |
| `transit_router_vpc_attachment_id` | The ID of the Transit Router VPC attachment |
| `transit_router_outbound_route_entry_id` | The ID of the outbound route entry |
| `eip_instances` | List of EIP instances |
| `common_bandwidth_package_id` | The ID of the common bandwidth package |

## Examples

### Basic DMZ VPC Configuration

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"

  dmz_vswitch_for_tr = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "Primary"
      vswitch_cidr        = "10.0.1.0/29"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "Secondary"
      vswitch_cidr        = "10.0.1.8/29"
    }
  ]

  dmz_vswitch_for_nat_gateway = {
    zone_id             = "cn-hangzhou-h"
    vswitch_name        = "dmz-nat"
    vswitch_description = "NAT Gateway"
    vswitch_cidr        = "10.0.2.0/24"
  }

  dmz_egress_eip_instances = [
    {
      payment_type = "PayAsYouGo"
    }
  ]
}
```

### DMZ with Common Bandwidth Package

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"
  
  dmz_enable_common_bandwidth_package = true
  dmz_common_bandwidth_package_bandwidth = "100"
  dmz_common_bandwidth_package_internet_charge_type = "PayByBandwidth"

  dmz_vswitch_for_tr = [...]
  dmz_vswitch_for_nat_gateway = {...}
  dmz_egress_eip_instances = [...]
}
```

## Notes

- DMZ VPC is designed for secure outbound internet connectivity
- Exactly 2 vSwitches are required for Transit Router attachment (primary and secondary)
- Recommend /29 CIDR blocks for Transit Router vSwitches
- NAT Gateway provides outbound internet access for resources in the DMZ VPC
- EIP instances are automatically associated with NAT Gateway
- Common bandwidth package can be used to share bandwidth across EIP instances
- Transit Router attachment enables connectivity to other VPCs via CEN
- Outbound route entry (0.0.0.0/0) routes all outbound traffic through DMZ VPC
- Route table association and propagation are automatically enabled for Transit Router attachment

