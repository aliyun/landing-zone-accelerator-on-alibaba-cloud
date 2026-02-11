<div align="right">

**中文** | [English](README.md)

</div>

# CEN 带宽包模块

该模块用于创建和管理阿里云 CEN（云企业网）带宽包，并将其关联到 CEN 实例。

## 功能特性

- 创建新的 CEN 带宽包或使用已有的带宽包
- 将带宽包关联到 CEN 实例

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_bandwidth_package.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_bandwidth_package) | resource | CEN 带宽包（按条件创建） |
| [alicloud_cen_bandwidth_package_attachment.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_bandwidth_package_attachment) | resource | CEN 带宽包关联 |

## 使用方法

### 创建新的带宽包

```hcl
module "cen_bandwidth_package" {
  source = "./modules/cen-bandwidth-package"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  bandwidth                  = 10
  cen_bandwidth_package_name = "cross-region-bwp"
  description                = "跨地域带宽包"
  geographic_region_a_id     = "China"
  geographic_region_b_id     = "China"
  payment_type               = "PrePaid"
  pricing_cycle              = "Month"
  period                     = 1
}
```

### 使用已有的带宽包

```hcl
module "cen_bandwidth_package" {
  source = "./modules/cen-bandwidth-package"

  cen_instance_id                = "cen-xxxxxxxxxxxxx"
  use_existing_bandwidth_package = true
  existing_bandwidth_package_id  = "cenbwp-xxxxxxxxxxxxx"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | 要关联带宽包的 CEN 实例 ID | `string` | - | 是 | - |
| `use_existing_bandwidth_package` | 是否使用已有的带宽包而不创建新的 | `bool` | `false` | 否 | - |
| `existing_bandwidth_package_id` | 已有的 CEN 带宽包 ID | `string` | `null` | 否 | 当 use_existing_bandwidth_package 为 true 时必填 |
| `bandwidth` | 带宽包的带宽（Mbps） | `number` | `null` | 否 | 2-10000。创建新带宽包时必填 |
| `cen_bandwidth_package_name` | 带宽包名称 | `string` | `null` | 否 | 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `description` | 带宽包描述 | `string` | `null` | 否 | 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `geographic_region_a_id` | 网络实例所属的区域 A | `string` | `null` | 否 | 必须为：China、North-America、Asia-Pacific、Europe、Australia。创建新带宽包时必填 |
| `geographic_region_b_id` | 网络实例所属的区域 B | `string` | `null` | 否 | 必须为：China、North-America、Asia-Pacific、Europe、Australia。创建新带宽包时必填 |
| `payment_type` | 带宽包的计费方式 | `string` | `"PrePaid"` | 否 | 必须为：PrePaid、PostPaid |
| `pricing_cycle` | 带宽包的计费周期 | `string` | `"Month"` | 否 | 必须为：Month、Year。仅当 payment_type 为 PrePaid 时有效 |
| `period` | 带宽包的包年包月时长 | `number` | `null` | 否 | 当 pricing_cycle 为 Month 时：1、2、3、6。当 pricing_cycle 为 Year 时：1、2、3。当 payment_type 为 PrePaid 时必填 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `bandwidth_package_id` | CEN 带宽包 ID |
| `bandwidth_package_created` | 是否创建了新的带宽包 |
| `cen_instance_id` | 带宽包关联的 CEN 实例 ID |

## 注意事项

- 当 `use_existing_bandwidth_package` 为 true 时，模块只会将已有的带宽包关联到 CEN 实例
- 创建新带宽包时，`bandwidth`、`geographic_region_a_id` 和 `geographic_region_b_id` 是必填项
- 对于中国境内的跨地域连接，将 `geographic_region_a_id` 和 `geographic_region_b_id` 都设置为 "China"
- 带宽包必须关联到 CEN 实例后才能用于跨地域带宽分配
- 如果 `payment_type` 设置为 PrePaid，在订阅到期前无法删除带宽包
