<div align="right">

**中文** | [English](README.md)

</div>

# CMS 模块

该模块用于启用阿里云云监控服务，并创建告警联系人和联系组，用于监控和告警。

## 功能特性

- 启用云监控基础版（始终启用）
- 可选启用云监控企业版
- 创建告警联系人，支持多种通知渠道
- 创建告警联系组
- 配置云监控服务关联角色

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cloud_monitor_service_basic_public.basic](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_monitor_service_basic_public) | resource | 云监控基础版 |
| [alicloud_resource_manager_service_linked_role.slr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | 云监控服务关联角色 |
| [alicloud_cloud_monitor_service_enterprise_public.enterprise](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_monitor_service_enterprise_public) | resource | 云监控企业版（可选） |
| [alicloud_cms_alarm_contact.contacts](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cms_alarm_contact) | resource | 告警联系人 |
| [alicloud_cms_alarm_contact_group.groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cms_alarm_contact_group) | resource | 告警联系组 |

## 使用方法

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

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `enable_enterprise` | 是否启用云监控企业版 | `bool` | `false` | 否 | - |
| `alarm_contacts` | 要创建的告警联系人列表 | `list(object)` | `[]` | 否 | 见下方告警联系人结构 |
| `alarm_contact_groups` | 要创建的告警联系组列表 | `list(object)` | `[]` | 否 | 见下方联系组结构 |

### 告警联系人对象结构

`alarm_contacts` 中每个告警联系人的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `name` | `string` | - | 是 | 联系人名称 | 2-40 个字符，以中文或英文开头，只能包含中文、英文、数字、点、下划线、连字符 |
| `description` | `string` | - | 是 | 联系人描述 | 不能为空 |
| `channels_aliim` | `string` | `null` | 否 | 阿里旺旺渠道 | - |
| `channels_ding_web_hook` | `string` | `null` | 否 | 钉钉 webhook | - |
| `channels_mail` | `string` | `null` | 否 | 邮箱地址 | 有效邮箱格式 |
| `channels_sms` | `string` | `null` | 否 | 短信手机号 | 有效中国手机号（11 位数字或 86-11 位数字） |
| `lang` | `string` | `"zh-cn"` | 否 | 语言 | 必须为：`en` 或 `zh-cn` |

### 告警联系组对象结构

`alarm_contact_groups` 中每个联系组的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `name` | `string` | - | 是 | 组名 | 2-40 个字符，以中文或英文开头，只能包含中文、英文、数字、点、下划线、连字符 |
| `contacts` | `list(string)` | `[]` | 否 | 联系人名称列表 | 联系人名称必须存在于 `alarm_contacts` 中 |
| `description` | `string` | `null` | 否 | 组描述 | - |
| `enable_subscribed` | `bool` | `true` | 否 | 是否启用订阅 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `basic_cloud_monitor_service_id` | 基础版云监控服务 ID |
| `enterprise_cloud_monitor_service_id` | 企业版云监控服务 ID（如果未启用则为 null） |
| `alarm_contacts` | 创建的告警联系人信息 |
| `alarm_contact_groups` | 创建的告警联系组信息 |
| `contact_id_map` | 联系人名称到 ID 的映射，便于引用 |

## 使用示例

### 基础云监控设置

```hcl
module "cms" {
  source = "./modules/cms"
}
```

### 企业版带联系人

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

### 多种通知渠道

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

## 注意事项

- 云监控基础版始终启用
- 企业版提供高级功能，需要额外配置
- 联系人名称在账户内必须唯一
- 联系组名称在账户内必须唯一
- `alarm_contact_groups[].contacts` 中引用的联系人名称必须存在于 `alarm_contacts` 中
- 邮箱地址必须为有效格式
- 语言可以是 `en`（英文）或 `zh-cn`（简体中文）

