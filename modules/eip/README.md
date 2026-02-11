<div align="right">

**English** | [中文](README-CN.md)

</div>

# EIP Module

This module creates and manages Alibaba Cloud Elastic IP (EIP) addresses.

## Features

- Creates multiple EIP instances
- Associates EIPs with instances (ECS, SLB, NAT Gateway, etc.)
- Supports both PayAsYouGo and Subscription payment types

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
| [alicloud_eip_address.eip_address](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address) | resource | EIP addresses |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP associations with instances (optional) |

## Usage

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-1"
    },
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "eip-2"
    }
  ]
  
  eip_associate_instance_id = "nat-2ze0xxxxxxxxxxxxxxxx"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `eip_instances` | List of EIP instance configurations | `list(object)` | - | Yes | See EIP instance structure below |
| `eip_associate_instance_id` | The ID of the instance to associate EIPs with | `string` | `""` | No | ECS, SLB, NAT Gateway, NetworkInterface, or HaVip ID |

### EIP Instance Object Structure

Each EIP instance in `eip_instances` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `eip_address_name` | `string` | `null` | No | EIP address name | 1-128 characters, start with letter, only letters, digits, periods, underscores, hyphens |
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
| `zone` | `string` | `null` | No | Zone of the EIP | - |
| `tags` | `map(string)` | `{}` | No | Tags for the EIP | - |

## Outputs

| Name | Description |
|------|-------------|
| `eip_instances` | List of EIP instances with details (id, ip_address, address_name, payment_type, status, association_id) |
| `eip_ids` | List of EIP IDs |
| `eip_ips` | List of EIP IP addresses |

## Examples

### Basic EIP Creation

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "production-eip"
    }
  ]
}
```

### EIP with Association

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "nat-eip"
    }
  ]
  
  eip_associate_instance_id = "ngw-uf6hg6eaaqz70xxxxxx"
}
```

### Subscription EIP

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      payment_type     = "Subscription"
      period           = 12
      pricing_cycle    = "Year"
      auto_pay         = true
      eip_address_name = "subscription-eip"
    }
  ]
}
```

### EIP with Advanced Configuration

```hcl
module "eip" {
  source = "./modules/eip"

  eip_instances = [
    {
      eip_address_name          = "advanced-eip"
      payment_type              = "PayAsYouGo"
      bandwidth                 = 100
      internet_charge_type      = "PayByTraffic"
      isp                       = "BGP_PRO"
      mode                      = "MULTI_BINDED"
      description               = "Advanced EIP configuration"
      deletion_protection       = false
      security_protection_type  = "antidos_enhanced"
      tags = {
        Environment = "production"
        Project     = "web-app"
      }
    }
  ]
}
```

## Notes

- EIP instances can be associated with ECS, SLB, NAT Gateway, NetworkInterface, or HaVip instances
- EIP names must start with a letter and can contain letters, digits, periods, underscores, and hyphens
- When `payment_type = "Subscription"`, `period` and `pricing_cycle` are required, and `internet_charge_type` must be `PayByBandwidth`
- When `payment_type = "PayAsYouGo"`, `internet_charge_type` can be `PayByBandwidth` or `PayByTraffic`
- Bandwidth limits vary by payment type and internet charge type (see field constraints above)
- `security_protection_type` accepts empty string (basic DDoS protection) or `"antidos_enhanced"` (enhanced DDoS protection)
- For common bandwidth package functionality, use the separate `common-bandwidth-package` module
