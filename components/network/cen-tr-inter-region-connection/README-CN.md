<div align="right">

**中文** | [English](README.md)

</div>

# CEN 转发路由器跨地域连接组件

该组件用于创建两个 CEN 转发路由器之间的跨地域连接（Inter-Region Connection），并为两个转发路由器配置路由表关联和路由条目。

## 功能特性

- 创建两个转发路由器之间的跨地域连接
- 为本地和对端转发路由器配置路由表关联（可选）
- 为本地和对端转发路由器配置路由表传播（可选）
- 支持为两个转发路由器的路由表配置路由条目

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud.cen_tr | >= 1.267.0 |
| alicloud.cen_peer_tr | >= 1.267.0 |

该组件期望 `alicloud` provider 暴露以下**配置别名**（参见 `versions.tf` 和 stack 级别的 provider 配置）：

- `alicloud.cen_tr` – 用于转发路由器资源
- `alicloud.cen_peer_tr` – 用于对端转发路由器资源

当直接在 Terraform 中使用该组件（而不是通过 `tfcomponent.yaml`）时，必须定义这些别名并将其连接到模块，例如：

```hcl
provider "alicloud" {
  alias  = "cen_tr"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "cen_peer_tr"
  region = "cn-beijing"
}

module "cen_tr_inter_region_connection" {
  source = "./components/network/cen-tr-inter-region-connection"

  providers = {
    alicloud.cen_tr      = alicloud.cen_tr
    alicloud.cen_peer_tr = alicloud.cen_peer_tr
  }

  # ...inputs...
}
```

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_transit_router_peer_attachment.peer_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_peer_attachment) | resource | 跨地域连接 |
| [alicloud_cen_transit_router_route_table_association.tr_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | 转发路由器路由表关联（可选） |
| [alicloud_cen_transit_router_route_table_association.peer_tr_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | 对端转发路由器路由表关联（可选） |
| [alicloud_cen_transit_router_route_table_propagation.tr_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | 转发路由器路由表传播（可选） |
| [alicloud_cen_transit_router_route_table_propagation.peer_tr_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | 对端转发路由器路由表传播（可选） |
| [alicloud_cen_transit_router_route_entry.tr_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | 转发路由器路由表路由条目 |
| [alicloud_cen_transit_router_route_entry.peer_tr_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | 对端转发路由器路由表路由条目 |

## 使用方法

```hcl
module "cen_tr_inter_region_connection" {
  source = "./components/network/cen-tr-inter-region-connection"

  providers = {
    alicloud.cen_tr      = alicloud.cen_tr
    alicloud.cen_peer_tr = alicloud.cen_peer_tr
  }

  cen_instance_id                = "cen-xxxxxxxxxxxxx"
  transit_router_id              = "tr-xxxxxxxxxxxxx"
  peer_transit_router_id         = "tr-yyyyyyyyyyyyy"
  peer_transit_router_region_id  = "cn-beijing"

  transit_router_peer_attachment_name   = "sh-bj-inter-region-connection"
  transit_router_attachment_description = "上海和北京之间的跨地域连接"
  bandwidth                             = 10
  bandwidth_type                        = "BandwidthPackage"
  cen_bandwidth_package_id              = "cenbwp-xxxxxxxxxxxxx"
  auto_publish_route_enabled            = false

  # 转发路由器路由表配置
  tr_route_table_id                  = "vtb-xxxxxxxxxxxxx"
  tr_route_table_association_enabled  = false
  tr_route_table_propagation_enabled  = false
  tr_route_entries = [
    {
      destination_cidrblock = "10.0.0.0/8"
      name                  = "route-to-peer-tr"
      description           = "到对端转发路由器的路由 10.0.0.0/8"
    },
    {
      destination_cidrblock = "172.16.0.0/12"
      name                  = "route-to-peer-tr-2"
    }
  ]

  # 对端转发路由器路由表配置
  peer_tr_route_table_id                  = "vtb-zzzzzzzzzzzzz"
  peer_tr_route_table_association_enabled  = false
  peer_tr_route_table_propagation_enabled  = false
  peer_tr_route_entries = [
    {
      destination_cidrblock = "192.168.0.0/16"
      name                  = "route-to-local-tr"
      description           = "到本地转发路由器的路由 192.168.0.0/16"
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | CEN 实例 ID | `string` | - | 是 | - |
| `transit_router_id` | 转发路由器 ID | `string` | - | 是 | - |
| `peer_transit_router_id` | 对端转发路由器 ID | `string` | - | 是 | - |
| `peer_transit_router_region_id` | 对端转发路由器所在的地域 ID | `string` | `null` | 否 | - |
| `transit_router_peer_attachment_name` | 跨地域连接名称 | `string` | `null` | 否 | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `transit_router_attachment_description` | 跨地域连接描述 | `string` | `null` | 否 | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `bandwidth` | 跨地域连接的带宽值（Mbit/s） | `number` | `2` | 否 | - |
| `bandwidth_type` | 带宽分配方式 | `string` | `"BandwidthPackage"` | 否 | `BandwidthPackage` 或 `DataTransfer`（可为 null） |
| `cen_bandwidth_package_id` | 带宽包 ID | `string` | `null` | 否 | 当 bandwidth_type 为 BandwidthPackage 时必填 |
| `default_link_type` | 默认线路类型 | `string` | `"Gold"` | 否 | `Platinum` 或 `Gold`（可为 null；Platinum 仅在 bandwidth_type 为 DataTransfer 时支持） |
| `auto_publish_route_enabled` | 是否启用自动向对端转发路由器发布路由 | `bool` | `false` | 否 | - |
| `tags` | 跨地域连接的标签 | `map(string)` | `{}` | 否 | - |
| `tr_route_table_id` | 转发路由器路由表 ID | `string` | - | 是 | - |
| `tr_route_table_association_enabled` | 是否为转发路由器创建路由表关联 | `bool` | `false` | 否 | - |
| `tr_route_table_propagation_enabled` | 是否为转发路由器创建路由表传播 | `bool` | `false` | 否 | - |
| `tr_route_entries` | 转发路由器路由表的路由条目列表。所有路由条目的下一跳都是新建的这个跨地域连接 | `list(object)` | `[]` | 否 | 参见下方路由条目对象结构 |
| `peer_tr_route_table_id` | 对端转发路由器路由表 ID | `string` | - | 是 | - |
| `peer_tr_route_table_association_enabled` | 是否为对端转发路由器创建路由表关联 | `bool` | `false` | 否 | - |
| `peer_tr_route_table_propagation_enabled` | 是否为对端转发路由器创建路由表传播 | `bool` | `false` | 否 | - |
| `peer_tr_route_entries` | 对端转发路由器路由表的路由条目列表。所有路由条目的下一跳都是新建的这个跨地域连接 | `list(object)` | `[]` | 否 | 参见下方路由条目对象结构 |

### 路由条目对象结构

`tr_route_entries` 或 `peer_tr_route_entries` 中的每个路由条目必须具有以下结构：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `destination_cidrblock` | `string` | 是 | 路由条目的目标 CIDR 网段（有效的 IPv4 CIDR） |
| `name` | `string` | 否 | 路由条目名称（1-128 个字符，不能以 http:// 或 https:// 开头） |
| `description` | `string` | 否 | 路由条目描述（1-256 个字符，不能以 http:// 或 https:// 开头） |

**注意：**
- 路由表关联和传播仅在对应的 `*_enabled` 标志设置为 `true` 时才会创建。
- 所有路由条目将自动使用本组件新建的跨地域连接（peer attachment）作为下一跳（`nexthop_type` 固定为 `Attachment`）。

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `peer_attachment_id` | 跨地域连接 ID |
| `tr_association_id` | 转发路由器路由表关联 ID（未启用时为 null） |
| `peer_tr_association_id` | 对端转发路由器路由表关联 ID（未启用时为 null） |
| `tr_propagation_id` | 转发路由器路由表传播 ID（未启用时为 null） |
| `peer_tr_propagation_id` | 对端转发路由器路由表传播 ID（未启用时为 null） |
| `tr_route_entries` | 转发路由器路由表的路由条目列表，包含 id |
| `peer_tr_route_entries` | 对端转发路由器路由表的路由条目列表，包含 id |

## 注意事项

- 该组件需要两个 provider 别名：`alicloud.cen_tr` 用于转发路由器地域，`alicloud.cen_peer_tr` 用于对端转发路由器地域。
- `tr_route_table_id` 和 `peer_tr_route_table_id` 是必填参数。
- 路由表关联和传播仅在对应的 `*_enabled` 标志设置为 `true` 时才会创建。
- 路由条目会为 `tr_route_entries` 和 `peer_tr_route_entries` 中定义的所有条目创建。
- 跨地域连接使用 `cen_tr` provider 创建，但两个 provider 都用于路由表关联、传播和路由条目。
