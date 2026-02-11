<div align="right">

**English** | [中文](README-CN.md)

</div>

# CMS Alarm Contacts Module

This module manages CloudMonitor (CMS) alarm contacts and contact groups.

## Features

- Create CMS alarm contacts with multiple notification channels
- Create CMS alarm contact groups referencing contacts

## Inputs

| Name                  | Description                               | Type          | Default | Required |
|-----------------------|-------------------------------------------|---------------|---------|----------|
| `alarm_contacts`      | List of alarm contacts to create         | `list(object)`| `[]`    | No       |
| `alarm_contact_groups`| List of alarm contact groups to create   | `list(object)`| `[]`    | No       |

## Outputs

| Name                  | Description                                   |
|-----------------------|-----------------------------------------------|
| `alarm_contacts`      | Information about created alarm contacts      |
| `alarm_contact_groups`| Information about created alarm contact groups|
| `contact_id_map`      | Mapping of contact names to their IDs         |

## Usage

```hcl
module "cms_alarm" {
  source = "./modules/cms-alarm-contact"

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


