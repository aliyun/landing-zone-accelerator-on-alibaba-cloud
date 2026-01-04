<div align="right">

**English** | [中文](README-CN.md)

</div>

# Security Center Component

This component enables Alibaba Cloud Security Center (Threat Detection) service for security monitoring and threat detection.

## Features

- Enables Security Center service
- Creates service-linked role for Security Center
- Configures Security Center instance type and payment method
- Supports PayAsYouGo and Subscription payment types

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.262.1 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | Current account information |
| [alicloud_threat_detection_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/threat_detection_instance) | resource | Security Center instance |
| [alicloud_security_center_service_linked_role.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_center_service_linked_role) | resource | Security Center service-linked role |

## Usage

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
  
  security_center_instance_type = "level2"
  security_center_payment_type = "PayAsYouGo"
  security_center_buy_number = 1
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_security_center` | Whether to enable Security Center | `bool` | `true` | No | - |
| `security_center_instance_type` | The type of the Security Center instance | `string` | `"level2"` | No | - |
| `security_center_payment_type` | The payment type for Security Center instance | `string` | `"PayAsYouGo"` | No | Must be: `PayAsYouGo` or `Subscription` |
| `security_center_buy_number` | The number of Security Center instances to buy | `number` | `1` | No | - |
| `modify_type` | The modification type for Security Center instance | `string` | `null` | No | - |

## Outputs

| Name | Description |
|------|-------------|
| `security_center_instance_id` | The ID of the Security Center instance |
| `security_center_instance_status` | The status of the Security Center instance |
| `security_center_service_linked_role` | The Security Center service-linked role |
| `security_center_instance_type` | The type of the Security Center instance |

## Examples

### Basic Security Center Setup

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
}
```

### Security Center with Custom Configuration

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
  
  security_center_instance_type = "level3"
  security_center_payment_type = "PayAsYouGo"
  security_center_buy_number = 1
}
```

## Notes

- Security Center service requires a service-linked role which is automatically created
- Instance type determines the level of security features available
- Payment type can be PayAsYouGo (pay-as-you-go) or Subscription (prepaid)
- Buy number specifies how many instances to purchase
- Service-linked role must be created before the instance

