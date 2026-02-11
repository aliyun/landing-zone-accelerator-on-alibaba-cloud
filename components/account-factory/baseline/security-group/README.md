<div align="right">

**English** | [中文](README-CN.md)

</div>

## Baseline Security Group Component

This component creates multiple security groups in a VPC (via `modules/security-group`).

## Features

- Create multiple security groups for a VPC baseline
- Support both direct configuration and loading from external configuration files
- Each security group can have its own rules and settings

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.2  |
| alicloud  | >= 1.267.0 |

## Providers

| Name          | Version   |
|---------------|-----------|
| alicloud       | >= 1.267.0 |

## Usage Examples

### Method 1: Direct Configuration

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  security_groups = [
    {
      security_group_name = "sg-web-server"
      description         = "Security group for web servers"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "Production"
        Application = "Web"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "80/80"
          description = "Allow HTTP from anywhere"
        },
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "443/443"
          description = "Allow HTTPS from anywhere"
        }
      ]
    },
    {
      security_group_name = "sg-database"
      description         = "Security group for database servers"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "Production"
        Application = "Database"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "10.0.0.0/8"
          port_range  = "3306/3306"
          description = "Allow MySQL from VPC"
        }
      ]
    }
  ]
}
```

### Method 2: Load from Directory

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  security_group_dir_path = "./security-groups"
}
```

All `.json`, `.yaml`, and `.yml` files in the directory and subdirectories will be processed. Each file must contain a single security group object.

**Example Security Group file (YAML) - Single Security Group Object:**

```yaml
# sg-web-server.yaml
security_group_name: sg-web-server
description: Security group for web servers
inner_access_policy: Accept
security_group_type: normal
tags:
  Environment: Production
  Application: Web
rules:
  - type: ingress
    ip_protocol: tcp
    policy: accept
    priority: 1
    cidr_ip: 0.0.0.0/0
    port_range: 80/80
    description: Allow HTTP from anywhere
  - type: ingress
    ip_protocol: tcp
    policy: accept
    priority: 1
    cidr_ip: 0.0.0.0/0
    port_range: 443/443
    description: Allow HTTPS from anywhere
```

### Method 3: Combined Configuration

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  # Direct security groups
  security_groups = [
    {
      security_group_name = "sg-web-server"
      description         = "Security group for web servers"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "80/80"
          description = "Allow HTTP from anywhere"
        }
      ]
    }
  ]

  # Load additional security groups from directory
  security_group_dir_path = "./security-groups"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_id` | The ID of the VPC in which to create the security groups | `string` | - | Yes |
| `security_groups` | List of security group configurations | `list(object)` | `[]` | No |
| `security_group_dir_path` | Directory path containing security group configuration files (YAML/JSON). Each file in this directory must contain a single security group object. Files will be loaded and combined with security_groups | `string` | `null` | No |

### security_groups Object

Each security group in `security_groups` can have the following structure:

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `security_group_name` | The name of the security group | `string` | Yes |
| `description` | The description of the security group | `string` | No |
| `inner_access_policy` | The internal access control policy. Valid values: `Accept`, `Drop` | `string` | No |
| `resource_group_id` | The ID of the resource group | `string` | No |
| `security_group_type` | The type of the security group. Valid values: `normal`, `enterprise` | `string` | No |
| `tags` | Tags of the security group | `map(string)` | No |
| `rules` | List of security group rules | `list(object)` | No |

### rules Object

Each rule in `rules` can have the following structure:

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `type` | The type of rule. Valid values: `ingress`, `egress` | `string` | - |
| `ip_protocol` | The IP protocol. Valid values: `tcp`, `udp`, `icmp`, `icmpv6`, `gre`, `all` | `string` | - |
| `policy` | The policy of the rule. Valid values: `accept`, `drop` | `string` | `"accept"` |
| `priority` | The priority of the rule (1-100) | `number` | `1` |
| `cidr_ip` | The CIDR IP address | `string` | - |
| `ipv6_cidr_ip` | The IPv6 CIDR IP address | `string` | - |
| `source_security_group_id` | The source security group ID | `string` | - |
| `source_group_owner_account` | The source security group owner account | `string` | - |
| `prefix_list_id` | The prefix list ID | `string` | - |
| `port_range` | The port range (e.g., "80/80", "80/90", "-1/-1" for all ports) | `string` | `"-1/-1"` |
| `nic_type` | The network interface type. Valid values: `internet`, `intranet` | `string` | `"internet"` |
| `description` | The description of the rule | `string` | - |

## Outputs

| Name | Description |
|------|-------------|
| `security_groups` | Map of all created security groups, keyed by security_group_name, including security group details and rules |
| `security_group_ids` | Map of security group IDs, keyed by security_group_name |
| `security_group_names` | Map of security group names, keyed by security_group_name |

## Notes

- Security groups are created using `for_each`, so each security group name must be unique within the VPC
- When loading from directory, each file must contain a single security group object
- Direct configuration and directory-loaded security groups are combined, with direct configuration taking precedence if there are duplicate names
- All security groups are created in the same VPC specified by `vpc_id`

