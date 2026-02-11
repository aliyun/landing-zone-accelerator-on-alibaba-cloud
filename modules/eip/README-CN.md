<div align="right">

**中文** | [English](README.md)

</div>

# EIP 模块

该模块用于创建和管理阿里云弹性公网 IP（EIP）地址。

## 功能特性

- 创建多个 EIP 实例
- 将 EIP 关联到实例（ECS、SLB、NAT 网关等）
- 支持按量付费和包年包月两种付费类型

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
| [alicloud_eip_address.eip_address](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address) | resource | EIP 地址 |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP 与实例的关联（可选） |

## 使用方法

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

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `eip_instances` | EIP 实例配置列表 | `list(object)` | - | 是 | 见下方 EIP 实例结构 |
| `eip_associate_instance_id` | 要关联 EIP 的实例 ID | `string` | `""` | 否 | ECS、SLB、NAT 网关、网卡或 HaVip ID |

### EIP 实例对象结构

`eip_instances` 中每个 EIP 实例的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `eip_address_name` | `string` | `null` | 否 | EIP 地址名称 | 1-128 个字符，以字母开头，只能包含字母、数字、点、下划线、连字符 |
| `payment_type` | `string` | `"PayAsYouGo"` | 否 | 付费类型 | 必须为：`Subscription` 或 `PayAsYouGo` |
| `period` | `number` | `null` | 否 | 包年包月时长 | 当 `payment_type = "Subscription"` 时必填。当 `pricing_cycle = "Month"` 时，范围为 1-9。当 `pricing_cycle = "Year"` 时，范围为 1-5 |
| `pricing_cycle` | `string` | `null` | 否 | 包年包月 EIP 的计费周期 | 必须为：`Month` 或 `Year`。当 `payment_type = "Subscription"` 时必填 |
| `auto_pay` | `bool` | `false` | 否 | 是否启用自动支付 | 当 `payment_type = "Subscription"` 时必填 |
| `bandwidth` | `number` | `5` | 否 | 最大带宽（Mbit/s） | PayAsYouGo + PayByBandwidth: 1-500。PayAsYouGo + PayByTraffic: 1-200。Subscription: 1-1000 |
| `deletion_protection` | `bool` | `false` | 否 | 是否启用删除保护 | - |
| `description` | `string` | `null` | 否 | EIP 描述 | 2-256 个字符，以字母开头，不能以 http:// 或 https:// 开头 |
| `internet_charge_type` | `string` | `"PayByBandwidth"` | 否 | 计费方式 | 必须为：`PayByBandwidth` 或 `PayByTraffic`。当 `payment_type = "Subscription"` 时，必须为 `PayByBandwidth` |
| `ip_address` | `string` | `null` | 否 | EIP 的 IP 地址 | 最多支持 50 个 EIP |
| `isp` | `string` | `"BGP"` | 否 | 线路类型 | 必须为：`BGP` 或 `BGP_PRO` |
| `mode` | `string` | `null` | 否 | 关联模式 | 必须为：`NAT`、`MULTI_BINDED` 或 `BINDED` |
| `netmode` | `string` | `"public"` | 否 | 网络类型 | 必须为：`public` |
| `public_ip_address_pool_id` | `string` | `null` | 否 | IP 地址池 ID | EIP 从 IP 地址池分配 |
| `resource_group_id` | `string` | `null` | 否 | 资源组 ID | - |
| `security_protection_type` | `string` | `null` | 否 | 安全防护级别 | 空字符串表示基础 DDoS 防护，`"antidos_enhanced"` 表示增强版 DDoS 防护 |
| `zone` | `string` | `null` | 否 | EIP 的可用区 | - |
| `tags` | `map(string)` | `{}` | 否 | EIP 标签 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `eip_instances` | EIP 实例列表，包含详细信息（id, ip_address, address_name, payment_type, status, association_id） |
| `eip_ids` | EIP ID 列表 |
| `eip_ips` | EIP IP 地址列表 |

## 使用示例

### 基础 EIP 创建

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

### 带关联的 EIP

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

### 包年包月 EIP

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

### 高级配置 EIP

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
      description               = "高级 EIP 配置"
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

## 注意事项

- EIP 实例可以关联到 ECS、SLB、NAT 网关、网卡或 HaVip 实例
- EIP 名称必须以字母开头，可以包含字母、数字、点、下划线和连字符
- 当 `payment_type = "Subscription"` 时，`period` 和 `pricing_cycle` 必填，且 `internet_charge_type` 必须为 `PayByBandwidth`
- 当 `payment_type = "PayAsYouGo"` 时，`internet_charge_type` 可以为 `PayByBandwidth` 或 `PayByTraffic`
- 带宽限制根据付费类型和计费方式而不同（见上方字段限制条件）
- `security_protection_type` 接受空字符串（基础 DDoS 防护）或 `"antidos_enhanced"`（增强版 DDoS 防护）
- 如需使用共享带宽包功能，请使用独立的 `common-bandwidth-package` 模块

