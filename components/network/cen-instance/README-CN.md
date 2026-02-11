<div align="right">

**中文** | [English](README.md)

</div>

# CEN 实例组件

该组件用于创建和管理阿里云 CEN（云企业网）实例。

## 功能特性

- 创建 CEN 实例
- 自动开通转发路由器服务
- 支持为 CEN 实例添加标签
- 创建并关联多个 CEN 带宽包

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

| Name | Source | Description |
|------|--------|-------------|
| cen_bandwidth_package | ../../../modules/cen-bandwidth-package | CEN 带宽包 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_transit_router_service.enable](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_service) | data source | 转发路由器服务开通 |
| [alicloud_cen_instance.cen](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance) | resource | CEN 实例 |

## 使用方法

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "enterprise-cen"
  description       = "企业 CEN 实例"
  
  tags = {
    Environment = "production"
  }

  bandwidth_packages = [
    {
      bandwidth                  = 10
      cen_bandwidth_package_name = "cross-region-bwp"
      geographic_region_a_id     = "China"
      geographic_region_b_id     = "China"
      payment_type               = "PrePaid"
      pricing_cycle              = "Month"
      period                     = 1
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_name` | CEN 实例名称 | `string` | `null` | 否 | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `description` | CEN 实例描述 | `string` | `null` | 否 | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `tags` | CEN 实例的标签 | `map(string)` | `null` | 否 | - |
| `protection_level` | CIDR 块重叠级别 | `string` | `null` | 否 | 有效值：REDUCED |
| `resource_group_id` | 资源组 ID | `string` | `null` | 否 | - |
| `bandwidth_packages` | CEN 带宽包配置列表 | `list(object)` | `[]` | 否 | 参见带宽包对象结构 |

### 带宽包对象结构

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `bandwidth` | `number` | - | 是 | 带宽（Mbps，2-10000） |
| `geographic_region_a_id` | `string` | - | 是 | 地理区域 A（China、North-America、Asia-Pacific、Europe、Australia） |
| `geographic_region_b_id` | `string` | - | 是 | 地理区域 B（China、North-America、Asia-Pacific、Europe、Australia） |
| `cen_bandwidth_package_name` | `string` | `null` | 否 | 带宽包名称 |
| `description` | `string` | `null` | 否 | 带宽包描述 |
| `payment_type` | `string` | `"PrePaid"` | 否 | 付费类型（PrePaid、PostPaid） |
| `pricing_cycle` | `string` | `"Month"` | 否 | 计费周期（Month、Year） |
| `period` | `number` | `1` | 否 | 订阅时长 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `cen_instance_id` | 创建的 CEN 实例 ID |
| `bandwidth_package_ids` | 关联到此 CEN 实例的带宽包 ID 列表 |
| `bandwidth_packages` | 关联到此 CEN 实例的带宽包列表（每个元素包含输入参数和 bandwidth_package_id） |
| `bandwidth_packages_map` | 关联到此 CEN 实例的带宽包映射（key 格式：\"RegionA:RegionB\"，例如 \"China:China\"） |

## 使用示例

### 基础 CEN 实例

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "my-cen"
}
```

### CEN 实例配置带宽包

```hcl
module "cen_instance" {
  source = "./components/network/cen-instance"

  cen_instance_name = "enterprise-cen"
  description       = "企业 CEN"
  
  tags = {
    Environment = "production"
    Project     = "landing-zone"
  }

  bandwidth_packages = [
    {
      bandwidth                  = 10
      cen_bandwidth_package_name = "china-cross-region"
      geographic_region_a_id     = "China"
      geographic_region_b_id     = "China"
      payment_type               = "PrePaid"
      pricing_cycle              = "Month"
      period                     = 1
    }
  ]
}
```

## 注意事项

- 创建 CEN 实例前会自动开通转发路由器服务
- 名称和描述不能以 `http://` 或 `https://` 开头
- 可以为 CEN 实例添加标签用于资源管理
- 带宽包用于跨地域连接
- `bandwidth_packages_map` 中的 key 格式使用冒号（`:`）连接地理区域（例如 `"China:China"`、`"China:Asia-Pacific"`）
- key 中的地理区域已排序，确保无论 A/B 顺序如何都保持一致

