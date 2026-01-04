<div align="right">

**English** | [中文](README-CN.md)

</div>

# Cloud Firewall Component

This component creates and manages Alibaba Cloud Cloud Firewall instance, member account management, and internet boundary firewall rules.

## Features

- Creates Cloud Firewall instance
- Manages member accounts for centralized firewall management
- Configures internet boundary protection for SLB resources
- Configures internet ACL rules
- Supports directory-based and inline configuration merging
- Directory configuration takes precedence over inline configuration

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
| [alicloud_cloud_firewall_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance) | resource | Cloud Firewall instance |
| [alicloud_cloud_firewall_instance_member.members](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance_member) | resource | Member accounts |
| [alicloud_cloud_firewall_control_policy.internet_protection](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | Internet boundary protection policy |
| [alicloud_cloud_firewall_control_policy.internet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | Internet ACL rules |

## Usage

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium"
  cloud_firewall_bandwidth       = 100
  cloud_firewall_payment_type    = "PayAsYouGo"

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]

  enable_internet_protection = true
  internet_protection_source = "0.0.0.0/0"
  internet_protection_destination = "10.0.0.0/8"

  internet_acl_rules = [
    {
      description      = "Allow HTTP from internet"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "80"
      destination_port = "80"
      policy           = "accept"
      direction        = "in"
      priority         = 1
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_cloud_firewall_instance` | Whether to create a cloud firewall instance | `bool` | `true` | No | - |
| `cloud_firewall_instance_type` | The type of the cloud firewall instance | `string` | `"premium"` | No | Valid instance type |
| `cloud_firewall_bandwidth` | The bandwidth of the cloud firewall instance | `number` | `100` | No | - |
| `cloud_firewall_payment_type` | The payment type of the cloud firewall instance | `string` | `"PayAsYouGo"` | No | - |
| `member_account_ids` | List of member account IDs to be managed | `list(string)` | `[]` | No | - |
| `member_account_ids_dir` | Directory path containing member account configuration files | `string` | `null` | No | Supports .json, .yaml, .yml |
| `internet_acl_rules` | List of internet ACL rules | `list(object)` | `[]` | No | Valid rule configuration |
| `internet_acl_rules_dir` | Directory path containing internet ACL rule configuration files | `string` | `null` | No | Supports .json, .yaml, .yml |
| `enable_internet_protection` | Whether to enable internet boundary protection | `bool` | `false` | No | - |
| `internet_protection_source` | Source CIDR for internet boundary protection | `string` | `"0.0.0.0/0"` | No | - |
| `internet_protection_destination` | Destination CIDR for internet boundary protection | `string` | `"0.0.0.0/0"` | No | - |
| `internet_protection_application` | Application name for internet boundary protection | `string` | `"ANY"` | No | - |
| `internet_protection_port` | Port for internet boundary protection | `string` | `"80"` | No | - |
| `control_policy_application_name` | The application name for control policies | `string` | `"ANY"` | No | - |
| `control_policy_source_type` | The source type for control policies | `string` | `"net"` | No | - |
| `control_policy_destination_type` | The destination type for control policies | `string` | `"net"` | No | - |

### internet_acl_rules Object

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `description` | Rule description | `string` | Yes |
| `source_cidr` | Source CIDR block | `string` | Yes |
| `destination_cidr` | Destination CIDR block | `string` | Yes |
| `ip_protocol` | IP protocol (TCP, UDP, etc.) | `string` | Yes |
| `source_port` | Source port | `string` | Yes |
| `destination_port` | Destination port | `string` | Yes |
| `policy` | Policy action (accept, drop) | `string` | Yes |
| `direction` | Traffic direction (in, out) | `string` | Yes |
| `priority` | Rule priority | `number` | Yes |

## Outputs

| Name | Description |
|------|-------------|
| `cloud_firewall_instance_id` | The ID of the cloud firewall instance |
| `cloud_firewall_instance_status` | The status of the cloud firewall instance |
| `member_account_ids` | The list of member account IDs managed by the cloud firewall |
| `internet_acl_rule_count` | The number of internet ACL rules created |
| `internet_protection_enabled` | Whether internet boundary protection is enabled |
| `internet_protection_policy_id` | The ID of the internet boundary protection policy |

## Examples

### Basic Cloud Firewall Instance

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium"
  cloud_firewall_bandwidth       = 100
}
```

### With Member Accounts

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]
}
```

### With Directory Configuration

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_ids_dir = "./member_accounts"
  internet_acl_rules_dir = "./acl_rules"
}
```

### Internet Boundary Protection

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  enable_internet_protection        = true
  internet_protection_source         = "0.0.0.0/0"
  internet_protection_destination   = "10.0.0.0/8"
  internet_protection_application   = "HTTP"
  internet_protection_port          = "80"
}
```

### Internet ACL Rules

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  internet_acl_rules = [
    {
      description      = "Allow HTTPS from internet"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "443"
      destination_port = "443"
      policy           = "accept"
      direction        = "in"
      priority         = 1
    },
    {
      description      = "Block SSH from internet"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "22"
      destination_port = "22"
      policy           = "drop"
      direction        = "in"
      priority         = 2
    }
  ]
}
```

## Notes

- Cloud Firewall instance must be created before adding member accounts or configuring rules
- Member accounts are added to the firewall for centralized management
- Internet boundary protection provides protection for SLB resources
- Internet ACL rules allow fine-grained control over traffic
- Directory configuration files (JSON/YAML) are merged with inline configuration
- Directory configuration takes precedence when both are provided
- Rule uniqueness is determined by description, source_cidr, destination_cidr, destination_port, and direction
