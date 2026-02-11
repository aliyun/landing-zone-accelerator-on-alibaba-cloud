<div align="right">

**English** | [中文](README-CN.md)

</div>

# NAT Gateway Module

This module creates and manages Alibaba Cloud Enhanced NAT Gateway with SNAT entries for outbound internet access.

## Features

- Creates Enhanced NAT Gateway (internet or intranet type)
- Associates EIPs with NAT Gateway
- Creates SNAT entries for source network address translation
- Supports PayAsYouGo billing for Enhanced NAT Gateway

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
| [alicloud_eip_addresses.associated_eips](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/eip_addresses) | data source | Associated EIP addresses lookup (when use_all_associated_eips = true) |
| [alicloud_nat_gateway.nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nat_gateway) | resource | NAT Gateway instance |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP associations with NAT Gateway |
| [alicloud_snat_entry.snat_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/snat_entry) | resource | SNAT entries for outbound traffic |

## Usage

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-uf6v10ktt3tnxxxxxxxx"
  vswitch_id      = "vsw-uf62k55n02gqxxxxxxxx"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-2ze0xxxxxxxxxxxxxxxx"]
  
  snat_entries = [
    {
      source_vswitch_id = "vsw-uf62k55n02gqxxxxxxxx"
      use_all_associated_eips = true
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `vpc_id` | VPC ID for NAT gateway | `string` | `""` | No | Required by underlying resource. Must be a valid VPC ID |
| `vswitch_id` | VSwitch ID for NAT gateway | `string` | - | Yes | - |
| `nat_gateway_name` | Name of the NAT gateway | `string` | `null` | No | 2-128 characters, alphanumeric or hyphens, cannot start/end with hyphen, cannot start with http:// or https:// |
| `description` | Description of the NAT gateway | `string` | `null` | No | 2-256 characters if not null, cannot start with http:// or https:// |
| `force` | Whether to forcefully delete the NAT gateway | `bool` | `false` | No | - |
| `tags` | Tags for NAT Gateway | `map(string)` | `null` | No | - |
| `association_eip_ids` | EIP instance IDs to associate with NAT gateway | `list(string)` | `[]` | No | - |
| `network_type` | Type of NAT gateway | `string` | `"internet"` | No | Must be: `internet` or `intranet` |
| `deletion_protection` | Whether to enable deletion protection for the NAT gateway | `bool` | `false` | No | - |
| `eip_bind_mode` | EIP binding mode of the NAT gateway | `string` | `"MULTI_BINDED"` | No | Must be one of: `MULTI_BINDED`, `NAT` |
| `icmp_reply_enabled` | Whether to enable ICMP reply | `bool` | `true` | No | - |
| `private_link_enabled` | Whether to enable PrivateLink | `bool` | `false` | No | If true, access_mode must be configured appropriately |
| `access_mode` | Access mode configuration for reverse access to the VPC NAT gateway | `set(object)` | `[]` | No | Each entry: `mode_value` in `route` or `tunnel`; if `mode_value = "tunnel"` and `tunnel_type` is set, it must be `geneve`. When `mode_value` is set, `private_link_enabled` must be `true` |
| `snat_entries` | List of SNAT entries to create | `list(object)` | `[]` | No | See SNAT entry structure below |

### SNAT Entry Object Structure

Each SNAT entry in `snat_entries` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `source_cidr` | `string` | `null` | No* | Source CIDR block | Valid CIDR block. Either `source_cidr` or `source_vswitch_id` must be provided, but not both |
| `source_vswitch_id` | `string` | `null` | No* | Source VSwitch ID | Either `source_cidr` or `source_vswitch_id` must be provided, but not both |
| `snat_ips` | `list(string)` | `[]` | No | List of SNAT IP addresses | Required when `use_all_associated_eips = false`, must be valid IP addresses |
| `use_all_associated_eips` | `bool` | `false` | No | Whether to use all associated EIPs | - |
| `snat_entry_name` | `string` | `null` | No | SNAT entry name | 2-128 characters, must start with letter, cannot start with http:// or https:// |
| `eip_affinity` | `number` | `0` | No | EIP affinity | Must be 0 or 1 |

## Outputs

| Name | Description |
|------|-------------|
| `nat_gateway_id` | The ID of the NAT gateway |
| `nat_gateway_snat_entry_ids` | The ID list of SNAT entries |
| `snat_entries` | List of all SNAT entries with detailed information (id, snat_entry_id, snat_ip, source_cidr, source_vswitch_id, snat_entry_name, eip_affinity, snat_table_id, status) |

## Examples

### Basic NAT Gateway

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "my-nat-gateway"
  
  association_eip_ids = ["eip-123456"]
}
```

### NAT Gateway with SNAT Entry for VSwitch

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-123456", "eip-789012"]
  
  snat_entries = [
    {
      source_vswitch_id = "vsw-xyz789"
      use_all_associated_eips = true
      snat_entry_name = "vswitch-snat"
    }
  ]
}
```

### NAT Gateway with SNAT Entry for CIDR

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-123456"]
  
  snat_entries = [
    {
      source_cidr = "192.168.1.0/24"
      snat_ips    = ["47.96.XX.XX"]
      snat_entry_name = "cidr-snat"
    }
  ]
}
```

### Intranet NAT Gateway

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "intranet-nat"
  network_type    = "intranet"
}
```

## Notes


- For SNAT entries, either `source_cidr` or `source_vswitch_id` must be provided, but not both
- When `use_all_associated_eips = true`, all associated EIPs are used for SNAT
- When `use_all_associated_eips = false`, `snat_ips` must be provided with valid IP addresses
- `eip_affinity` controls EIP affinity: 0 for no affinity, 1 for affinity
- SNAT entry names must start with a letter and cannot start with http:// or https://
