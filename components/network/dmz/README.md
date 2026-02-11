<div align="right">

**English** | [中文](README-CN.md)

</div>

# DMZ VPC Component

This component creates and manages a DMZ (Demilitarized Zone) VPC for secure outbound internet connectivity, including VPC, vSwitches, NAT Gateway, EIPs, and CEN integration.

## Features

- Creates DMZ VPC with configurable CIDR
- Creates vSwitches with configurable purpose
- Creates EIP instances with optional common bandwidth package
- Creates NAT Gateway for outbound internet access
- Attaches DMZ VPC to CEN Transit Router
- Configures outbound route entry (0.0.0.0/0) in Transit Router

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
| alicloud.dmz | >= 1.267.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| dmz_vpc | ../../../modules/vpc | DMZ VPC and vSwitches |
| dmz_eip | ../../../modules/eip | EIP instances for NAT Gateway |
| dmz_nat_gateway | ../../../modules/nat-gateway | NAT Gateway for outbound access |
| dmz_vpc_attach_to_cen | ../../../modules/cen-vpc-attach | VPC attachment to CEN Transit Router |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_route_entry.dmz_cen_route_entries](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_entry) | resource | CEN route entries to publish routes to CEN route tables |

## Usage

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz    = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_name        = "dmz-vpc"
  dmz_vpc_cidr        = "10.0.0.0/16"
  dmz_vpc_description = "DMZ VPC for outbound access"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "Primary vSwitch for TR"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "Secondary vSwitch for TR"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "vSwitch for NAT Gateway"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]

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
| `dmz_vswitch` | vSwitches in DMZ VPC | `list(object)` | - | Yes | Must contain at least 2 vSwitches with `purpose="TR"` and exactly 1 vSwitch with `purpose="NATGW"`. See vSwitch object structure |
| `dmz_egress_nat_gateway_name` | The name of NAT Gateway | `string` | `null` | No | 2-128 chars if not null |
| `dmz_egress_nat_gateway_description` | Description of the DMZ NAT Gateway | `string` | `null` | No | 2-256 chars if not null, must not start with http:// or https:// |
| `dmz_egress_nat_gateway_tags` | Tags for NAT Gateway | `map(string)` | `{}` | No | - |
| `dmz_egress_nat_gateway_deletion_protection` | Whether to enable deletion protection for the DMZ NAT Gateway | `bool` | `false` | No | - |
| `dmz_egress_nat_gateway_eip_bind_mode` | EIP binding mode of the DMZ NAT Gateway | `string` | `"MULTI_BINDED"` | No | One of: `MULTI_BINDED`, `NAT` |
| `dmz_egress_nat_gateway_icmp_reply_enabled` | Whether to enable ICMP reply on the DMZ NAT Gateway | `bool` | `true` | No | - |
| `dmz_egress_nat_gateway_private_link_enabled` | Whether to enable PrivateLink on the DMZ NAT Gateway | `bool` | `false` | No | If true, `dmz_egress_nat_gateway_access_mode` should be configured appropriately |
| `dmz_egress_nat_gateway_access_mode` | Access mode configuration for reverse access to the DMZ NAT Gateway | `set(object)` | `[]` | No | Each entry: `mode_value` in `route` or `tunnel`; if `mode_value = "tunnel"` and `tunnel_type` is set, it must be `geneve` |
| `dmz_nat_gateway_snat_entries` | SNAT entries configuration for the DMZ NAT Gateway | `list(object)` | `[]` | No | Only `source_cidr` is supported (not `source_vswitch_id`). Each entry must have `source_cidr` (required). See SNAT entry object structure below |
| `dmz_vpc_route_entries` | Route entries for the DMZ VPC system route table. All entries use Transit Router attachment as next hop | `list(object)` | `[]` | No | See Route entry object structure below |
| `dmz_egress_eip_instances` | List of EIP instance configs | `list(object)` | `[]` | No | See EIP instance structure |
| `dmz_enable_common_bandwidth_package` | Whether to enable common bandwidth package | `bool` | `true` | No | - |
| `dmz_common_bandwidth_package_name` | The name of common bandwidth package | `string` | `null` | No | 2-256 chars if not null, must start with letter |
| `dmz_common_bandwidth_package_bandwidth` | Bandwidth for common bandwidth package (Mbps) | `string` | `"5"` | No | 1-1000 |
| `dmz_common_bandwidth_package_internet_charge_type` | Billing method | `string` | `"PayByBandwidth"` | No | Must be: `PayByBandwidth`, `PayBy95`, or `PayByDominantTraffic` |
| `dmz_common_bandwidth_package_ratio` | Ratio for PayBy95 billing | `number` | `20` | No | Must be 20 |
| `dmz_common_bandwidth_package_deletion_protection` | Whether to enable deletion protection | `bool` | `false` | No | - |
| `dmz_common_bandwidth_package_description` | The description of the Internet Shared Bandwidth instance | `string` | `null` | No | 0-256 chars if not null, cannot start with http:// or https:// |
| `dmz_common_bandwidth_package_isp` | The line type of the common bandwidth package | `string` | `"BGP"` | No | Must be: `BGP` or `BGP_PRO` |
| `dmz_common_bandwidth_package_resource_group_id` | The ID of the resource group | `string` | `null` | No | - |
| `dmz_common_bandwidth_package_security_protection_types` | The edition of Anti-DDoS | `list(string)` | `[]` | No | Empty list for Basic, `AntiDDoS_Enhanced` for Pro. Valid when internet_charge_type is PayBy95. Maximum 10 elements |
| `dmz_common_bandwidth_package_tags` | The tags of the common bandwidth package resource | `map(string)` | `{}` | No | - |
| `dmz_tr_attachment_name` | Transit Router VPC attachment name | `string` | `""` | No | 2-128 chars if not empty |
| `dmz_tr_attachment_description` | Transit Router VPC attachment description | `string` | `""` | No | 1-256 chars if not empty |
| `dmz_tr_route_table_association_enabled` | Whether to enable route table association for the Transit Router VPC attachment | `bool` | `true` | No | - |
| `dmz_tr_route_table_propagation_enabled` | Whether to enable route table propagation for the Transit Router VPC attachment | `bool` | `true` | No | - |
| `dmz_tr_attachment_force_delete` | Whether to forcibly delete the DMZ VPC attachment and related dependencies | `bool` | `false` | No | - |
| `dmz_tr_attachment_tags` | Tags for the DMZ transit router VPC attachment | `map(string)` | `{}` | No | - |
| `dmz_tr_attachment_options` | TransitRouterVpcAttachmentOptions for the DMZ VPC attachment | `map(string)` | `{}` | No | - |
| `cen_service_linked_role_exists` | Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role. If false, the module will create it | `bool` | `false` | No | - |
| `create_cen_instance_grant` | Whether to create CEN instance grant for cross-account attachment. **Must be set to `true` when CEN and VPC are in different accounts, and `false` when they are in the same account.**  | `bool` | `false` | No | - |
| `dmz_tr_attachment_auto_publish_route_enabled` | Specifies whether to enable the Enterprise Edition transit router to automatically advertise routes to VPCs | `bool` | `false` | No | - |
| `cen_route_entry_cidr_blocks` | List of CIDR blocks to publish as CEN route entries. Routes will be published to the Transit Router route table | `list(string)` | `[]` | No | Each entry must be a valid IPv4 CIDR block |

### vSwitch Object Structure

Each vSwitch object must have the following structure:

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `zone_id` | `string` | Yes | Availability zone ID | - |
| `vswitch_name` | `string` | Yes | vSwitch name | - |
| `vswitch_description` | `string` | Yes | vSwitch description | - |
| `vswitch_cidr` | `string` | Yes | vSwitch CIDR block | Valid IPv4 CIDR block |
| `purpose` | `string` | No | vSwitch purpose | `"TR"` for Transit Router attachment, `"NATGW"` for NAT Gateway, or `null`/empty for normal vSwitch |
| `tags` | `map(string)` | No | Tags for the vSwitch | - |

**Note**: 
- At least 2 vSwitches with `purpose="TR"` are required (primary and secondary). Recommend /29 CIDR blocks for TR vSwitches.
- Exactly 1 vSwitch with `purpose="NATGW"` is required for NAT Gateway.
- Additional vSwitches without `purpose` (or `purpose=null`) can be added as needed for normal use.

**Note**: 
- CEN route entries are created after all other resources are ready (VPC, EIP, NAT Gateway, and CEN VPC attachment).
- All route entries are published to the Transit Router route table specified by `transit_router_route_table_id`.

### EIP Instance Object Structure

Each EIP instance object must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `eip_address_name` | `string` | `null` | No | EIP address name | 1-128 chars if not null, start with letter, only letters, digits, periods, underscores, hyphens |
| `payment_type` | `string` | `"PayAsYouGo"` | No | Payment type | Must be: `Subscription` or `PayAsYouGo` |
| `period` | `number` | `null` | No | Subscription period | Required when `payment_type = "Subscription"`. When `pricing_cycle = "Month"`, range is 1-9. When `pricing_cycle = "Year"`, range is 1-5 |
| `pricing_cycle` | `string` | `null` | No | Billing cycle for subscription EIP | Must be: `Month` or `Year`. Required when `payment_type = "Subscription"` |
| `auto_pay` | `bool` | `false` | No | Enable automatic payment | Required when `payment_type = "Subscription"` |
| `bandwidth` | `number` | `5` | No | Maximum bandwidth (Mbit/s) | PayAsYouGo + PayByBandwidth: 1-500. PayAsYouGo + PayByTraffic: 1-200. Subscription: 1-1000 |
| `deletion_protection` | `bool` | `false` | No | Enable deletion protection | - |
| `description` | `string` | `null` | No | EIP description | 2-256 characters, start with letter, cannot start with http:// or https:// |
| `internet_charge_type` | `string` | `"PayByBandwidth"` | No | Metering method | Must be: `PayByBandwidth` or `PayByTraffic`. When `payment_type = "Subscription"`, must be `PayByBandwidth` |
| `ip_address` | `string` | `null` | No | IP address of the EIP | Supports up to 50 EIPs |
| `isp` | `string` | `"BGP"` | No | Line type | Must be: `BGP` or `BGP_PRO` |
| `mode` | `string` | `null` | No | Association mode | Must be: `NAT`, `MULTI_BINDED`, or `BINDED` |
| `netmode` | `string` | `"public"` | No | Network type | Must be: `public` |
| `public_ip_address_pool_id` | `string` | `null` | No | IP address pool ID | EIP is allocated from the IP address pool |
| `resource_group_id` | `string` | `null` | No | Resource group ID | - |
| `security_protection_type` | `string` | `null` | No | Security protection level | Empty string for basic DDoS protection, `"antidos_enhanced"` for enhanced DDoS protection |
| `tags` | `map(string)` | `{}` | No | Tags for the EIP | - |

### SNAT Entry Object Structure

Each SNAT entry object must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `source_cidr` | `string` | - | Yes | Source CIDR block for SNAT | Valid IPv4 CIDR block |
| `snat_entry_name` | `string` | `null` | No | SNAT entry name | 2-128 chars if not null, must start with a letter, cannot start with http:// or https:// |
| `eip_affinity` | `number` | `0` | No | EIP affinity mode | Must be `0` or `1` |

**Note**: 
- Only `source_cidr` is supported. `source_vswitch_id` is not allowed in this component.
- `snat_ips` will be automatically set to all EIP IPs created by this component (`dmz_egress_eip_instances`). You don't need to specify `snat_ips` or `use_all_associated_eips` in the configuration.

### Route Entry Object Structure

Each route entry object must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `destination_cidrblock` | `string` | - | Yes | Destination CIDR block | Valid IPv4 CIDR block (e.g., 0.0.0.0/0) |
| `name` | `string` | `null` | No | Route entry name | 1-128 characters, cannot start with http:// or https:// |
| `description` | `string` | `null` | No | Route entry description | 1-256 characters, cannot start with http:// or https:// |

**Note**: Route entries are always added to the VPC system route table. All route entries automatically use the Transit Router attachment as the next hop (`nexthop_type` is fixed to `Attachment`). Route entries are created by the `modules/cen-vpc-attach` module after the CEN attachment is established.

## Outputs

| Name | Description |
|------|-------------|
| `dmz_vpc_id` | The ID of the DMZ VPC |
| `dmz_route_table_id` | The ID of the DMZ VPC route table |
| `nat_gateway_id` | The ID of the NAT Gateway |
| `dmz_vswitch` | List of all vSwitches with their purpose |
| `dmz_vswitch_for_tr` | List of vSwitches for Transit Router (filtered by `purpose="TR"`) |
| `dmz_vswitch_for_nat_gateway` | vSwitch for NAT Gateway (filtered by `purpose="NATGW"`) |
| `transit_router_vpc_attachment_id` | The ID of the Transit Router VPC attachment |
| `eip_instances` | List of EIP instances |
| `common_bandwidth_package_id` | The ID of the common bandwidth package |

## Examples

### Basic DMZ VPC Configuration

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz    = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "Primary vSwitch for TR"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "Secondary vSwitch for TR"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "vSwitch for NAT Gateway"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]

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
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz    = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"
  
  dmz_enable_common_bandwidth_package = true
  dmz_common_bandwidth_package_bandwidth = "100"
  dmz_common_bandwidth_package_internet_charge_type = "PayByBandwidth"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "Primary vSwitch for TR"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "Secondary vSwitch for TR"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "vSwitch for NAT Gateway"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]
  dmz_egress_eip_instances = [...]
}
```

## Notes

- DMZ VPC is designed for secure outbound internet connectivity
- At least 2 vSwitches with `purpose="TR"` are required for Transit Router attachment (primary and secondary)
- Exactly 1 vSwitch with `purpose="NATGW"` is required for NAT Gateway
- Recommend /29 CIDR blocks for Transit Router vSwitches
- NAT Gateway provides outbound internet access for resources in the DMZ VPC
- EIP instances are automatically associated with NAT Gateway
- Common bandwidth package can be used to share bandwidth across EIP instances
- Transit Router attachment enables connectivity to other VPCs via CEN
- Outbound route entry (0.0.0.0/0) routes all outbound traffic through DMZ VPC
- Route table association and propagation can be controlled via `dmz_tr_route_table_association_enabled` and `dmz_tr_route_table_propagation_enabled` variables (default: `true`)

