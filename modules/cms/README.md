<div align="right">

**English** | [中文](README-CN.md)

</div>

# CMS Module

This module enables Alibaba Cloud CloudMonitor Service and creates alarm contacts and contact groups for monitoring and alerting.

## Features

- Enables CloudMonitor Basic edition (always enabled)
- Optionally enables CloudMonitor Enterprise edition
- Creates alarm contacts with multiple notification channels
- Creates alarm contact groups
- Configures service-linked role for CloudMonitor

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
| [alicloud_cloud_monitor_service_basic_public.basic](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_monitor_service_basic_public) | resource | CloudMonitor Basic edition |
| [alicloud_resource_manager_service_linked_role.slr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | Service-linked role for CloudMonitor |
| [alicloud_cloud_monitor_service_enterprise_public.enterprise](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_monitor_service_enterprise_public) | resource | CloudMonitor Enterprise edition (optional) |
| [alicloud_cms_alarm_contact.contacts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cms_alarm_contact) | resource | Alarm contacts |
| [alicloud_cms_alarm_contact_group.groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cms_alarm_contact_group) | resource | Alarm contact groups |

## Usage

```hcl
module "cms" {
  source = "./modules/cms"

  enable_enterprise = true
  
  alarm_contacts = [
    {
      name        = "admin"
      description = "Primary administrator"
      channels_mail = "admin@example.com"
      channels_sms  = "13800138000"
      lang        = "zh-cn"
    }
  ]
  
  alarm_contact_groups = [
    {
      name              = "critical-alerts"
      contacts          = ["admin"]
      description       = "Critical alerts group"
      enable_subscribed = true
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_enterprise` | Whether to enable CloudMonitor Enterprise edition | `bool` | `false` | No | - |
| `alarm_contacts` | List of alarm contacts to create | `list(object)` | `[]` | No | See alarm contact structure below |
| `alarm_contact_groups` | List of alarm contact groups to create | `list(object)` | `[]` | No | See contact group structure below |

### Alarm Contact Object Structure

Each alarm contact in `alarm_contacts` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Contact name | 2-40 characters, start with Chinese or English, only Chinese, English, numbers, dots, underscores, hyphens |
| `description` | `string` | - | Yes | Contact description | Cannot be empty |
| `channels_aliim` | `string` | `null` | No | AliIM channel | - |
| `channels_ding_web_hook` | `string` | `null` | No | DingTalk webhook | - |
| `channels_mail` | `string` | `null` | No | Email address | Valid email format |
| `channels_sms` | `string` | `null` | No | SMS phone number | Valid Chinese phone number (11 digits or 86-11 digits) |
| `lang` | `string` | `"zh-cn"` | No | Language | Must be: `en` or `zh-cn` |

### Alarm Contact Group Object Structure

Each contact group in `alarm_contact_groups` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Group name | 2-40 characters, start with Chinese or English, only Chinese, English, numbers, dots, underscores, hyphens |
| `contacts` | `list(string)` | `[]` | No | List of contact names | Contact names must exist in `alarm_contacts` |
| `description` | `string` | `null` | No | Group description | - |
| `enable_subscribed` | `bool` | `true` | No | Whether to enable subscription | - |

## Outputs

| Name | Description |
|------|-------------|
| `basic_cloud_monitor_service_id` | The ID of the Basic CloudMonitor service |
| `enterprise_cloud_monitor_service_id` | The ID of the Enterprise CloudMonitor service (null if not enabled) |
| `alarm_contacts` | Information about created alarm contacts |
| `alarm_contact_groups` | Information about created alarm contact groups |
| `contact_id_map` | Mapping of contact names to their IDs for easy reference |

## Examples

### Basic CloudMonitor Setup

```hcl
module "cms" {
  source = "./modules/cms"
}
```

### Enterprise Edition with Contacts

```hcl
module "cms" {
  source = "./modules/cms"

  enable_enterprise = true
  
  alarm_contacts = [
    {
      name        = "ops-team"
      description = "Operations team"
      channels_mail = "ops@example.com"
      channels_sms  = "13900139000"
      lang        = "en"
    },
    {
      name        = "dev-team"
      description = "Development team"
      channels_mail = "dev@example.com"
      lang        = "en"
    }
  ]
  
  alarm_contact_groups = [
    {
      name              = "all-teams"
      contacts          = ["ops-team", "dev-team"]
      description       = "All teams notification group"
      enable_subscribed = true
    }
  ]
}
```

### Multiple Notification Channels

```hcl
module "cms" {
  source = "./modules/cms"

  enable_enterprise = true
  
  alarm_contacts = [
    {
      name                 = "admin"
      description          = "Administrator"
      channels_mail        = "admin@example.com"
      channels_sms         = "13800138000"
      channels_ding_web_hook = "https://oapi.dingtalk.com/robot/send?access_token=xxx"
      lang                 = "zh-cn"
    }
  ]
}
```

## Notes

- CloudMonitor Basic edition is always enabled
- Enterprise edition provides advanced features and requires additional configuration
- Contact names must be unique within the account
- Contact group names must be unique within the account
- Contact names referenced in `alarm_contact_groups[].contacts` must exist in `alarm_contacts`
- Email addresses must be in valid format
- Language can be `en` (English) or `zh-cn` (Simplified Chinese)
