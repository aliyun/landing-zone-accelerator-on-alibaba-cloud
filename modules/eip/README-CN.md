<div align="right">

**中文** | [English](README.md)

</div>

# EIP 模块

该模块用于创建和管理阿里云弹性公网 IP（EIP）地址，支持可选的共享带宽包。

## 功能特性

- 创建多个 EIP 实例
- 将 EIP 关联到实例（ECS、SLB、NAT 网关等）
- 可选的共享带宽包，用于共享带宽
- 支持按量付费和包年包月两种付费类型

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
| [alicloud_eip_address.eip_address](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_address) | resource | EIP 地址 |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP 与实例的关联（可选） |
| [alicloud_common_bandwidth_package.bandwidth_package](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package) | resource | 共享带宽包（可选） |
| [alicloud_common_bandwidth_package_attachment.bandwidth_package_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/common_bandwidth_package_attachment) | resource | EIP 到带宽包的关联（可选） |

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
  
  eip_associate_instance_id = "nat-1234567890abcdef0"
  
  enable_common_bandwidth_package = true
  common_bandwidth_package_name   = "shared-bandwidth"
  common_bandwidth_package_bandwidth = "100"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `eip_instances` | EIP 实例配置列表 | `list(object)` | - | 是 | 见下方 EIP 实例结构 |
| `eip_associate_instance_id` | 要关联 EIP 的实例 ID | `string` | `""` | 否 | ECS、SLB、NAT 网关、网卡或 HaVip ID |
| `enable_common_bandwidth_package` | 是否启用共享带宽包 | `bool` | `false` | 否 | - |
| `common_bandwidth_package_name` | 共享带宽包名称 | `string` | `null` | 否 | 2-256 个字符，以字母开头，不能以 http:// 或 https:// 开头 |
| `common_bandwidth_package_bandwidth` | 共享带宽包带宽（Mbps） | `string` | `"5"` | 否 | 1-1000 之间的整数 |
| `common_bandwidth_package_internet_charge_type` | 共享带宽包计费方式 | `string` | `"PayByBandwidth"` | 否 | 必须为：`PayByBandwidth`、`PayBy95`、`PayByDominantTraffic` |
| `common_bandwidth_package_ratio` | PayBy95 计费方式的比率 | `number` | `20` | 否 | 必须为 20 |

### EIP 实例对象结构

`eip_instances` 中每个 EIP 实例的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `payment_type` | `string` | `"PayAsYouGo"` | 否 | 付费类型 | 必须为：`Subscription` 或 `PayAsYouGo` |
| `period` | `number` | `null` | 否 | 包年包月时长（月） | 当 `payment_type = "Subscription"` 时必填 |
| `eip_address_name` | `string` | `null` | 否 | EIP 地址名称 | 1-128 个字符，以字母开头，只能包含字母、数字、点、下划线、连字符 |
| `tags` | `object` | `{}` | 否 | EIP 标签 | - |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `eip_instances` | EIP 实例列表，包含详细信息（id, ip_address, address_name, payment_type, status, association_id, bandwidth_package_attachment_id） |
| `common_bandwidth_package_id` | 共享带宽包 ID（如果启用） |

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
  
  eip_associate_instance_id = "ngw-1234567890abcdef0"
}
```

### 带共享带宽包的 EIP

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
  
  enable_common_bandwidth_package = true
  common_bandwidth_package_name   = "shared-bandwidth"
  common_bandwidth_package_bandwidth = "200"
  common_bandwidth_package_internet_charge_type = "PayByBandwidth"
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
      eip_address_name = "subscription-eip"
    }
  ]
}
```

## 注意事项

- EIP 实例可以关联到 ECS、SLB、NAT 网关、网卡或 HaVip 实例
- 共享带宽包允许多个 EIP 共享带宽，降低成本
- 当 `enable_common_bandwidth_package = true` 时，所有 EIP 自动关联到带宽包
- `PayBy95` 计费方式需要 `common_bandwidth_package_ratio = 20`
- EIP 名称必须以字母开头，可以包含字母、数字、点、下划线和连字符

