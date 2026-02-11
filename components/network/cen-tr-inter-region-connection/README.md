<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN Transit Router Inter-Region Connection Component

This component creates an inter-region connection (peer attachment) between two CEN Transit Routers and configures route table associations and route entries for both Transit Routers.

## Features

- Creates inter-region connection (peer attachment) between two Transit Routers
- Configures route table associations for both local and peer Transit Routers (optional)
- Configures route table propagations for both local and peer Transit Routers (optional)
- Supports configuring route entries for route tables on both Transit Routers

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud.cen_tr | >= 1.267.0 |
| alicloud.cen_peer_tr | >= 1.267.0 |

This component expects the `alicloud` provider to expose the following **configuration aliases** (see `versions.tf` and stack-level provider config):

- `alicloud.cen_tr` – used for Transit Router resources
- `alicloud.cen_peer_tr` – used for peer Transit Router resources

When using this component directly in Terraform (instead of via `tfcomponent.yaml`), you must define these aliases and wire them into the module, for example:

```hcl
provider "alicloud" {
  alias  = "cen_tr"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "cen_peer_tr"
  region = "cn-beijing"
}

module "cen_tr_inter_region_connection" {
  source = "./components/network/cen-tr-inter-region-connection"

  providers = {
    alicloud.cen_tr      = alicloud.cen_tr
    alicloud.cen_peer_tr = alicloud.cen_peer_tr
  }

  # ...inputs...
}
```

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_transit_router_peer_attachment.peer_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_peer_attachment) | resource | Inter-region connection (peer attachment) |
| [alicloud_cen_transit_router_route_table_association.tr_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | Route table association for Transit Router (optional) |
| [alicloud_cen_transit_router_route_table_association.peer_tr_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | Route table association for peer Transit Router (optional) |
| [alicloud_cen_transit_router_route_table_propagation.tr_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | Route table propagation for Transit Router (optional) |
| [alicloud_cen_transit_router_route_table_propagation.peer_tr_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | Route table propagation for peer Transit Router (optional) |
| [alicloud_cen_transit_router_route_entry.tr_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | Route entries for Transit Router route table |
| [alicloud_cen_transit_router_route_entry.peer_tr_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | Route entries for peer Transit Router route table |

## Usage

```hcl
module "cen_tr_inter_region_connection" {
  source = "./components/network/cen-tr-inter-region-connection"

  providers = {
    alicloud.cen_tr      = alicloud.cen_tr
    alicloud.cen_peer_tr = alicloud.cen_peer_tr
  }

  cen_instance_id                = "cen-xxxxxxxxxxxxx"
  transit_router_id              = "tr-xxxxxxxxxxxxx"
  peer_transit_router_id         = "tr-yyyyyyyyyyyyy"
  peer_transit_router_region_id  = "cn-beijing"

  transit_router_peer_attachment_name   = "sh-bj-inter-region-connection"
  transit_router_attachment_description = "Inter-region connection between Shanghai and Beijing"
  bandwidth                             = 10
  bandwidth_type                        = "BandwidthPackage"
  cen_bandwidth_package_id              = "cenbwp-xxxxxxxxxxxxx"
  auto_publish_route_enabled            = false

  # Route table configuration for Transit Router
  tr_route_table_id                  = "vtb-xxxxxxxxxxxxx"
  tr_route_table_association_enabled  = false
  tr_route_table_propagation_enabled  = false
  tr_route_entries = [
    {
      destination_cidrblock = "10.0.0.0/8"
      name                  = "route-to-peer-tr"
      description           = "Route to peer TR for 10.0.0.0/8"
    },
    {
      destination_cidrblock = "172.16.0.0/12"
      name                  = "route-to-peer-tr-2"
    }
  ]

  # Route table configuration for peer Transit Router
  peer_tr_route_table_id                  = "vtb-zzzzzzzzzzzzz"
  peer_tr_route_table_association_enabled  = false
  peer_tr_route_table_propagation_enabled  = false
  peer_tr_route_entries = [
    {
      destination_cidrblock = "192.168.0.0/16"
      name                  = "route-to-local-tr"
      description           = "Route to local TR for 192.168.0.0/16"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance | `string` | - | Yes | - |
| `transit_router_id` | The ID of the Transit Router | `string` | - | Yes | - |
| `peer_transit_router_id` | The ID of the peer Transit Router | `string` | - | Yes | - |
| `peer_transit_router_region_id` | The region ID where the peer Transit Router is deployed | `string` | `null` | No | - |
| `transit_router_peer_attachment_name` | The name of the peer attachment | `string` | `null` | No | 1-128 chars if not null/empty, cannot start with http:// or https:// |
| `transit_router_attachment_description` | The description of the peer attachment | `string` | `null` | No | 1-256 chars if not null/empty, cannot start with http:// or https:// |
| `bandwidth` | The bandwidth value of the inter-region connection (Mbit/s) | `number` | `2` | No | - |
| `bandwidth_type` | The method to allocate bandwidth | `string` | `"BandwidthPackage"` | No | `BandwidthPackage` or `DataTransfer` (can be null) |
| `cen_bandwidth_package_id` | The ID of the bandwidth plan | `string` | `null` | No | Required when bandwidth_type is BandwidthPackage |
| `default_link_type` | The default line type | `string` | `"Gold"` | No | `Platinum` or `Gold` (can be null; Platinum only supported when bandwidth_type is DataTransfer) |
| `auto_publish_route_enabled` | Whether to enable automatic route advertisement to peer transit router | `bool` | `false` | No | - |
| `tags` | Tags to assign to the peer attachment | `map(string)` | `{}` | No | - |
| `tr_route_table_id` | The route table ID for Transit Router | `string` | - | Yes | - |
| `tr_route_table_association_enabled` | Whether to create route table association for Transit Router | `bool` | `false` | No | - |
| `tr_route_table_propagation_enabled` | Whether to create route table propagation for Transit Router | `bool` | `false` | No | - |
| `tr_route_entries` | List of route entries for Transit Router route table. All route entries use the inter-region connection as the next hop | `list(object)` | `[]` | No | See Route Entry Object Structure below |
| `peer_tr_route_table_id` | The route table ID for peer Transit Router | `string` | - | Yes | - |
| `peer_tr_route_table_association_enabled` | Whether to create route table association for peer Transit Router | `bool` | `false` | No | - |
| `peer_tr_route_table_propagation_enabled` | Whether to create route table propagation for peer Transit Router | `bool` | `false` | No | - |
| `peer_tr_route_entries` | List of route entries for peer Transit Router route table. All route entries use the inter-region connection as the next hop | `list(object)` | `[]` | No | See Route Entry Object Structure below |

### Route Entry Object Structure

Each route entry in `tr_route_entries` or `peer_tr_route_entries` must have the following structure:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `destination_cidrblock` | `string` | Yes | The destination CIDR block for the route entry (valid IPv4 CIDR) |
| `name` | `string` | No | The name of the route entry (1-128 characters, cannot start with http:// or https://) |
| `description` | `string` | No | The description of the route entry (1-256 characters, cannot start with http:// or https://) |

**Note:** 
- Route table associations and propagations are created only when the corresponding `*_enabled` flags are set to `true`.
- All route entries will automatically use the inter-region connection (peer attachment) created by this component as the next hop (`nexthop_type` is fixed to `Attachment`).

## Outputs

| Name | Description |
|------|-------------|
| `peer_attachment_id` | The ID of the inter-region connection (peer attachment) |
| `tr_association_id` | The ID of the route table association for Transit Router (null if not enabled) |
| `peer_tr_association_id` | The ID of the route table association for peer Transit Router (null if not enabled) |
| `tr_propagation_id` | The ID of the route table propagation for Transit Router (null if not enabled) |
| `peer_tr_propagation_id` | The ID of the route table propagation for peer Transit Router (null if not enabled) |
| `tr_route_entries` | List of route entries for Transit Router route table with IDs added |
| `peer_tr_route_entries` | List of route entries for peer Transit Router route table with IDs added |

## Notes

- This component requires two provider aliases: `alicloud.cen_tr` for the Transit Router region and `alicloud.cen_peer_tr` for the peer Transit Router region.
- Both `tr_route_table_id` and `peer_tr_route_table_id` are required parameters.
- Route table associations and propagations are created only when the corresponding `*_enabled` flags are set to `true`.
- Route entries are created for all entries defined in `tr_route_entries` and `peer_tr_route_entries`.
- The inter-region connection is created using the `cen_tr` provider, but both providers are used for route table associations, propagations, and route entries.
