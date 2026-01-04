<div align="right">

**English** | [中文](README-CN.md)

</div>

# Contact Module

This module creates and manages Alibaba Cloud Message Service Center (MSC) contacts and configures subscription notifications.

## Features

- Creates MSC contacts with name, email, mobile, and position
- Configures subscription notifications for all subscription items
- Supports overwrite or append mode for notification recipients

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
| [alicloud_msc_sub_subscriptions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/msc_sub_subscriptions) | data source | MSC subscription items lookup |
| [alicloud_msc_sub_contact.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/msc_sub_contact) | resource | MSC contacts |
| [alicloud_msc_sub_subscription.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/msc_sub_subscription) | resource | Subscription configurations for all subscription items |

## Usage

```hcl
module "contact" {
  source = "./modules/contact"

  contacts = [
    {
      name     = "JohnDoe"
      email    = "john.doe@example.com"
      mobile   = "13800138000"
      position = "Technical Director"
    }
  ]
  
  notification_recipient_mode = "append"
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `contacts` | List of contacts to create | `list(object)` | `[]` | No | See contact object structure below |
| `notification_recipient_mode` | Mode for setting notification recipients | `string` | `"append"` | No | Must be `"overwrite"` or `"append"` |

### Contact Object Structure

Each contact in `contacts` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `name` | `string` | - | Yes | Contact name | 2-12 Chinese or English characters |
| `email` | `string` | - | Yes | Email address | Valid email format |
| `mobile` | `string` | `"0000"` | No | Mobile phone number | At least 4 digits |
| `position` | `string` | - | Yes | Contact position | Must be one of: `CEO`, `Finance Director`, `Maintenance Director`, `Other`, `Project Director`, `Technical Director` |

## Outputs

| Name | Description |
|------|-------------|
| `contacts` | List of contacts with their IDs |

## Examples

### Create Multiple Contacts

```hcl
module "contact" {
  source = "./modules/contact"

  contacts = [
    {
      name     = "ZhangSan"
      email    = "zhangsan@example.com"
      mobile   = "13800138000"
      position = "Technical Director"
    },
    {
      name     = "LiSi"
      email    = "lisi@example.com"
      mobile   = "13900139000"
      position = "Maintenance Director"
    }
  ]
}
```

### Overwrite Mode

```hcl
module "contact" {
  source = "./modules/contact"

  contacts = [
    {
      name     = "Admin"
      email    = "admin@example.com"
      mobile   = "13800138000"
      position = "CEO"
    }
  ]
  
  notification_recipient_mode = "overwrite"
}
```

## Notes

- Contact names must be 2-12 Chinese or English characters
- Email addresses must be in valid format
- Mobile numbers must be at least 4 digits (defaults to "0000" if not provided)
- Position must be one of the predefined values
- When `notification_recipient_mode = "append"`, new contacts are added to existing notification recipients
- When `notification_recipient_mode = "overwrite"`, existing notification recipients are replaced with the new contacts
- All subscription items are automatically configured with the contacts
