<div align="right">

**中文** | [English](README.md)

</div>

# VPC 模块

该模块用于创建和管理阿里云专有网络（VPC）资源，包括 VPC、交换机（VSwitch）和可选的网络 ACL 配置。

## 功能特性

- 创建 VPC，支持 IPv4 和可选的 IPv6
- 在多个可用区创建多个交换机
- 可选的网络 ACL，支持入站和出站规则
- 支持 IPAM（IP 地址管理器）集成
- 配置用户自定义 CIDR 块
- 支持资源组分配

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
| [alicloud_vpc.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource | 专有网络 |
| [alicloud_vswitch.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource | 交换机（一个或多个） |
| [alicloud_network_acl.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/network_acl) | resource | 网络 ACL（可选） |
| [alicloud_route_tables.system_route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/route_tables) | data source | 系统路由表查询 |

## 使用方法

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "production-vpc"
  vpc_cidr        = "192.168.0.0/16"
  vpc_description = "Production VPC"
  
  vswitches = [
    {
      cidr_block   = "192.168.1.0/24"
      zone_id      = "cn-hangzhou-h"
      vswitch_name = "vswitch-1"
    },
    {
      cidr_block   = "192.168.2.0/24"
      zone_id      = "cn-hangzhou-i"
      vswitch_name = "vswitch-2"
    }
  ]
  
  enable_acl = true
  acl_name   = "production-acl"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `vpc_name` | VPC 名称 | `string` | `null` | 否 | 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `vpc_cidr` | VPC 的 CIDR 块 | `string` | `null` | 否 | 有效的 IPv4 CIDR 块（如 192.168.0.0/16） |
| `vpc_description` | VPC 描述 | `string` | `null` | 否 | 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `enable_ipv6` | 是否启用 IPv6 | `bool` | `false` | 否 | - |
| `ipv6_isp` | IPv6 CIDR 块类型 | `string` | `"BGP"` | 否 | 必须为：`BGP`、`ChinaMobile`、`ChinaUnicom`、`ChinaTelecom` |
| `resource_group_id` | 资源组 ID | `string` | `null` | 否 | - |
| `user_cidrs` | 用户 CIDR 块列表 | `list(string)` | `null` | 否 | 最多 3 个 CIDR 块 |
| `ipv4_cidr_mask` | 从 IPAM 池按掩码分配 VPC | `number` | `null` | 否 | 0-32（如 16 表示 /16） |
| `ipv4_ipam_pool_id` | IPv4 的 IPAM 池 ID | `string` | `null` | 否 | - |
| `ipv6_cidr_block` | IPv6 CIDR 块 | `string` | `null` | 否 | 当 `enable_ipv6 = true` 时必填 |
| `vpc_tags` | VPC 标签 | `map(string)` | `{}` | 否 | - |
| `vswitches` | 交换机列表 | `list(object)` | `[]` | 否 | 见下方交换机对象结构 |
| `enable_acl` | 是否启用 VPC 网络 ACL | `bool` | `false` | 否 | - |
| `acl_name` | 网络 ACL 名称 | `string` | `null` | 否 | 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `acl_description` | 网络 ACL 描述 | `string` | `null` | 否 | 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `acl_tags` | 网络 ACL 标签 | `map(string)` | `{}` | 否 | - |
| `ingress_acl_entries` | 入站 ACL 条目列表 | `list(object)` | `[]` | 否 | 见下方 ACL 条目结构 |
| `egress_acl_entries` | 出站 ACL 条目列表 | `list(object)` | `[]` | 否 | 见下方 ACL 条目结构 |

### 交换机对象结构

`vswitches` 中每个交换机对象的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `cidr_block` | `string` | - | 是 | 交换机的 CIDR 块 | 有效的 IPv4 CIDR 块（如 192.168.1.0/24） |
| `zone_id` | `string` | - | 是 | 可用区 ID | - |
| `vswitch_name` | `string` | `null` | 否 | 交换机名称 | - |
| `description` | `string` | `null` | 否 | 交换机描述 | - |
| `enable_ipv6` | `bool` | `null` | 否 | 是否启用 IPv6 | - |
| `ipv6_cidr_block_mask` | `number` | `null` | 否 | IPv6 CIDR 块掩码 | - |
| `tags` | `map(string)` | `null` | 否 | 交换机标签 | 如果为 null 或空，则继承 VPC 标签 |

### ACL 条目对象结构

`ingress_acl_entries` 或 `egress_acl_entries` 中每个条目的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `protocol` | `string` | - | 是 | 协议类型 | 必须为：`icmp`、`gre`、`tcp`、`udp`、`all` |
| `port` | `string` | - | 是 | 端口范围 | `-1/-1` 用于 all/icmp/gre，或 `1-65535/1-65535` 用于 tcp/udp |
| `source_cidr_ip` | `string` | - | 是（入站） | 源 CIDR IP | - |
| `destination_cidr_ip` | `string` | - | 是（出站） | 目标 CIDR IP | - |
| `policy` | `string` | `"accept"` | 否 | 策略动作 | 必须为：`accept` 或 `drop` |
| `description` | `string` | `null` | 否 | 条目描述 | 1-256 个字符，不能以 http:// 或 https:// 开头 |
| `network_acl_entry_name` | `string` | `null` | 否 | 条目名称 | 1-128 个字符，不能以 http:// 或 https:// 开头 |
| `ip_version` | `string` | `"IPV4"` | 否 | IP 版本 | 必须为：`IPV4` 或 `IPV6` |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `vpc_id` | VPC ID |
| `route_table_id` | VPC 路由表 ID |
| `system_route_table_id` | 系统路由表 ID |
| `vswitch_ids` | 所有交换机 ID 列表 |
| `vswitchs` | 所有交换机详细信息列表（包含 id、cidr_block、zone_id、vswitch_name、description、enable_ipv6、ipv6_cidr_block、status、tags） |
| `network_acl_id` | VPC ACL ID（如果启用） |

## 使用示例

### 基础 VPC 和交换机

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "my-vpc"
  vpc_cidr        = "10.0.0.0/16"
  vpc_description = "My VPC"
  
  vswitches = [
    {
      cidr_block   = "10.0.1.0/24"
      zone_id      = "cn-hangzhou-h"
      vswitch_name = "vswitch-zone-h"
    },
    {
      cidr_block   = "10.0.2.0/24"
      zone_id      = "cn-hangzhou-i"
      vswitch_name = "vswitch-zone-i"
    }
  ]
}
```

### 带网络 ACL 的 VPC

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "secure-vpc"
  vpc_cidr        = "172.16.0.0/16"
  
  vswitches = [
    {
      cidr_block = "172.16.1.0/24"
      zone_id    = "cn-hangzhou-h"
    }
  ]
  
  enable_acl = true
  acl_name   = "secure-acl"
  
  ingress_acl_entries = [
    {
      protocol       = "tcp"
      port           = "80/80"
      source_cidr_ip = "0.0.0.0/0"
      policy         = "accept"
      description    = "Allow HTTP"
    },
    {
      protocol       = "tcp"
      port           = "443/443"
      source_cidr_ip = "0.0.0.0/0"
      policy         = "accept"
      description    = "Allow HTTPS"
    }
  ]
  
  egress_acl_entries = [
    {
      protocol            = "all"
      port                = "-1/-1"
      destination_cidr_ip = "0.0.0.0/0"
      policy              = "accept"
      description         = "Allow all outbound"
    }
  ]
}
```

### 支持 IPv6 的 VPC

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name        = "ipv6-vpc"
  vpc_cidr        = "192.168.0.0/16"
  enable_ipv6     = true
  ipv6_isp        = "BGP"
  ipv6_cidr_block = "2408:4004:cc0::/56"
  
  vswitches = [
    {
      cidr_block      = "192.168.1.0/24"
      zone_id         = "cn-hangzhou-h"
      enable_ipv6     = true
      ipv6_cidr_block_mask = 64
    }
  ]
}
```

### 使用 IPAM 的 VPC

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name         = "ipam-vpc"
  ipv4_ipam_pool_id = "ipam-pool-123456"
  ipv4_cidr_mask    = 16
  
  vswitches = [
    {
      cidr_block = "10.0.1.0/24"
      zone_id    = "cn-hangzhou-h"
    }
  ]
}
```

## 注意事项

- VPC CIDR 块必须是有效的 IPv4 CIDR（如 192.168.0.0/16）
- 交换机 CIDR 块必须在 VPC CIDR 块范围内
- 当 `enable_acl = true` 时，所有交换机自动关联到 ACL
- 如果未指定 ACL 名称，默认为 `{vpc_name}-acl`
- 如果未指定交换机标签，则继承 VPC 标签
- IPv6 需要 `enable_ipv6 = true` 并设置 `ipv6_cidr_block`
- IPAM 集成需要 `ipv4_ipam_pool_id` 以及 `vpc_cidr` 或 `ipv4_cidr_mask`

