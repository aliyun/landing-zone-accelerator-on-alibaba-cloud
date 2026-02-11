<div align="right">

**中文** | [English](README.md)

</div>

# CMS 告警联系人模块

该模块用于管理云监控（CloudMonitor，CMS）的告警联系人和告警联系组。

## 功能特性

- 创建云监控告警联系人，支持多种通知渠道
- 创建告警联系组，并引用已创建的联系人

## 输入参数

| 参数名                 | 说明                     | 类型           | 默认值 | 必填 |
|------------------------|--------------------------|----------------|--------|------|
| `alarm_contacts`       | 要创建的告警联系人列表   | `list(object)` | `[]`   | 否   |
| `alarm_contact_groups` | 要创建的告警联系组列表   | `list(object)` | `[]`   | 否   |

## 输出参数

| 名称                   | 说明                         |
|------------------------|------------------------------|
| `alarm_contacts`       | 已创建告警联系人的详细信息   |
| `alarm_contact_groups` | 已创建告警联系组的详细信息   |
| `contact_id_map`       | 联系人名称到联系人 ID 的映射 |

## 使用示例

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


