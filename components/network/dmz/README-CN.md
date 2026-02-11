<div align="right">

**中文** | [English](README.md)

</div>

# DMZ VPC 组件

该组件用于创建和管理 DMZ（隔离区）VPC，实现安全的出站互联网连接，包括 VPC、交换机、NAT 网关、EIP 和 CEN 集成。

## 功能特性

- 创建可配置 CIDR 的 DMZ VPC
- 创建可配置用途的交换机
- 创建 EIP 实例，支持共享带宽包
- 创建 NAT 网关用于出站互联网访问
- 将 DMZ VPC 连接到 CEN 转发路由器
- 在转发路由器中配置出站路由条目（0.0.0.0/0）

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.cen_tr | >= 1.267.0 |
| alicloud.dmz | >= 1.267.0 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| dmz_vpc | ../../../modules/vpc | DMZ VPC 和交换机 |
| dmz_eip | ../../../modules/eip | NAT 网关的 EIP 实例 |
| dmz_nat_gateway | ../../../modules/nat-gateway | 出站访问的 NAT 网关 |
| dmz_vpc_attach_to_cen | ../../../modules/cen-vpc-attach | VPC 到 CEN 转发路由器的连接 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_route_entry.dmz_cen_route_entries](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_entry) | resource | 发布路由到 CEN 路由表的路由条目 |

## 使用方法

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_name        = "dmz-vpc"
  dmz_vpc_cidr        = "10.0.0.0/16"
  dmz_vpc_description = "用于出站访问的 DMZ VPC"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "转发路由器主交换机"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "转发路由器备交换机"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "NAT 网关交换机"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]

  dmz_egress_nat_gateway_name = "dmz-nat-gateway"
  dmz_egress_eip_instances = [
    {
      payment_type = "PayAsYouGo"
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `cen_instance_id` | CEN 实例 ID | `string` | - | Yes | - |
| `cen_transit_router_id` | 转发路由器 ID | `string` | - | Yes | - |
| `transit_router_route_table_id` | 转发路由器路由表 ID | `string` | - | Yes | - |
| `dmz_vpc_name` | DMZ VPC 名称 | `string` | `null` | No | 非空时 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `dmz_vpc_description` | DMZ VPC 描述 | `string` | `null` | No | 非空时 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `dmz_vpc_cidr` | DMZ VPC CIDR 网段 | `string` | - | Yes | 有效的 IPv4 CIDR 块 |
| `dmz_vpc_tags` | DMZ VPC 标签 | `map(string)` | `{}` | No | - |
| `dmz_vswitch` | DMZ VPC 中的交换机 | `list(object)` | - | Yes | 必须包含至少 2 个 `purpose="TR"` 的交换机和恰好 1 个 `purpose="NATGW"` 的交换机。参见交换机对象结构 |
| `dmz_egress_nat_gateway_name` | NAT 网关名称 | `string` | `null` | No | 非空时 2-128 个字符 |
| `dmz_egress_nat_gateway_description` | DMZ NAT 网关描述 | `string` | `null` | No | 非空时 2-256 个字符，且不能以 http:// 或 https:// 开头 |
| `dmz_egress_nat_gateway_tags` | NAT 网关标签 | `map(string)` | `{}` | No | - |
| `dmz_egress_nat_gateway_deletion_protection` | 是否为 DMZ NAT 网关启用删除保护 | `bool` | `false` | No | - |
| `dmz_egress_nat_gateway_eip_bind_mode` | DMZ NAT 网关的 EIP 绑定模式 | `string` | `"MULTI_BINDED"` | No | 取值：`MULTI_BINDED`、`NAT` |
| `dmz_egress_nat_gateway_icmp_reply_enabled` | 是否在 DMZ NAT 网关上启用 ICMP 回显 | `bool` | `true` | No | - |
| `dmz_egress_nat_gateway_private_link_enabled` | 是否为 DMZ NAT 网关启用 PrivateLink | `bool` | `false` | No | 如为 true，建议同时配置 `dmz_egress_nat_gateway_access_mode` |
| `dmz_egress_nat_gateway_access_mode` | 反向访问 DMZ NAT 网关的接入模式配置 | `set(object)` | `[]` | No | 每个元素需满足：`mode_value` 为 `route` 或 `tunnel`；当 `mode_value = "tunnel"` 且设置了 `tunnel_type` 时，必须为 `geneve` |
| `dmz_nat_gateway_snat_entries` | DMZ NAT 网关的 SNAT 条目配置 | `list(object)` | `[]` | No | 仅支持 `source_cidr`（不支持 `source_vswitch_id`）。每个条目必须包含 `source_cidr`（必填）。参见 SNAT 条目对象结构 |
| `dmz_vpc_route_entries` | DMZ VPC 系统路由表的路由条目。所有条目使用转发路由器连接作为下一跳 | `list(object)` | `[]` | No | 参见路由条目对象结构 |
| `dmz_egress_eip_instances` | EIP 实例配置列表 | `list(object)` | `[]` | No | 参见 EIP 实例结构 |
| `dmz_enable_common_bandwidth_package` | 是否启用共享带宽包 | `bool` | `true` | No | - |
| `dmz_common_bandwidth_package_name` | 共享带宽包名称 | `string` | `null` | No | 非空时 2-256 个字符，必须以字母开头 |
| `dmz_common_bandwidth_package_bandwidth` | 共享带宽包带宽（Mbps） | `string` | `"5"` | No | 1-1000 |
| `dmz_common_bandwidth_package_internet_charge_type` | 计费方式 | `string` | `"PayByBandwidth"` | No | 必须是：`PayByBandwidth`、`PayBy95` 或 `PayByDominantTraffic` |
| `dmz_common_bandwidth_package_ratio` | PayBy95 计费的比率 | `number` | `20` | No | 必须是 20 |
| `dmz_common_bandwidth_package_deletion_protection` | 是否启用删除保护 | `bool` | `false` | No | - |
| `dmz_common_bandwidth_package_description` | 共享带宽实例的描述 | `string` | `null` | No | 非空时 0-256 个字符，不能以 http:// 或 https:// 开头 |
| `dmz_common_bandwidth_package_isp` | 共享带宽包的线路类型 | `string` | `"BGP"` | No | 必须是：`BGP` 或 `BGP_PRO` |
| `dmz_common_bandwidth_package_resource_group_id` | 资源组 ID | `string` | `null` | No | - |
| `dmz_common_bandwidth_package_security_protection_types` | 抗 DDoS 版本 | `list(string)` | `[]` | No | 空列表表示基础版，`AntiDDoS_Enhanced` 表示增强版。仅在 internet_charge_type 为 PayBy95 时有效。最多 10 个元素 |
| `dmz_common_bandwidth_package_tags` | 共享带宽包资源的标签 | `map(string)` | `{}` | No | - |
| `dmz_tr_attachment_name` | 转发路由器 VPC 连接名称 | `string` | `""` | No | 非空时 2-128 个字符 |
| `dmz_tr_attachment_description` | 转发路由器 VPC 连接描述 | `string` | `""` | No | 非空时 1-256 个字符 |
| `dmz_tr_route_table_association_enabled` | 是否为 DMZ VPC 连接启用路由表关联 | `bool` | `true` | No | - |
| `dmz_tr_route_table_propagation_enabled` | 是否为 DMZ VPC 连接启用路由表传播 | `bool` | `true` | No | - |
| `dmz_tr_attachment_force_delete` | 是否强制删除 DMZ VPC 连接及其相关依赖 | `bool` | `false` | No | - |
| `dmz_tr_attachment_tags` | DMZ 转发路由器 VPC 连接的标签 | `map(string)` | `{}` | No | - |
| `dmz_tr_attachment_options` | DMZ VPC 连接的 TransitRouterVpcAttachmentOptions 配置 | `map(string)` | `{}` | No | - |
| `cen_service_linked_role_exists` | CEN 服务关联角色是否已存在。如果为 true，模块将不会创建服务关联角色。如果为 false，模块将创建它 | `bool` | `false` | No | - |
| `create_cen_instance_grant` | 是否为跨账号连接创建 CEN 实例授权。**当 CEN 和 VPC 在不同账号时，必须设置为 `true`；在同一账号时，必须设置为 `false`。**  | `bool` | `false` | No | - |
| `dmz_tr_attachment_auto_publish_route_enabled` | 是否启用企业版转发路由器自动向 VPC 发布路由 | `bool` | `false` | No | - |
| `cen_route_entry_cidr_blocks` | 要发布为 CEN 路由条目的 CIDR 块列表。路由将发布到转发路由器路由表 | `list(string)` | `[]` | No | 每个条目必须是有效的 IPv4 CIDR 块 |

### 交换机对象结构

每个交换机对象必须具有以下结构：

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `zone_id` | `string` | Yes | 可用区 ID | - |
| `vswitch_name` | `string` | Yes | 交换机名称 | - |
| `vswitch_description` | `string` | Yes | 交换机描述 | - |
| `vswitch_cidr` | `string` | Yes | 交换机 CIDR 网段 | 有效的 IPv4 CIDR 块 |
| `purpose` | `string` | No | 交换机用途 | `"TR"` 用于转发路由器连接，`"NATGW"` 用于 NAT 网关，或 `null`/空字符串表示普通交换机 |
| `tags` | `map(string)` | No | 交换机的标签 | - |

**注意**：
- 至少需要 2 个 `purpose="TR"` 的交换机（主备）。建议转发路由器交换机使用 /29 CIDR 块。
- 恰好需要 1 个 `purpose="NATGW"` 的交换机用于 NAT 网关。
- 可以根据需要添加不设置 `purpose`（或 `purpose=null`）的普通交换机。

### EIP 实例对象结构

每个 EIP 实例对象必须具有以下结构：

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
| `tags` | `map(string)` | `{}` | 否 | EIP 标签 | - |

### SNAT 条目对象结构

每个 SNAT 条目对象必须具有以下结构：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `source_cidr` | `string` | - | 是 | SNAT 的源 CIDR 网段 | 有效的 IPv4 CIDR 块 |
| `snat_entry_name` | `string` | `null` | 否 | SNAT 条目名称 | 非空时 2-128 个字符，必须以字母开头，不能以 http:// 或 https:// 开头 |
| `eip_affinity` | `number` | `0` | 否 | EIP 亲和模式 | 必须为 `0` 或 `1` |

**注意**：
- 仅支持 `source_cidr`。此组件中不允许使用 `source_vswitch_id`。
- `snat_ips` 会自动设置为该组件创建的所有 EIP IP 地址（`dmz_egress_eip_instances`）。您无需在配置中指定 `snat_ips` 或 `use_all_associated_eips`。

### 路由条目对象结构

每个路由条目对象必须具有以下结构：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `destination_cidrblock` | `string` | - | 是 | 目标 CIDR 网段 | 有效的 IPv4 CIDR 块（如 0.0.0.0/0） |
| `name` | `string` | `null` | 否 | 路由条目名称 | 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `description` | `string` | `null` | 否 | 路由条目描述 | 1-256 个字符，不能以 http:// 或 https:// 开头 |

**注意**：路由条目始终添加到 VPC 系统路由表。所有路由条目自动使用转发路由器连接作为下一跳（`nexthop_type` 固定为 `Attachment`）。路由条目由 `modules/cen-vpc-attach` 模块在 CEN 连接建立后创建。

## 输出参数

| Name | Description |
|------|-------------|
| `dmz_vpc_id` | DMZ VPC ID |
| `dmz_route_table_id` | DMZ VPC 路由表 ID |
| `nat_gateway_id` | NAT 网关 ID |
| `dmz_vswitch` | 所有交换机列表（包含其用途） |
| `dmz_vswitch_for_tr` | 转发路由器的交换机列表（通过 `purpose="TR"` 过滤） |
| `dmz_vswitch_for_nat_gateway` | NAT 网关的交换机（通过 `purpose="NATGW"` 过滤） |
| `transit_router_vpc_attachment_id` | 转发路由器 VPC 连接 ID |
| `eip_instances` | EIP 实例列表 |
| `common_bandwidth_package_id` | 共享带宽包 ID |

## 使用示例

### 基础 DMZ VPC 配置

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "转发路由器主交换机"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "转发路由器备交换机"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "NAT 网关交换机"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]

  dmz_egress_eip_instances = [
    {
      payment_type = "PayAsYouGo"
    }
  ]
}
```

### DMZ 配置共享带宽包

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"
  
  dmz_enable_common_bandwidth_package = true
  dmz_common_bandwidth_package_bandwidth = "100"
  dmz_common_bandwidth_package_internet_charge_type = "PayByBandwidth"

  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "转发路由器主交换机"
      vswitch_cidr        = "10.0.1.0/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "转发路由器备交换机"
      vswitch_cidr        = "10.0.1.8/29"
      purpose             = "TR"
    },
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-nat"
      vswitch_description = "NAT 网关交换机"
      vswitch_cidr        = "10.0.2.0/24"
      purpose             = "NATGW"
    }
  ]
  dmz_egress_eip_instances = [...]
}
```

## 注意事项

- DMZ VPC 设计用于安全的出站互联网连接
- 至少需要 2 个 `purpose="TR"` 的交换机用于转发路由器连接（主备）
- 恰好需要 1 个 `purpose="NATGW"` 的交换机用于 NAT 网关
- 建议转发路由器交换机使用 /29 CIDR 块
- NAT 网关为 DMZ VPC 中的资源提供出站互联网访问
- EIP 实例自动关联到 NAT 网关
- 共享带宽包可用于在 EIP 实例之间共享带宽
- 转发路由器连接支持通过 CEN 连接到其他 VPC
- 出站路由条目（0.0.0.0/0）将所有出站流量路由到 DMZ VPC
- 路由表关联和传播可通过 `dmz_tr_route_table_association_enabled` 和 `dmz_tr_route_table_propagation_enabled` 变量控制（默认值：`true`）

