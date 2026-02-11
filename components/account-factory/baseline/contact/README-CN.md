<div align="right">

**中文** | [English](README.md)

</div>

# Contact 模块

该模块用于创建和管理阿里云消息服务中心（MSC）联系人，并配置订阅通知。

## 功能特性

- 创建 MSC 联系人，包含姓名、邮箱、手机和职位
- 为所有订阅项配置订阅通知
- 支持覆盖或追加模式的通知接收人设置

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_msc_sub_subscriptions.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/msc_sub_subscriptions) | data source | MSC 订阅项查询 |
| [alicloud_msc_sub_contact.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/msc_sub_contact) | resource | MSC 联系人 |
| [alicloud_msc_sub_subscription.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/msc_sub_subscription) | resource | 所有订阅项的订阅配置 |

## 使用方法

```hcl
module "contact" {
  source = "./components/account-factory/baseline/contact"

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

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `contacts` | 要创建的联系人列表 | `list(object)` | `[]` | 否 | 见下方联系人对象结构 |
| `notification_recipient_mode` | 设置通知接收人的模式 | `string` | `"append"` | 否 | 必须为 `"overwrite"` 或 `"append"` |

### 联系人对象结构

`contacts` 中每个联系人对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `name` | `string` | - | 是 | 联系人姓名 | 2-12 个中文字符或英文字符 |
| `email` | `string` | - | 是 | 邮箱地址 | 有效邮箱格式 |
| `mobile` | `string` | `"0000"` | 否 | 手机号码 | 至少 4 位数字 |
| `position` | `string` | - | 是 | 联系人职位 | 必须为：`CEO`、`Finance Director`、`Maintenance Director`、`Other`、`Project Director`、`Technical Director` 之一 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `contacts` | 联系人列表及其 ID |

## 使用示例

### 创建多个联系人

```hcl
module "contact" {
  source = "./components/account-factory/baseline/contact"

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

### 覆盖模式

```hcl
module "contact" {
  source = "./components/account-factory/baseline/contact"

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

## 注意事项

- 联系人姓名必须为 2-12 个中文字符或英文字符
- 邮箱地址必须为有效格式
- 手机号码必须至少 4 位数字（如果未提供，默认为 "0000"）
- 职位必须为预定义值之一
- 当 `notification_recipient_mode = "append"` 时，新联系人会添加到现有通知接收人
- 当 `notification_recipient_mode = "overwrite"` 时，现有通知接收人会被新联系人替换
- 所有订阅项会自动配置为使用这些联系人

