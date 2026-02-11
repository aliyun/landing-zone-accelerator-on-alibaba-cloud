<div align="right">

**English** | [中文](README-CN.md)

</div>

# CEN VPN Connection Component

This component creates and manages VPN connections (IPsec) in dual-tunnel mode and attaches them to Alibaba Cloud CEN Transit Router.

## Features

- Creates multiple customer gateways (on-premises VPN device representation)
- Creates VPN attachment (IPsec connection) in dual-tunnel mode only
- Attaches VPN Gateway to CEN Transit Router
- Supports IKE, IPsec, and BGP configurations per tunnel
- Supports route auto-publishing to Transit Router
- Provides high availability with automatic failover between tunnels
- Auto-generates PSK (Pre-Shared Key) for tunnels when not provided by user

## Important Note

When binding VPN to Transit Router, **only dual-tunnel mode is supported**. You must configure exactly 2 tunnels with different customer gateways for link redundancy.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_vpn_customer_gateway.customer_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpn_customer_gateway) | resource | Customer gateway (on-premises VPN device) |
| [alicloud_vpn_gateway_vpn_attachment.ipsec_connection](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpn_gateway_vpn_attachment) | resource | IPsec-VPN connection (dual-tunnel mode) |
| [alicloud_cen_transit_router_vpn_attachment.transit_router_vpn_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpn_attachment) | resource | Transit Router VPN attachment |
| [random_string.tunnel_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | Random PSK generation for tunnels when not provided |

## Usage

```hcl
module "vpn_attachment" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id              = "cen-xxxxxxxxxxxxx"
  transit_router_id            = "tr-xxxxxxxxxxxxx"
  customer_gateway_ip_address  = "203.0.113.1"
  customer_gateway_asn         = "65001"

  local_subnet  = "10.0.0.0/16"
  remote_subnet = "192.168.0.0/16"

  ike_config = {
    psk = "your_pre_shared_key"
  }

  ipsec_config = {
    ipsec_enc_alg = "aes"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | The ID of the CEN instance | `string` | - | Yes | - |
| `transit_router_id` | The ID of the Transit Router | `string` | - | Yes | - |
| `customer_gateways` | List of customer gateways to create | `list(object)` | - | Yes | See Customer Gateway Object Structure. Names must be unique. Must have at least 2 gateways |
| `ipsec_connection_name` | The name of the IPsec-VPN connection | `string` | `null` | No | 1-128 chars if not null/empty |
| `local_subnet` | CIDR block(s) on Alibaba Cloud side | `string` | - | Yes | Comma-separated IPv4 CIDRs. Use `0.0.0.0/0` for Destination Routing Mode |
| `remote_subnet` | CIDR block(s) on on-premises side | `string` | - | Yes | Comma-separated IPv4 CIDRs. Use `0.0.0.0/0` for Destination Routing Mode |
| `network_type` | The network type | `string` | `"public"` | No | Must be: `public` or `private` |
| `effect_immediately` | Whether to apply configuration immediately | `bool` | `false` | No | - |
| `enable_tunnels_bgp` | Whether to enable BGP for tunnels | `bool` | `false` | No | If true, tunnel_bgp_config must be configured for each tunnel. Available since v1.246.0 |
| `tunnels_bgp_local_asn` | Local ASN for BGP routing on both tunnels | `number` | `45104` | No | Shared configuration for all tunnels. Only used when enable_tunnels_bgp is true. Range: 1-4294967295 |
| `tunnel_options_specification` | Tunnel configuration | `set(object)` | - | Yes | See Tunnel Options Structure. Must contain exactly 2 tunnels with different customer gateways |
| `transit_router_vpn_attachment_name` | The name of the Transit Router VPN attachment | `string` | `null` | No | 1-128 chars if not null/empty |
| `transit_router_vpn_attachment_description` | The description of the Transit Router VPN attachment | `string` | `null` | No | 1-256 chars if not null/empty |
| `auto_publish_route_enabled` | Whether to automatically publish routes | `bool` | `true` | No | - |
| `cen_tr_route_table_association_enabled` | Enable route table association | `bool` | `false` | No | - |
| `cen_tr_route_table_propagation_enabled` | Enable route table propagation (route learning) | `bool` | `false` | No | - |
| `cen_tr_route_table_id` | Transit Router route table ID for association/propagation | `string` | `null` | No | Required when association or propagation is enabled |
| `ipsec_connection_resource_group_id` | Resource group ID for IPsec-VPN connection | `string` | `null` | No | Available since v1.246.0 |
| `ipsec_connection_tags` | Tags for IPsec-VPN connection | `map(string)` | `null` | No | Available since v1.246.0 |
| `transit_router_vpn_attachment_tags` | Tags for Transit Router VPN attachment | `map(string)` | `null` | No | - |

### Customer Gateway Object Structure

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `ip_address` | `string` | Yes | The public IP address of the customer gateway. Cannot be in ranges: 100.64.0.0~100.127.255.255, 127.0.0.0~127.255.255.255, 169.254.0.0~169.254.255.255, 224.0.0.0~239.255.255.255, 255.0.0.0~255.255.255.255 |
| `asn` | `string` | No | The ASN of the customer gateway for BGP (1-4294967295, cannot be 45104) |
| `name` | `string` | Yes | The name of the customer gateway (1-100 chars, cannot start with http:// or https://) |
| `description` | `string` | No | The description of the customer gateway (1-100 chars, cannot start with http:// or https://) |
| `tags` | `map(string)` | No | Tags to assign to the customer gateway |

### Tunnel Options Structure

Each tunnel object in `tunnel_options_specification` contains:

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `customer_gateway_name` | `string` | - | Yes | Name of the customer gateway from customer_gateways map. Each tunnel must use a different customer gateway |
| `enable_dpd` | `bool` | `true` | No | Whether to enable Dead Peer Detection for this tunnel |
| `enable_nat_traversal` | `bool` | `true` | No | Whether to enable NAT Traversal for this tunnel |
| `tunnel_index` | `number` | - | Yes | Tunnel index: must be 1 or 2 |
| `tunnel_bgp_config` | `object` | `null` | No | BGP configuration for this tunnel (see Tunnel BGP Config) |
| `tunnel_ike_config` | `object` | `null` | No | IKE configuration for this tunnel (see Tunnel IKE Config) |
| `tunnel_ipsec_config` | `list(object)` | `null` | No | IPsec configuration for this tunnel (see Tunnel IPsec Config) |

#### Tunnel BGP Config

Required when `enable_tunnels_bgp` is true. The `local_asn` is configured globally via `tunnels_bgp_local_asn` variable.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `local_bgp_ip` | `string` | Yes | Local BGP IP address for this tunnel |
| `tunnel_cidr` | `string` | Yes | Tunnel CIDR block for this tunnel (mask length 30 within 169.254.0.0/16) |

#### Tunnel IKE Config

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `ike_auth_alg` | `string` | `"sha1"` | No | IKE authentication algorithm |
| `ike_enc_alg` | `string` | `"aes"` | No | IKE encryption algorithm |
| `ike_lifetime` | `number` | `86400` | No | IKE lifetime in seconds |
| `ike_mode` | `string` | `"main"` | No | IKE negotiation mode |
| `ike_pfs` | `string` | `"group2"` | No | IKE perfect forward secrecy |
| `ike_version` | `string` | `"ikev2"` | No | IKE version |
| `local_id` | `string` | `null` | No | Local identifier |
| `psk` | `string` | `null` | No | Pre-shared key. If not provided, a random PSK will be auto-generated. Supports digits, uppercase/lowercase letters, and special characters: `~`!@#$%^&*()_-+={}[]\|;:',.<>/?` (no spaces) |
| `psk_random_length` | `number` | `16` | No | Length of randomly generated PSK when `psk` is not provided. Range: 1-100. Only used when `psk` is not provided |
| `remote_id` | `string` | `null` | No | Remote identifier |

#### Tunnel IPsec Config

| Field | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `ipsec_auth_alg` | `string` | `"sha1"` | No | IPsec authentication algorithm |
| `ipsec_enc_alg` | `string` | `"aes"` | No | IPsec encryption algorithm |
| `ipsec_lifetime` | `number` | `86400` | No | IPsec lifetime in seconds |
| `ipsec_pfs` | `string` | `"group2"` | No | IPsec perfect forward secrecy |

## Outputs

| Name | Description |
|------|-------------|
| `customer_gateway_ids` | Map of customer gateway IDs, keyed by customer gateway name |
| `customer_gateways` | Map of customer gateway details (id, ip_address, asn, name, description), keyed by customer gateway name |
| `ipsec_connection_id` | The ID of the IPsec-VPN connection in dual-tunnel mode |
| `ipsec_connection` | The IPsec-VPN connection details (id, name, local_subnet, remote_subnet, network_type, enable_tunnels_bgp, status, create_time) |
| `transit_router_vpn_attachment_id` | The ID of the Transit Router VPN attachment |
| `route_table_association_id` | The ID of the route table association (null if not enabled) |
| `route_table_propagation_id` | The ID of the route table propagation (null if not enabled) |
| `tunnel_psks` | Map of PSK values for each tunnel, keyed by customer_gateway_name. Includes both user-provided and auto-generated PSKs. Use this output to get the PSK values for configuring your on-premises VPN devices |

## Examples

### Dual-Tunnel VPN Attachment (Required Configuration)

```hcl
module "vpn_attachment_dual_tunnel" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id   = "cen-xxxxxxxxxxxxx"
  transit_router_id = "tr-xxxxxxxxxxxxx"
  
  # Create two customer gateways for redundancy
  customer_gateways = [
    {
      ip_address  = "203.0.113.1"
      asn         = "65001"
      name        = "on-premises-gateway-1"
      description = "Primary VPN gateway"
      tags = {
        Type = "Primary"
      }
    },
    {
      ip_address  = "203.0.113.2"
      asn         = "65002"
      name        = "on-premises-gateway-2"
      description = "Secondary VPN gateway"
      tags = {
        Type = "Secondary"
      }
    }
  ]
  
  ipsec_connection_name = "ipsec-connection-dual-tunnel"

  local_subnet          = "10.0.0.0/16"
  remote_subnet         = "192.168.0.0/16"
  network_type          = "public"
  enable_tunnels_bgp    = true
  tunnels_bgp_local_asn = 45104

  # Configure two tunnels with different customer gateways
  tunnel_options_specification = [
    {
      customer_gateway_name = "on-premises-gateway-1"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 1
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.11.1"
        tunnel_cidr  = "169.254.11.0/30"
      }
      tunnel_ike_config = {
        ike_auth_alg = "sha1"
        ike_enc_alg  = "aes"
        ike_lifetime = 86400
        ike_mode     = "main"
        ike_pfs      = "group2"
        ike_version  = "ikev2"
        local_id     = "tunnel-1-local"
        psk          = "tunnel_1_pre_shared_key"
        remote_id    = "203.0.113.1"
      }
      tunnel_ipsec_config = [
        {
          ipsec_auth_alg = "sha1"
          ipsec_enc_alg  = "aes"
          ipsec_lifetime = 86400
          ipsec_pfs      = "group2"
        }
      ]
    },
    {
      customer_gateway_name = "on-premises-gateway-2"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 2
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.12.1"
        tunnel_cidr  = "169.254.12.0/30"
      }
      tunnel_ike_config = {
        ike_auth_alg = "sha1"
        ike_enc_alg  = "aes"
        ike_lifetime = 86400
        ike_mode     = "main"
        ike_pfs      = "group2"
        ike_version  = "ikev2"
        local_id     = "tunnel-2-local"
        psk          = "tunnel_2_pre_shared_key"
        remote_id    = "203.0.113.2"
      }
      tunnel_ipsec_config = [
        {
          ipsec_auth_alg = "sha1"
          ipsec_enc_alg  = "aes"
          ipsec_lifetime = 86400
          ipsec_pfs      = "group2"
        }
      ]
    }
  ]

  transit_router_vpn_attachment_name        = "tr-vpn-attachment-dual"
  transit_router_vpn_attachment_description = "Transit Router VPN attachment with dual tunnels"
  auto_publish_route_enabled                = true

  # Route table association and propagation
  cen_tr_route_table_association_enabled  = true
  cen_tr_route_table_propagation_enabled  = true
  cen_tr_route_table_id                   = "vtb-xxxxxxxxxxxxx"

  ipsec_connection_resource_group_id = "rg-xxxxxxxxxxxxx"
  ipsec_connection_tags = {
    Environment = "production"
    Project     = "landing-zone"
    Type        = "ipsec-connection"
  }

  transit_router_vpn_attachment_tags = {
    Environment = "production"
    Project     = "landing-zone"
    Type        = "transit-router-attachment"
  }
}
```

### Dual-Tunnel VPN Attachment with Auto-Generated PSK

```hcl
module "vpn_attachment_auto_psk" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id   = "cen-xxxxxxxxxxxxx"
  transit_router_id = "tr-xxxxxxxxxxxxx"
  
  customer_gateways = [
    {
      ip_address  = "203.0.113.1"
      asn         = "65001"
      name        = "on-premises-gateway-1"
      description = "Primary VPN gateway"
    },
    {
      ip_address  = "203.0.113.2"
      asn         = "65002"
      name        = "on-premises-gateway-2"
      description = "Secondary VPN gateway"
    }
  ]
  
  ipsec_connection_name = "ipsec-connection-auto-psk"
  local_subnet          = "10.0.0.0/16"
  remote_subnet         = "192.168.0.0/16"
  network_type          = "public"

  # Configure tunnels without providing PSK - PSK will be auto-generated
  tunnel_options_specification = [
    {
      customer_gateway_name = "on-premises-gateway-1"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 1
      tunnel_ike_config = {
        ike_auth_alg      = "sha1"
        ike_enc_alg       = "aes"
        # psk is not provided - will be auto-generated
        # psk_random_length = 20  # Optional: specify length (default: 16)
      }
    },
    {
      customer_gateway_name = "on-premises-gateway-2"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 2
      tunnel_ike_config = {
        ike_auth_alg      = "sha1"
        ike_enc_alg       = "aes"
        # psk is not provided - will be auto-generated with custom length
        psk_random_length = 24  # Custom length for this tunnel
      }
    }
  ]

  transit_router_vpn_attachment_name = "tr-vpn-attachment-auto-psk"
  auto_publish_route_enabled         = true
}

# After deployment, retrieve PSK values from outputs:
# - module.vpn_attachment_auto_psk.tunnel_psks["on-premises-gateway-1"]
# - module.vpn_attachment_auto_psk.tunnel_psks["on-premises-gateway-2"]
```

## Notes

- The VPN Gateway must be created separately before using this component
- When binding to Transit Router, **only dual-tunnel mode is supported**
- The VPN attachment (IPsec connection) is created in dual-tunnel mode with automatic failover
- The Transit Router VPN attachment binds the VPN Gateway to the CEN Transit Router
- Route auto-publishing can be enabled to automatically publish routes to the Transit Router route table
- Names and descriptions cannot start with `http://` or `https://`

### Dual-Tunnel Requirements
- Must configure exactly 2 tunnels via `tunnel_options_specification`
- Each tunnel must use a different customer gateway for redundancy
- Each tunnel has its own IKE, IPsec, and BGP configuration
- Tunnel indices must be 1 and 2
- Provides automatic failover between tunnels for high availability

### Routing Mode
The routing mode is determined by the values of `local_subnet` and `remote_subnet`:

- **Destination Routing Mode**: Set both `local_subnet` and `remote_subnet` to `0.0.0.0/0`
  - Routes all traffic through the VPN tunnels
  - Suitable for scenarios where all traffic needs to pass through VPN

- **Interested Traffic Mode (Protected Data Flows)**: Set both to specific CIDR blocks
  - Example: `local_subnet = "10.0.0.0/16,172.16.0.0/16"`, `remote_subnet = "192.168.0.0/16"`
  - Only traffic matching these CIDR blocks will be routed through VPN
  - More secure and granular control over VPN traffic
  - Multiple CIDR blocks are separated by commas

### BGP Configuration
- Enable BGP for tunnels by setting `enable_tunnels_bgp = true`
- **Important**: When `enable_tunnels_bgp` is true, you MUST configure `tunnel_bgp_config` for each tunnel in `tunnel_options_specification`
- The `local_asn` is shared across both tunnels and configured globally via `tunnels_bgp_local_asn` (default: 45104)
- Each tunnel requires its own unique `local_bgp_ip` and `tunnel_cidr` (both tunnels use different /30 subnets within 169.254.0.0/16)

### Route Table Association and Propagation
- **Route Table Association**: Associate the Transit Router VPN attachment with a specific route table
  - Enable via `cen_tr_route_table_association_enabled = true`
  - Requires `cen_tr_route_table_id` to be specified
  - Allows the attachment to forward traffic based on the route table entries

- **Route Table Propagation (Route Learning)**: Enable automatic route learning from VPN to Transit Router
  - Enable via `cen_tr_route_table_propagation_enabled = true`
  - Requires `cen_tr_route_table_id` to be specified
  - Automatically propagates VPN routes to the specified route table
  - Useful for dynamic routing scenarios with BGP

### PSK (Pre-Shared Key) Auto-Generation
- If `psk` is not provided in `tunnel_ike_config`, a random PSK will be automatically generated
- The length of the auto-generated PSK can be configured via `psk_random_length` (default: 16, range: 1-100)
- Auto-generated PSK supports digits, uppercase/lowercase letters, and special characters: `~`!@#$%^&*()_-+={}[]\|;:',.<>/?` (no spaces)
- Both user-provided and auto-generated PSKs are available in the `tunnel_psks` output
- **Important**: After deployment, retrieve the PSK values from outputs and configure them on your on-premises VPN devices
