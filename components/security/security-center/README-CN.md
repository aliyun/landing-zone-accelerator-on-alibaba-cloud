<div align="right">

**中文** | [English](README.md)

</div>

# Security Center 组件

该组件用于开通阿里云安全中心（威胁检测）服务，提供安全监控和威胁检测能力。

## 功能特性

- 开通安全中心服务
- 创建安全中心服务关联角色
- 配置安全中心实例类型和付费方式
- 支持按量付费和包年包月付费方式

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| alicloud | ~> 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | ~> 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | 当前账号信息 |
| [alicloud_threat_detection_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/threat_detection_instance) | resource | 安全中心实例 |
| [alicloud_security_center_service_linked_role.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_center_service_linked_role) | resource | 安全中心服务关联角色 |

## 使用方法

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
  
  security_center_instance_type = "level2"
  security_center_payment_type = "PayAsYouGo"
  security_center_buy_number = 1
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `enable_security_center` | 是否开通安全中心 | `bool` | `true` | No | - |
| `security_center_instance_type` | 安全中心实例类型 | `string` | `"level2"` | No | - |
| `security_center_payment_type` | 安全中心实例付费方式 | `string` | `"PayAsYouGo"` | No | 必须是：`PayAsYouGo` 或 `Subscription` |
| `security_center_buy_number` | 购买的安全中心实例数量 | `number` | `1` | No | - |
| `modify_type` | 安全中心实例修改类型 | `string` | `null` | No | - |

## 输出参数

| Name | Description |
|------|-------------|
| `security_center_instance_id` | 安全中心实例 ID |
| `security_center_instance_status` | 安全中心实例状态 |
| `security_center_service_linked_role` | 安全中心服务关联角色 |
| `security_center_instance_type` | 安全中心实例类型 |

## 使用示例

### 基础安全中心配置

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
}
```

### 自定义配置的安全中心

```hcl
module "security_center" {
  source = "./components/security/security-center"

  enable_security_center = true
  
  security_center_instance_type = "level3"
  security_center_payment_type = "PayAsYouGo"
  security_center_buy_number = 1
}
```

## 注意事项

- 安全中心服务需要服务关联角色，组件会自动创建
- 实例类型决定可用的安全功能级别
- 付费方式可以是按量付费（PayAsYouGo）或包年包月（Subscription）
- 购买数量指定要购买的实例数量
- 服务关联角色必须在实例创建之前创建

