<div align="right">

**English** | [中文](README-CN.md)

</div>

# VPC Module

This module creates and manages Alibaba Cloud Virtual Private Cloud (VPC) resources, including VPC, VSwitches, and optional Network ACL configuration.

## Features

- Creates VPC with IPv4 and optional IPv6 support
- Creates multiple VSwitches across different availability zones
- Optional Network ACL with ingress and egress rules
- Supports IPAM (IP Address Manager) integration
- Configures user-defined CIDR blocks
- Supports resource group assignment

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
| [alicloud_vpc.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | Virtual Private Cloud |
| [alicloud_vswitch.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | VSwitches (one or more) |
| [alicloud_network_acl.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/network_acl) | resource | Network ACL (optional) |

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "production-vpc"
  vpc_cidr        = "192.168.0.0/16"
  vpc_description = "Production VPC"
  
  vswitches = [
    {
      cidr_block   = "192.168.1.0/24"
      zone_id      = "cn-hangzhou-h"
      vswitch_name = "vswitch-1"
    },
    {
      cidr_block   = "192.168.2.0/24"
      zone_id      = "cn-hangzhou-i"
      vswitch_name = "vswitch-2"
    }
  ]
  
  enable_acl = true
  acl_name   = "production-acl"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `vpc_name` | The name of the VPC | `string` | `null` | No | 1-128 characters, cannot start with http:// or https:// |
| `vpc_cidr` | The CIDR block of the VPC | `string` | `null` | No | Valid IPv4 CIDR block (e.g., 192.168.0.0/16) |
| `vpc_description` | The description of the VPC | `string` | `null` | No | 1-256 characters, cannot start with http:// or https:// |
| `enable_ipv6` | Whether to enable IPv6 for the VPC | `bool` | `false` | No | - |
| `ipv6_isp` | The type of IPv6 CIDR block | `string` | `"BGP"` | No | Must be: `BGP`, `ChinaMobile`, `ChinaUnicom`, `ChinaTelecom` |
| `resource_group_id` | The ID of the resource group | `string` | `null` | No | - |
| `user_cidrs` | List of user CIDR blocks | `list(string)` | `null` | No | Up to 3 CIDR blocks |
| `ipv4_cidr_mask` | Allocate VPC from IPAM pool by mask | `number` | `null` | No | 0-32 (e.g., 16 for /16) |
| `ipv4_ipam_pool_id` | The ID of the IPAM pool for IPv4 | `string` | `null` | No | - |
| `ipv6_cidr_block` | The IPv6 CIDR block | `string` | `null` | No | Required when `enable_ipv6 = true` |
| `vpc_tags` | Tags of the VPC | `map(string)` | `{}` | No | - |
| `vswitches` | List of VSwitches | `list(object)` | `[]` | No | See VSwitch object structure below |
| `enable_acl` | Whether to enable VPC Network ACL | `bool` | `false` | No | - |
| `acl_name` | The name of the network ACL | `string` | `null` | No | 1-128 characters, cannot start with http:// or https:// |
| `acl_description` | The description of the network ACL | `string` | `null` | No | 1-256 characters, cannot start with http:// or https:// |
| `acl_tags` | The tags of the network ACL | `map(string)` | `{}` | No | - |
| `ingress_acl_entries` | List of ingress ACL entries | `list(object)` | `[]` | No | See ACL entry structure below |
| `egress_acl_entries` | List of egress ACL entries | `list(object)` | `[]` | No | See ACL entry structure below |

### VSwitch Object Structure

Each VSwitch in `vswitches` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `cidr_block` | `string` | - | Yes | CIDR block for the VSwitch | Valid IPv4 CIDR block (e.g., 192.168.1.0/24) |
| `zone_id` | `string` | - | Yes | Availability zone ID | - |
| `vswitch_name` | `string` | `null` | No | Name of the VSwitch | - |
| `description` | `string` | `null` | No | Description of the VSwitch | - |
| `enable_ipv6` | `bool` | `null` | No | Whether to enable IPv6 | - |
| `ipv6_cidr_block_mask` | `number` | `null` | No | IPv6 CIDR block mask | - |
| `tags` | `map(string)` | `null` | No | Tags for the VSwitch | If null or empty, inherits VPC tags |

### ACL Entry Object Structure

Each entry in `ingress_acl_entries` or `egress_acl_entries` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `protocol` | `string` | - | Yes | Protocol type | Must be: `icmp`, `gre`, `tcp`, `udp`, `all` |
| `port` | `string` | - | Yes | Port range | `-1/-1` for all/icmp/gre, or `1-65535/1-65535` for tcp/udp |
| `source_cidr_ip` | `string` | - | Yes (ingress) | Source CIDR IP | - |
| `destination_cidr_ip` | `string` | - | Yes (egress) | Destination CIDR IP | - |
| `policy` | `string` | `"accept"` | No | Policy action | Must be: `accept` or `drop` |
| `description` | `string` | `null` | No | Entry description | 1-256 characters, cannot start with http:// or https:// |
| `network_acl_entry_name` | `string` | `null` | No | Entry name | 1-128 characters, cannot start with http:// or https:// |
| `ip_version` | `string` | `"IPV4"` | No | IP version | Must be: `IPV4` or `IPV6` |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | The ID of the VPC |
| `vswitch_ids` | List of all VSwitch IDs |
| `network_acl_id` | The ID of the VPC ACL (if enabled) |

## Examples

### Basic VPC with VSwitches

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "my-vpc"
  vpc_cidr        = "10.0.0.0/16"
  vpc_description = "My VPC"
  
  vswitches = [
    {
      cidr_block   = "10.0.1.0/24"
      zone_id      = "cn-hangzhou-h"
      vswitch_name = "vswitch-zone-h"
    },
    {
      cidr_block   = "10.0.2.0/24"
      zone_id      = "cn-hangzhou-i"
      vswitch_name = "vswitch-zone-i"
    }
  ]
}
```

### VPC with Network ACL

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "secure-vpc"
  vpc_cidr        = "172.16.0.0/16"
  
  vswitches = [
    {
      cidr_block = "172.16.1.0/24"
      zone_id    = "cn-hangzhou-h"
    }
  ]
  
  enable_acl = true
  acl_name   = "secure-acl"
  
  ingress_acl_entries = [
    {
      protocol       = "tcp"
      port           = "80/80"
      source_cidr_ip = "0.0.0.0/0"
      policy         = "accept"
      description    = "Allow HTTP"
    },
    {
      protocol       = "tcp"
      port           = "443/443"
      source_cidr_ip = "0.0.0.0/0"
      policy         = "accept"
      description    = "Allow HTTPS"
    }
  ]
  
  egress_acl_entries = [
    {
      protocol            = "all"
      port                = "-1/-1"
      destination_cidr_ip = "0.0.0.0/0"
      policy              = "accept"
      description         = "Allow all outbound"
    }
  ]
}
```

### VPC with IPv6

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "ipv6-vpc"
  vpc_cidr        = "192.168.0.0/16"
  enable_ipv6     = true
  ipv6_isp        = "BGP"
  ipv6_cidr_block = "2408:4004:cc0::/56"
  
  vswitches = [
    {
      cidr_block      = "192.168.1.0/24"
      zone_id         = "cn-hangzhou-h"
      enable_ipv6     = true
      ipv6_cidr_block_mask = 64
    }
  ]
}
```

### VPC with IPAM

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name         = "ipam-vpc"
  ipv4_ipam_pool_id = "ipam-pool-123456"
  ipv4_cidr_mask    = 16
  
  vswitches = [
    {
      cidr_block = "10.0.1.0/24"
      zone_id    = "cn-hangzhou-h"
    }
  ]
}
```

## Notes

- VPC CIDR block must be a valid IPv4 CIDR (e.g., 192.168.0.0/16)
- VSwitch CIDR blocks must be within the VPC CIDR block
- When `enable_acl = true`, all VSwitches are automatically associated with the ACL
- ACL name defaults to `{vpc_name}-acl` if not specified
- VSwitch tags inherit from VPC tags if not specified
- IPv6 requires `enable_ipv6 = true` and `ipv6_cidr_block` to be set
- IPAM integration requires `ipv4_ipam_pool_id` and either `vpc_cidr` or `ipv4_cidr_mask`
