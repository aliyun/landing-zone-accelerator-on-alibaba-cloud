<div align="right">

**中文** | [English](README.md)

</div>

# DMZ VPC 组件

该组件用于创建和管理 DMZ（隔离区）VPC，实现安全的出站互联网连接，包括 VPC、交换机、NAT 网关、EIP 和 CEN 集成。

## 功能特性

- 创建可配置 CIDR 的 DMZ VPC
- 为转发路由器创建交换机（主备）
- 为 NAT 网关创建交换机
- 根据需要创建额外的交换机
- 创建 EIP 实例，支持共享带宽包
- 创建 NAT 网关用于出站互联网访问
- 将 DMZ VPC 连接到 CEN 转发路由器
- 在转发路由器中配置出站路由条目（0.0.0.0/0）

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |
| alicloud.cen | >= 1.262.1 |
| alicloud.dmz | >= 1.262.1 |

## Modules

| Name | Source | Description |
|------|--------|-------------|
| dmz_eip | ../../../modules/eip | NAT 网关的 EIP 实例 |
| dmz_nat_gateway | ../../../modules/nat-gateway | 出站访问的 NAT 网关 |
| dmz_vpc_attach_to_cen | ../../../modules/cen-vpc-attach | VPC 到 CEN 转发路由器的连接 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_vpc.dmz_vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | DMZ VPC |
| [alicloud_vswitch.dmz_vswitch_for_tr](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | 转发路由器的交换机（需要 2 个） |
| [alicloud_vswitch.dmz_vswitch_for_nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | NAT 网关的交换机 |
| [alicloud_vswitch.dmz_vswitch](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | 额外的交换机 |
| [alicloud_cen_transit_router_route_entry.dmz_vpc_outbound](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_entry) | resource | 出站路由条目（0.0.0.0/0） |

## 使用方法

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_name        = "dmz-vpc"
  dmz_vpc_cidr        = "10.0.0.0/16"
  dmz_vpc_description = "用于出站访问的 DMZ VPC"

  dmz_vswitch_for_tr = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "转发路由器主交换机"
      vswitch_cidr        = "10.0.1.0/29"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "转发路由器备交换机"
      vswitch_cidr        = "10.0.1.8/29"
    }
  ]

  dmz_vswitch_for_nat_gateway = {
    zone_id             = "cn-hangzhou-h"
    vswitch_name        = "dmz-nat"
    vswitch_description = "NAT 网关交换机"
    vswitch_cidr        = "10.0.2.0/24"
  }

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
| `dmz_vswitch_for_tr` | 转发路由器的交换机 | `list(object)` | - | Yes | 必须包含恰好 2 个交换机 |
| `dmz_vswitch_for_nat_gateway` | NAT 网关的交换机 | `object` | - | Yes | 参见交换机对象结构 |
| `dmz_vswitch` | 额外的交换机 | `list(object)` | `[]` | No | 参见交换机对象结构 |
| `dmz_egress_nat_gateway_name` | NAT 网关名称 | `string` | `null` | No | 非空时 2-128 个字符 |
| `dmz_egress_nat_gateway_tags` | NAT 网关标签 | `map(string)` | `{}` | No | - |
| `dmz_egress_eip_instances` | EIP 实例配置列表 | `list(object)` | `[]` | No | 参见 EIP 实例结构 |
| `dmz_enable_common_bandwidth_package` | 是否启用共享带宽包 | `bool` | `true` | No | - |
| `dmz_common_bandwidth_package_name` | 共享带宽包名称 | `string` | `null` | No | 非空时 2-256 个字符，必须以字母开头 |
| `dmz_common_bandwidth_package_bandwidth` | 共享带宽包带宽（Mbps） | `string` | `"5"` | No | 1-1000 |
| `dmz_common_bandwidth_package_internet_charge_type` | 计费方式 | `string` | `"PayByBandwidth"` | No | 必须是：`PayByBandwidth`、`PayBy95` 或 `PayByDominantTraffic` |
| `dmz_common_bandwidth_package_ratio` | PayBy95 计费的比率 | `number` | `20` | No | 必须是 20 |
| `dmz_tr_attachment_name` | 转发路由器 VPC 连接名称 | `string` | `""` | No | 非空时 2-128 个字符 |
| `dmz_tr_attachment_description` | 转发路由器 VPC 连接描述 | `string` | `""` | No | 非空时 1-256 个字符 |
| `dmz_outbound_route_entry_name` | 出站路由条目名称 | `string` | `null` | No | 非空时 2-128 个字符，必须以字母开头 |
| `dmz_outbound_route_entry_description` | 出站路由条目描述 | `string` | `null` | No | 非空时 1-256 个字符 |

### 交换机对象结构

每个交换机对象必须具有以下结构：

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| `zone_id` | `string` | Yes | 可用区 ID | - |
| `vswitch_name` | `string` | Yes | 交换机名称 | - |
| `vswitch_description` | `string` | Yes | 交换机描述 | - |
| `vswitch_cidr` | `string` | Yes | 交换机 CIDR 网段 | 有效的 IPv4 CIDR 块 |
| `tags` | `map(string)` | No | 交换机的标签 | - |

**注意**：对于 `dmz_vswitch_for_tr`，需要恰好 2 个交换机（主备）。建议使用 /29 CIDR 块。

### EIP 实例对象结构

每个 EIP 实例对象必须具有以下结构：

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `payment_type` | `string` | `"PayAsYouGo"` | No | 付费类型 | 必须是：`Subscription` 或 `PayAsYouGo` |
| `period` | `number` | `null` | No | 订阅时长 | 当 `payment_type = "Subscription"` 时必需 |
| `eip_address_name` | `string` | `null` | No | EIP 地址名称 | 非空时 1-128 个字符，必须以字母开头 |
| `tags` | `map(string)` | `{}` | No | 标签 | - |

## 输出参数

| Name | Description |
|------|-------------|
| `dmz_vpc_id` | DMZ VPC ID |
| `dmz_route_table_id` | DMZ VPC 路由表 ID |
| `nat_gateway_id` | NAT 网关 ID |
| `dmz_vswitch_for_tr` | 转发路由器的交换机列表 |
| `dmz_vswitch_for_nat_gateway` | NAT 网关的交换机 |
| `dmz_vswitch` | 额外的交换机列表 |
| `transit_router_vpc_attachment_id` | 转发路由器 VPC 连接 ID |
| `transit_router_outbound_route_entry_id` | 出站路由条目 ID |
| `eip_instances` | EIP 实例列表 |
| `common_bandwidth_package_id` | 共享带宽包 ID |

## 使用示例

### 基础 DMZ VPC 配置

```hcl
module "dmz" {
  source = "./components/network/dmz"

  providers = {
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"

  dmz_vswitch_for_tr = [
    {
      zone_id             = "cn-hangzhou-h"
      vswitch_name        = "dmz-tr-primary"
      vswitch_description = "主交换机"
      vswitch_cidr        = "10.0.1.0/29"
    },
    {
      zone_id             = "cn-hangzhou-i"
      vswitch_name        = "dmz-tr-secondary"
      vswitch_description = "备交换机"
      vswitch_cidr        = "10.0.1.8/29"
    }
  ]

  dmz_vswitch_for_nat_gateway = {
    zone_id             = "cn-hangzhou-h"
    vswitch_name        = "dmz-nat"
    vswitch_description = "NAT 网关"
    vswitch_cidr        = "10.0.2.0/24"
  }

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
    alicloud.cen = alicloud.cen
    alicloud.dmz = alicloud.dmz
  }

  cen_instance_id           = "cen-xxxxxxxxxxxxx"
  cen_transit_router_id    = "tr-xxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  dmz_vpc_cidr = "10.0.0.0/16"
  
  dmz_enable_common_bandwidth_package = true
  dmz_common_bandwidth_package_bandwidth = "100"
  dmz_common_bandwidth_package_internet_charge_type = "PayByBandwidth"

  dmz_vswitch_for_tr = [...]
  dmz_vswitch_for_nat_gateway = {...}
  dmz_egress_eip_instances = [...]
}
```

## 注意事项

- DMZ VPC 设计用于安全的出站互联网连接
- 转发路由器连接需要恰好 2 个交换机（主备）
- 建议转发路由器交换机使用 /29 CIDR 块
- NAT 网关为 DMZ VPC 中的资源提供出站互联网访问
- EIP 实例自动关联到 NAT 网关
- 共享带宽包可用于在 EIP 实例之间共享带宽
- 转发路由器连接支持通过 CEN 连接到其他 VPC
- 出站路由条目（0.0.0.0/0）将所有出站流量路由到 DMZ VPC
- 转发路由器连接自动启用路由表关联和传播

