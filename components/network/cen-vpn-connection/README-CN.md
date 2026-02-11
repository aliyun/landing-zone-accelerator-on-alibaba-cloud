<div align="right">

**中文** | [English](README.md)

</div>

# CEN VPN 连接组件

该组件用于创建和管理双隧道模式的 VPN 连接（IPsec）并将其连接到阿里云 CEN 转发路由器。

## 功能特性

- 创建多个用户网关（本地 VPN 设备表示）
- 创建双隧道模式的 VPN 连接（IPsec 连接）
- 将 VPN 网关连接到 CEN 转发路由器
- 支持每个隧道独立的 IKE、IPsec 和 BGP 配置
- 支持自动发布路由到转发路由器
- 提供隧道间自动故障转移的高可用性
- 当用户未提供 PSK 时，自动为隧道生成预共享密钥（PSK）

## 重要说明

绑定转发路由器场景下，VPN 连接**仅支持双隧道模式**。必须配置恰好 2 个使用不同用户网关的隧道以实现链路冗余。

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| random | >= 3.6.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_vpn_customer_gateway.customer_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpn_customer_gateway) | resource | 用户网关（本地 VPN 设备） |
| [alicloud_vpn_gateway_vpn_attachment.ipsec_connection](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpn_gateway_vpn_attachment) | resource | IPsec-VPN 连接（双隧道模式） |
| [alicloud_cen_transit_router_vpn_attachment.transit_router_vpn_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpn_attachment) | resource | 转发路由器 VPN 连接 |
| [random_string.tunnel_psk](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource | 当用户未提供 PSK 时，为隧道自动生成随机 PSK |

## 使用方法

```hcl
module "vpn_attachment" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id              = "cen-xxxxxxxxxxxxx"
  transit_router_id            = "tr-xxxxxxxxxxxxx"
  customer_gateway_ip_address  = "203.0.113.1"
  customer_gateway_asn         = "65001"

  local_subnet  = "10.0.0.0/16"
  remote_subnet = "192.168.0.0/16"

  ike_config = {
    psk = "your_pre_shared_key"
  }

  ipsec_config = {
    ipsec_enc_alg = "aes"
  }
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | CEN 实例 ID | `string` | - | 是 | - |
| `transit_router_id` | 转发路由器 ID | `string` | - | 是 | - |
| `customer_gateways` | 要创建的用户网关列表 | `list(object)` | - | 是 | 见用户网关对象结构。名称必须唯一。至少需要 2 个网关 |
| `ipsec_connection_name` | IPsec-VPN 连接名称 | `string` | `null` | 否 | 非空时 1-128 个字符 |
| `local_subnet` | 阿里云侧的 CIDR 地址段 | `string` | - | 是 | 逗号分隔的 IPv4 CIDR。使用 `0.0.0.0/0` 为目的路由模式 |
| `remote_subnet` | 本地侧的 CIDR 地址段 | `string` | - | 是 | 逗号分隔的 IPv4 CIDR。使用 `0.0.0.0/0` 为目的路由模式 |
| `network_type` | 网络类型 | `string` | `"public"` | 否 | 必须是：`public` 或 `private` |
| `effect_immediately` | 是否立即生效 | `bool` | `false` | 否 | - |
| `enable_tunnels_bgp` | 是否为隧道启用 BGP | `bool` | `false` | 否 | 如果为 true，则必须为每个隧道配置 tunnel_bgp_config。v1.246.0 版本起可用 |
| `tunnels_bgp_local_asn` | 两个隧道的 BGP 路由本地 ASN | `number` | `45104` | 否 | 所有隧道共享的配置。仅在 enable_tunnels_bgp 为 true 时使用。范围：1-4294967295 |
| `tunnel_options_specification` | 隧道配置 | `set(object)` | - | 是 | 见隧道选项结构。必须包含使用不同用户网关的 2 个隧道 |
| `transit_router_vpn_attachment_name` | 转发路由器 VPN 连接名称 | `string` | `null` | 否 | 非空时 1-128 个字符 |
| `transit_router_vpn_attachment_description` | 转发路由器 VPN 连接描述 | `string` | `null` | 否 | 非空时 1-256 个字符 |
| `auto_publish_route_enabled` | 是否自动发布路由 | `bool` | `true` | 否 | - |
| `cen_tr_route_table_association_enabled` | 是否启用路由表关联 | `bool` | `false` | 否 | - |
| `cen_tr_route_table_propagation_enabled` | 是否启用路由表传播（路由学习） | `bool` | `false` | 否 | - |
| `cen_tr_route_table_id` | 用于关联和传播的转发路由器路由表 ID | `string` | `null` | 否 | 启用关联或传播时必填 |
| `ipsec_connection_resource_group_id` | IPsec-VPN 连接的资源组 ID | `string` | `null` | 否 | v1.246.0 版本起可用 |
| `ipsec_connection_tags` | IPsec-VPN 连接的标签 | `map(string)` | `null` | 否 | v1.246.0 版本起可用 |
| `transit_router_vpn_attachment_tags` | 转发路由器 VPN 连接的标签 | `map(string)` | `null` | 否 | - |

### 用户网关对象结构

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `ip_address` | `string` | 是 | 用户网关的公网 IP 地址。不能在以下范围内：100.64.0.0~100.127.255.255、127.0.0.0~127.255.255.255、169.254.0.0~169.254.255.255、224.0.0.0~239.255.255.255、255.0.0.0~255.255.255.255 |
| `asn` | `string` | 否 | 用户网关的 ASN（用于 BGP，1-4294967295，不能为 45104） |
| `name` | `string` | 是 | 用户网关名称（1-100 个字符，不能以 http:// 或 https:// 开头） |
| `description` | `string` | 否 | 用户网关描述（1-100 个字符，不能以 http:// 或 https:// 开头） |
| `tags` | `map(string)` | 否 | 分配给用户网关的标签 |

### 隧道选项结构

`tunnel_options_specification` 中的每个隧道对象包含：

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `customer_gateway_name` | `string` | - | 是 | customer_gateways 映射中的用户网关名称。每个隧道必须使用不同的用户网关 |
| `enable_dpd` | `bool` | `true` | 否 | 是否为此隧道启用 Dead Peer Detection |
| `enable_nat_traversal` | `bool` | `true` | 否 | 是否为此隧道启用 NAT Traversal |
| `tunnel_index` | `number` | - | 是 | 隧道索引：必须为 1 或 2 |
| `tunnel_bgp_config` | `object` | `null` | 否 | 此隧道的 BGP 配置（见隧道 BGP 配置） |
| `tunnel_ike_config` | `object` | `null` | 否 | 此隧道的 IKE 配置（见隧道 IKE 配置） |
| `tunnel_ipsec_config` | `list(object)` | `null` | 否 | 此隧道的 IPsec 配置（见隧道 IPsec 配置） |

#### 隧道 BGP 配置

当 `enable_tunnels_bgp` 为 true 时必需配置。`local_asn` 通过 `tunnels_bgp_local_asn` 变量全局配置。

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `local_bgp_ip` | `string` | 是 | 此隧道的本地 BGP IP 地址 |
| `tunnel_cidr` | `string` | 是 | 此隧道的隧道 CIDR 地址段（掩码长度 30，在 169.254.0.0/16 范围内） |

#### 隧道 IKE 配置

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `ike_auth_alg` | `string` | `"sha1"` | 否 | IKE 认证算法 |
| `ike_enc_alg` | `string` | `"aes"` | 否 | IKE 加密算法 |
| `ike_lifetime` | `number` | `86400` | 否 | IKE 生存时间（秒） |
| `ike_mode` | `string` | `"main"` | 否 | IKE 协商模式 |
| `ike_pfs` | `string` | `"group2"` | 否 | IKE 完美前向保密 |
| `ike_version` | `string` | `"ikev2"` | 否 | IKE 版本 |
| `local_id` | `string` | `null` | 否 | 本地标识符 |
| `psk` | `string` | `null` | 否 | 预共享密钥。如果不提供，将自动生成随机 PSK。支持数字、大小写英文字母及特殊字符：`~`!@#$%^&*()_-+={}[]\|;:',.<>/?`（不能包含空格） |
| `psk_random_length` | `number` | `16` | 否 | 当未提供 `psk` 时，随机生成的 PSK 长度。范围：1-100。仅在未提供 `psk` 时使用 |
| `remote_id` | `string` | `null` | 否 | 远程标识符 |

#### 隧道 IPsec 配置

| 字段 | 类型 | 默认值 | 必填 | 说明 |
|------|------|--------|------|------|
| `ipsec_auth_alg` | `string` | `"sha1"` | 否 | IPsec 认证算法 |
| `ipsec_enc_alg` | `string` | `"aes"` | 否 | IPsec 加密算法 |
| `ipsec_lifetime` | `number` | `86400` | 否 | IPsec 生存时间（秒） |
| `ipsec_pfs` | `string` | `"group2"` | 否 | IPsec 完美前向保密 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `customer_gateway_ids` | 用户网关 ID 映射，以用户网关名称为 key |
| `customer_gateways` | 用户网关详细信息映射（id、ip_address、asn、name、description），以用户网关名称为 key |
| `ipsec_connection_id` | 双隧道模式 IPsec-VPN 连接 ID |
| `ipsec_connection` | IPsec-VPN 连接详细信息（id、name、local_subnet、remote_subnet、network_type、enable_tunnels_bgp、status、create_time） |
| `transit_router_vpn_attachment_id` | 转发路由器 VPN 连接 ID |
| `route_table_association_id` | 路由表关联 ID（未启用时为 null） |
| `route_table_propagation_id` | 路由表传播 ID（未启用时为 null） |
| `tunnel_psks` | 每个隧道的 PSK 值映射，以 customer_gateway_name 为 key。包含用户提供的和自动生成的 PSK。使用此输出获取 PSK 值以配置本地 VPN 设备 |

## 使用示例

### 双隧道 VPN 连接（必需配置）

```hcl
module "vpn_attachment_dual_tunnel" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id   = "cen-xxxxxxxxxxxxx"
  transit_router_id = "tr-xxxxxxxxxxxxx"
  
  # 创建两个用户网关以实现冗余
  customer_gateways = [
    {
      ip_address  = "203.0.113.1"
      asn         = "65001"
      name        = "本地网关-1"
      description = "主 VPN 网关"
      tags = {
        Type = "Primary"
      }
    },
    {
      ip_address  = "203.0.113.2"
      asn         = "65002"
      name        = "本地网关-2"
      description = "备 VPN 网关"
      tags = {
        Type = "Secondary"
      }
    }
  ]
  
  ipsec_connection_name = "ipsec-connection-dual-tunnel"

  local_subnet          = "10.0.0.0/16"
  remote_subnet         = "192.168.0.0/16"
  network_type          = "public"
  enable_tunnels_bgp    = true
  tunnels_bgp_local_asn = 45104

  # 配置两个使用不同用户网关的隧道
  tunnel_options_specification = [
    {
      customer_gateway_name = "本地网关-1"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 1
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.11.1"
        tunnel_cidr  = "169.254.11.0/30"
      }
      tunnel_ike_config = {
        ike_auth_alg = "sha1"
        ike_enc_alg  = "aes"
        ike_lifetime = 86400
        ike_mode     = "main"
        ike_pfs      = "group2"
        ike_version  = "ikev2"
        local_id     = "tunnel-1-local"
        psk          = "tunnel_1_pre_shared_key"
        remote_id    = "203.0.113.1"
      }
      tunnel_ipsec_config = [
        {
          ipsec_auth_alg = "sha1"
          ipsec_enc_alg  = "aes"
          ipsec_lifetime = 86400
          ipsec_pfs      = "group2"
        }
      ]
    },
    {
      customer_gateway_name = "本地网关-2"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 2
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.12.1"
        tunnel_cidr  = "169.254.12.0/30"
      }
      tunnel_ike_config = {
        ike_auth_alg = "sha1"
        ike_enc_alg  = "aes"
        ike_lifetime = 86400
        ike_mode     = "main"
        ike_pfs      = "group2"
        ike_version  = "ikev2"
        local_id     = "tunnel-2-local"
        psk          = "tunnel_2_pre_shared_key"
        remote_id    = "203.0.113.2"
      }
      tunnel_ipsec_config = [
        {
          ipsec_auth_alg = "sha1"
          ipsec_enc_alg  = "aes"
          ipsec_lifetime = 86400
          ipsec_pfs      = "group2"
        }
      ]
    }
  ]

  transit_router_vpn_attachment_name        = "tr-vpn-attachment-dual"
  transit_router_vpn_attachment_description = "带双隧道的转发路由器 VPN 连接"
  auto_publish_route_enabled                = true

  # 路由表关联和传播
  cen_tr_route_table_association_enabled  = true
  cen_tr_route_table_propagation_enabled  = true
  cen_tr_route_table_id                   = "vtb-xxxxxxxxxxxxx"

  ipsec_connection_resource_group_id = "rg-xxxxxxxxxxxxx"
  ipsec_connection_tags = {
    Environment = "production"
    Project     = "landing-zone"
    Type        = "ipsec-connection"
  }

  transit_router_vpn_attachment_tags = {
    Environment = "production"
    Project     = "landing-zone"
    Type        = "transit-router-attachment"
  }
}
```

### 使用自动生成 PSK 的双隧道 VPN 连接

```hcl
module "vpn_attachment_auto_psk" {
  source = "./components/network/cen-vpn-connection"

  cen_instance_id   = "cen-xxxxxxxxxxxxx"
  transit_router_id = "tr-xxxxxxxxxxxxx"
  
  customer_gateways = [
    {
      ip_address  = "203.0.113.1"
      asn         = "65001"
      name        = "本地网关-1"
      description = "主 VPN 网关"
    },
    {
      ip_address  = "203.0.113.2"
      asn         = "65002"
      name        = "本地网关-2"
      description = "备 VPN 网关"
    }
  ]
  
  ipsec_connection_name = "ipsec-connection-auto-psk"
  local_subnet          = "10.0.0.0/16"
  remote_subnet         = "192.168.0.0/16"
  network_type          = "public"

  # 配置隧道时不提供 PSK - PSK 将自动生成
  tunnel_options_specification = [
    {
      customer_gateway_name = "本地网关-1"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 1
      tunnel_ike_config = {
        ike_auth_alg      = "sha1"
        ike_enc_alg       = "aes"
        # 未提供 psk - 将自动生成
        # psk_random_length = 20  # 可选：指定长度（默认：16）
      }
    },
    {
      customer_gateway_name = "本地网关-2"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 2
      tunnel_ike_config = {
        ike_auth_alg      = "sha1"
        ike_enc_alg       = "aes"
        # 未提供 psk - 将自动生成，使用自定义长度
        psk_random_length = 24  # 此隧道的自定义长度
      }
    }
  ]

  transit_router_vpn_attachment_name = "tr-vpn-attachment-auto-psk"
  auto_publish_route_enabled         = true
}

# 部署后，从输出中获取 PSK 值：
# - module.vpn_attachment_auto_psk.tunnel_psks["本地网关-1"]
# - module.vpn_attachment_auto_psk.tunnel_psks["本地网关-2"]
```

## 注意事项

- VPN 网关必须在使用此组件之前单独创建
- 绑定转发路由器场景下，**仅支持双隧道模式**
- VPN 连接（IPsec 连接）以双隧道模式创建，具有自动故障转移功能
- 转发路由器 VPN 连接将 VPN 网关绑定到 CEN 转发路由器
- 可以启用路由自动发布，自动将路由发布到转发路由器路由表
- 名称和描述不能以 `http://` 或 `https://` 开头

### 双隧道要求
- 必须通过 `tunnel_options_specification` 配置恰好 2 个隧道
- 每个隧道必须使用不同的用户网关以实现冗余
- 每个隧道都有自己的 IKE、IPsec 和 BGP 配置
- 隧道索引必须为 1 和 2
- 提供隧道间的自动故障转移，实现高可用性

### 路由模式
路由模式由 `local_subnet` 和 `remote_subnet` 的值决定：

- **目的路由模式**：将 `local_subnet` 和 `remote_subnet` 都设置为 `0.0.0.0/0`
  - 所有流量通过 VPN 隧道路由
  - 适用于所有流量都需要通过 VPN 的场景

- **感兴趣流模式（受保护数据流）**：将两者都设置为具体的 CIDR 地址段
  - 示例：`local_subnet = "10.0.0.0/16,172.16.0.0/16"`，`remote_subnet = "192.168.0.0/16"`
  - 只有匹配这些 CIDR 地址段的流量才会通过 VPN 路由
  - 更安全，对 VPN 流量有更精细的控制
  - 多个网段之间用半角逗号（,）分隔

### BGP 配置
- 通过设置 `enable_tunnels_bgp = true` 启用隧道的 BGP
- **重要**：当 `enable_tunnels_bgp` 为 true 时，必须为 `tunnel_options_specification` 中的每个隧道配置 `tunnel_bgp_config`
- `local_asn` 在两个隧道间共享，通过 `tunnels_bgp_local_asn` 全局配置（默认值：45104）
- 每个隧道需要配置各自独立的 `local_bgp_ip` 和 `tunnel_cidr`（两个隧道使用 169.254.0.0/16 范围内的不同 /30 子网）

### 路由表关联和路由学习
- **路由表关联**：将转发路由器 VPN 连接关联到指定的路由表
  - 通过 `cen_tr_route_table_association_enabled = true` 启用
  - 需要指定 `cen_tr_route_table_id`
  - 允许连接根据路由表条目转发流量

- **路由表传播（路由学习）**：启用从 VPN 到转发路由器的自动路由学习
  - 通过 `cen_tr_route_table_propagation_enabled = true` 启用
  - 需要指定 `cen_tr_route_table_id`
  - 自动将 VPN 路由传播到指定的路由表
  - 适用于使用 BGP 的动态路由场景

### PSK（预共享密钥）自动生成
- 如果在 `tunnel_ike_config` 中未提供 `psk`，将自动生成随机 PSK
- 自动生成的 PSK 长度可通过 `psk_random_length` 配置（默认值：16，范围：1-100）
- 自动生成的 PSK 支持数字、大小写英文字母及特殊字符：`~`!@#$%^&*()_-+={}[]\|;:',.<>/?`（不能包含空格）
- 用户提供的和自动生成的 PSK 都可在 `tunnel_psks` 输出中获取
- **重要**：部署后，请从输出中获取 PSK 值并配置到本地 VPN 设备上
