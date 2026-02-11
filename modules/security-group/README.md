<div align="right">

**English** | [中文](README-CN.md)

</div>

# Security Group Module

This module creates and manages Alibaba Cloud Security Groups and their rules.

## Features

- Creates security groups with configurable parameters
- Creates multiple security group rules (ingress/egress)

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
| [alicloud_security_group.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource | Security Group |
| [alicloud_security_group_rule.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | Security Group Rules |

## Usage

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  description         = "Security group for web servers"
  security_group_type = "normal"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      nic_type    = "internet"
      description = "Allow HTTP access"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      nic_type    = "internet"
      description = "Allow HTTPS access"
    },
    {
      type        = "egress"
      ip_protocol = "all"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      description = "Allow all outbound traffic"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `vpc_id` | The ID of the VPC in which you want to create the security group | `string` | - | Yes | - |
| `security_group_name` | The name of the security group | `string` | `null` | No | 2-128 characters, start with a letter, cannot start with http:// or https:// |
| `description` | The description of the security group | `string` | `null` | No | 2-256 characters, cannot start with http:// or https:// |
| `inner_access_policy` | The internal access control policy of the security group | `string` | `null` | No | Must be: `Accept` or `Drop` |
| `resource_group_id` | The ID of the resource group to which the security group belongs | `string` | `null` | No | - |
| `security_group_type` | The type of the security group | `string` | `"normal"` | No | Must be: `normal` or `enterprise` |
| `tags` | A mapping of tags to assign to the security group | `map(string)` | `{}` | No | - |
| `rules` | List of security group rules to create | `list(object)` | `[]` | No | See Rule Object Structure below |

### Rule Object Structure

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `type` | The type of the Security Group Rule | `string` | - | Yes | Must be: `ingress` or `egress` |
| `ip_protocol` | The transport layer protocol of the Security Group Rule | `string` | - | Yes | Must be: `tcp`, `udp`, `icmp`, `icmpv6`, `gre`, `all` |
| `policy` | The action of the Security Group Rule | `string` | `"accept"` | No | Must be: `accept` or `drop` |
| `priority` | The priority of the Security Group Rule | `number` | `1` | No | Must be between 1 and 100 |
| `cidr_ip` | The target IP address range (IPv4) | `string` | `null` | No | Cannot be set together with `ipv6_cidr_ip` |
| `ipv6_cidr_ip` | Source IPv6 CIDR address block | `string` | `null` | No | Cannot be set together with `cidr_ip` |
| `source_security_group_id` | The target security group ID within the same region | `string` | `null` | No | If set, `nic_type` can only be `intranet` |
| `source_group_owner_account` | The Alibaba Cloud user account Id of the target security group when security groups are authorized across accounts | `string` | `null` | No | Invalid if `cidr_ip` is set |
| `prefix_list_id` | The ID of the source/destination prefix list | `string` | `null` | No | Ignored if `cidr_ip`, `source_security_group_id`, or `ipv6_cidr_ip` is set |
| `port_range` | The range of port numbers relevant to the IP protocol | `string` | `"-1/-1"` | No | For tcp/udp: 1-65535, format: "start/end" |
| `nic_type` | Network type | `string` | `"internet"` | No | Must be: `internet` or `intranet` |
| `description` | The description of the security group rule | `string` | `null` | No | 1-512 characters |

## Outputs

| Name | Description |
|------|-------------|
| `security_group_id` | The ID of the security group |
| `security_group_name` | The name of the security group |
| `rule_ids` | List of security group rule IDs |
| `rules` | List of security group rules with their IDs and details (includes `rule_id` and all rule attributes) |

## Examples

### Basic Security Group

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  description         = "Security group for web servers"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}
```

### Security Group with Multiple Rules

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "app-sg"
  description         = "Security group for application servers"
  security_group_type = "enterprise"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "8080/8080"
      cidr_ip     = "10.0.0.0/8"
      policy      = "accept"
      priority    = 1
      nic_type    = "intranet"
      description = "Allow internal access to application port"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "192.168.1.0/24"
      policy      = "accept"
      priority    = 10
      nic_type    = "intranet"
      description = "Allow SSH from management network"
    },
    {
      type        = "egress"
      ip_protocol = "all"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      description = "Allow all outbound traffic"
    }
  ]
}
```

### Security Group with Source Security Group

```hcl
module "web_sg" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}

module "app_sg" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "app-sg"
  
  rules = [
    {
      type                     = "ingress"
      ip_protocol              = "tcp"
      port_range               = "8080/8080"
      source_security_group_id = module.web_sg.security_group_id
      nic_type                 = "intranet"
      description              = "Allow access from web security group"
    }
  ]
}
```

## Notes

- `vpc_id` is required and cannot be empty
- Security group rules use a composite key to prevent resource recreation when the order changes
- Only one of `cidr_ip`, `ipv6_cidr_ip`, `source_security_group_id`, or `prefix_list_id` can be set per rule
- When `source_security_group_id` is set, `nic_type` can only be `intranet`
- For `tcp` and `udp` protocols, `port_range` must be in format "start/end" (e.g., "80/80" or "8000/9000")
- For other protocols, `port_range` should be "-1/-1"
- `priority` determines the order of rule evaluation (lower numbers have higher priority)
- `policy` determines whether to accept or drop matching traffic

