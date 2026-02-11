<div align="right">

**English** | [中文](README-CN.md)

</div>

# Common Bandwidth Package Module

This module creates and manages Alibaba Cloud Common Bandwidth Package (共享带宽包) for sharing bandwidth across multiple EIP instances.

## Features

- Creates a common bandwidth package
- Attaches multiple EIP instances to the bandwidth package
- Supports configurable bandwidth limits per EIP attachment
- Supports multiple billing methods (PayByBandwidth, PayBy95, PayByDominantTraffic)
- Supports deletion protection and force deletion

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_common_bandwidth_package.bandwidth_package](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package) | resource | Common bandwidth package |
| [alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package_attachment) | resource | EIP attachments to bandwidth package |

## Usage

### Basic Common Bandwidth Package

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "100"
  eip_attachments = [
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    }
  ]
}
```

### Common Bandwidth Package with EIP Bandwidth Limits

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "200"
  internet_charge_type   = "PayByBandwidth"
  eip_attachments = [
    {
      instance_id              = "eip-2ze0xxxxxxxxxxxxxxxx"
      bandwidth_package_bandwidth = "50"
    },
    {
      instance_id              = "eip-2ze0xxxxxxxxxxxxxxxx"
      bandwidth_package_bandwidth = "100"
    }
  ]
}
```

### Common Bandwidth Package with PayBy95 Billing

```hcl
module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name       = "shared-bandwidth-payby95"
  bandwidth                    = "500"
  internet_charge_type         = "PayBy95"
  ratio                        = 20
  security_protection_types    = ["AntiDDoS_Enhanced"]
  eip_attachments = [
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    },
    {
      instance_id = "eip-2ze0xxxxxxxxxxxxxxxx"
    }
  ]
}
```

### Common Bandwidth Package with EIP Module

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
}

module "common_bandwidth_package" {
  source = "./modules/common-bandwidth-package"

  bandwidth_package_name = "shared-bandwidth"
  bandwidth              = "200"
  eip_attachments = [
    for eip in module.eip.eip_instances : {
      instance_id              = eip.id
      bandwidth_package_bandwidth = eip.id == module.eip.eip_instances[0].id ? "50" : "100"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `bandwidth` | The bandwidth of the common bandwidth package (Mbps) | `string` | `"5"` | No | Integer between 1 and 1000 |
| `internet_charge_type` | The billing method of the common bandwidth package | `string` | `"PayByBandwidth"` | No | Must be: `PayByBandwidth`, `PayBy95`, `PayByDominantTraffic` |
| `bandwidth_package_name` | The name of the common bandwidth package | `string` | `null` | No | 2-256 characters, start with letter, cannot start with http:// or https:// |
| `ratio` | The ratio for PayBy95 billing method | `number` | `20` | No | Must be 20 |
| `deletion_protection` | Whether to enable deletion protection | `bool` | `false` | No | - |
| `description` | The description of the Internet Shared Bandwidth instance | `string` | `null` | No | 0-256 characters, cannot start with http:// or https:// |
| `force` | Whether to forcefully delete the Internet Shared Bandwidth instance | `bool` | `false` | No | - |
| `isp` | The line type of the common bandwidth package | `string` | `"BGP"` | No | Must be: `BGP` or `BGP_PRO` |
| `resource_group_id` | The ID of the resource group | `string` | `null` | No | - |
| `security_protection_types` | The edition of Anti-DDoS | `list(string)` | `[]` | No | Empty list for Basic, `AntiDDoS_Enhanced` for Pro. Valid when internet_charge_type is PayBy95. Maximum 10 elements |
| `tags` | The tags of the common bandwidth package resource | `map(string)` | `{}` | No | - |
| `zone` | The zone of the Internet Shared Bandwidth instance | `string` | `null` | No | Required if creating for a cloud box |
| `eip_attachments` | List of EIP attachments to the common bandwidth package | `list(object)` | `[]` | No | Each object contains instance_id and optional bandwidth_package_bandwidth. bandwidth_package_bandwidth can be positive integer string or `"Cancelled"` (from version 1.261.0) |

## Outputs

| Name | Description |
|------|-------------|
| `bandwidth_package_id` | ID of the common bandwidth package |
| `bandwidth_package_name` | Name of the common bandwidth package |
| `attachment_ids` | List of attachment IDs for EIPs attached to the bandwidth package |
| `attachment_details` | List of attachment details including attachment ID, EIP instance ID, and bandwidth_package_bandwidth |

## Notes

- Common bandwidth package allows multiple EIPs to share bandwidth, reducing costs
- `PayBy95` billing method requires `ratio = 20`
- `security_protection_types` is only valid when `internet_charge_type` is `PayBy95`, and can have at most 10 elements
- `zone` is required when creating an Internet Shared Bandwidth instance for a cloud box
- `force` when set to `true`, will disassociate all EIPs and delete the bandwidth package forcefully
- The `bandwidth_package_bandwidth` field in `eip_attachments` sets the maximum bandwidth for each EIP when attached to the bandwidth package. This value cannot be larger than the maximum bandwidth of the Internet Shared Bandwidth instance. From version 1.261.0, setting it to `"Cancelled"` will cancel the maximum bandwidth configuration for the EIP
- If `bandwidth_package_bandwidth` is not provided in the attachment object, the EIP attachment will not have bandwidth limits set

