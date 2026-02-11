<div align="right">

**中文** | [English](README.md)

</div>

# CEN 转发路由器组件

该组件用于创建和管理阿里云 CEN 转发路由器，并获取系统路由表 ID。

## 功能特性

- 在 CEN 实例中创建转发路由器
- 获取转发路由器系统路由表 ID
- 支持为转发路由器添加标签
- 为转发路由器分配 CIDR 地址段（可选，最多 5 个 CIDR 块）

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
| [alicloud_cen_transit_router_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/cen_transit_router_route_tables) | data source | 转发路由器路由表查询 |
| [alicloud_cen_transit_router.transit_router](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router) | resource | 转发路由器 |
| [alicloud_cen_transit_router_cidr.transit_router_cidr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_cidr) | resource | 转发路由器 CIDR 地址段（可选） |

## 使用方法

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name        = "enterprise-tr"
  transit_router_description = "企业转发路由器"
  
  transit_router_tags = {
    Environment = "production"
  }
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | CEN 实例 ID | `string` | - | 是 | - |
| `transit_router_name` | 转发路由器名称 | `string` | `null` | 否 | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `transit_router_description` | 转发路由器描述 | `string` | `null` | 否 | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `transit_router_tags` | 分配给转发路由器的标签 | `map(string)` | `null` | 否 | - |
| `transit_router_cidrs` | 分配给转发路由器的 CIDR 地址段列表 | `list(object)` | `[]` | 否 | 见下方转发路由器 CIDR 对象结构 |

### 转发路由器 CIDR 对象结构

`transit_router_cidrs` 中每个 CIDR 配置的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `cidr` | `string` | - | 是 | 要分配的 CIDR 地址段（子网掩码必须在 /16 到 /24 之间，包含边界） |
| `description` | `string` | `null` | 否 | CIDR 地址段的描述（1-256 个字符，不能以 http:// 或 https:// 开头） |
| `publish_cidr_route` | `bool` | `true` | 否 | 是否自动添加指向该 CIDR 地址段的路由 |
| `transit_router_cidr_name` | `string` | `null` | 否 | CIDR 地址段的名称（1-128 个字符，不能以 http:// 或 https:// 开头） |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `transit_router_id` | 创建的转发路由器 ID |
| `transit_router_region_id` | 创建的转发路由器所在区域 ID |
| `system_transit_router_route_table_id` | 系统转发路由器路由表 ID |
| `transit_router_cidrs` | 转发路由器 CIDR 地址段列表及其详细信息 |
| `transit_router_cidr_ids` | CIDR 地址段到转发路由器 CIDR ID 的映射 |

## 使用示例

### 基础转发路由器

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id      = "cen-xxxxxxxxxxxxx"
  transit_router_name = "my-tr"
}
```

### 转发路由器配置标签

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name        = "enterprise-tr"
  transit_router_description = "企业转发路由器"
  
  transit_router_tags = {
    Environment = "production"
    Project     = "landing-zone"
  }
}
```

### 转发路由器配置 CIDR 地址段

```hcl
module "cen_transit_router" {
  source = "./components/network/cen-transit-router"

  cen_instance_id            = "cen-xxxxxxxxxxxxx"
  transit_router_name        = "enterprise-tr"
  transit_router_description = "企业转发路由器"
  
  transit_router_cidrs = [
    {
      cidr                     = "192.168.0.0/24"
      description              = "主 CIDR 地址段，用于 VPN 网关 IP"
      publish_cidr_route       = true
      transit_router_cidr_name = "tr-cidr-primary"
    },
    {
      cidr                     = "192.168.1.0/24"
      description              = "备用 CIDR 地址段"
      publish_cidr_route       = false
      transit_router_cidr_name = "tr-cidr-secondary"
    }
  ]
}
```

## 注意事项

- 转发路由器必须在已存在的 CEN 实例中创建
- 自动获取系统路由表 ID 供 VPC 连接使用
- 名称和描述不能以 `http://` 或 `https://` 开头
- 可以为转发路由器添加标签用于资源管理

### 转发路由器 CIDR 地址段

配置 `transit_router_cidrs` 时，请注意以下限制：

- **最多 5 个地址段**：一个转发路由器最多支持配置 5 个地址段
- **子网掩码范围**：每个地址段的子网掩码位数不能少于 16 位，且不能超过 24 位（即 /16 到 /24）
- **CIDR 唯一性**：每个地址段必须唯一（不允许重复）
- **CIDR 重叠**：地址段之间不能重叠。阿里云 API 会在资源创建时验证重叠情况
- **禁止的 CIDR 范围**：以下 CIDR 范围及其子网不支持：
  - `100.64.0.0/10`
  - `224.0.0.0/4`
  - `127.0.0.0/8`
  - `169.254.0.0/16`

