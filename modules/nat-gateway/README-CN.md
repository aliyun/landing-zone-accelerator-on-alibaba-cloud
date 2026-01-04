<div align="right">

**中文** | [English](README.md)

</div>

# NAT Gateway 模块

该模块用于创建和管理阿里云 NAT 网关，包含 SNAT 条目以提供出站互联网访问。

## 功能特性

- 创建增强型 NAT 网关（公网或私网类型）
- 将 EIP 关联到 NAT 网关
- 创建 SNAT 条目用于源网络地址转换
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
| [alicloud_eip_addresses.associated_eips](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/eip_addresses) | data source | 关联的 EIP 地址查询（当 use_all_associated_eips = true 时） |
| [alicloud_nat_gateway.nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nat_gateway) | resource | NAT 网关实例 |
| [alicloud_eip_association.eip_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/eip_association) | resource | EIP 与 NAT 网关的关联 |
| [alicloud_snat_entry.snat_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/snat_entry) | resource | 出站流量的 SNAT 条目 |

## 使用方法

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-1234567890abcdef0"
  vswitch_id      = "vsw-1234567890abcdef0"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-1234567890abcdef0"]
  
  snat_entries = [
    {
      source_vswitch_id = "vsw-1234567890abcdef0"
      use_all_associated_eips = true
    }
  ]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `vpc_id` | NAT 网关的 VPC ID | `string` | `""` | 否 | - |
| `vswitch_id` | NAT 网关的交换机 ID | `string` | - | 是 | - |
| `nat_gateway_name` | NAT 网关名称 | `string` | `null` | 否 | 2-128 个字符，字母数字或连字符，不能以连字符开头或结尾，不能以 http:// 或 https:// 开头 |
| `tags` | NAT 网关标签 | `map(string)` | `null` | 否 | - |
| `association_eip_ids` | 要关联到 NAT 网关的 EIP 实例 ID 列表 | `list(string)` | `[]` | 否 | - |
| `network_type` | NAT 网关类型 | `string` | `"internet"` | 否 | 必须为：`internet` 或 `intranet` |
| `payment_type` | NAT 网关计费方式 | `string` | `"PayAsYouGo"` | 否 | 必须为：`PayAsYouGo` 或 `Subscription` |
| `period` | 包年包月时长（月） | `number` | `null` | 否 | 当 `payment_type = "Subscription"` 时必填 |
| `snat_entries` | 要创建的 SNAT 条目列表 | `list(object)` | `[]` | 否 | 见下方 SNAT 条目结构 |

### SNAT 条目对象结构

`snat_entries` 中每个 SNAT 条目的结构如下：

| 字段 | 类型 | 默认值 | 必填 | 说明 | 限制条件 |
|------|------|--------|------|------|----------|
| `source_cidr` | `string` | `null` | 否* | 源 CIDR 块 | 有效 CIDR 块。必须提供 `source_cidr` 或 `source_vswitch_id` 之一，但不能同时提供 |
| `source_vswitch_id` | `string` | `null` | 否* | 源交换机 ID | 必须提供 `source_cidr` 或 `source_vswitch_id` 之一，但不能同时提供 |
| `snat_ips` | `list(string)` | `[]` | 否 | SNAT IP 地址列表 | 当 `use_all_associated_eips = false` 时必填，必须是有效的 IP 地址 |
| `use_all_associated_eips` | `bool` | `false` | 否 | 是否使用所有关联的 EIP | - |
| `snat_entry_name` | `string` | `null` | 否 | SNAT 条目名称 | 2-128 个字符，必须以字母开头，不能以 http:// 或 https:// 开头 |
| `eip_affinity` | `number` | `0` | 否 | EIP 亲和性 | 必须为 0 或 1 |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `nat_gateway_id` | NAT 网关 ID |
| `nat_gateway_snat_entry_ids` | SNAT 条目 ID 列表 |

## 使用示例

### 基础 NAT 网关

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "my-nat-gateway"
  
  association_eip_ids = ["eip-123456"]
}
```

### 带交换机 SNAT 条目的 NAT 网关

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-123456", "eip-789012"]
  
  snat_entries = [
    {
      source_vswitch_id = "vsw-xyz789"
      use_all_associated_eips = true
      snat_entry_name = "vswitch-snat"
    }
  ]
}
```

### 带 CIDR SNAT 条目的 NAT 网关

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "production-nat"
  
  association_eip_ids = ["eip-123456"]
  
  snat_entries = [
    {
      source_cidr = "192.168.1.0/24"
      snat_ips    = ["47.96.XX.XX"]
      snat_entry_name = "cidr-snat"
    }
  ]
}
```

### 私网 NAT 网关

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  vpc_id          = "vpc-abc123"
  vswitch_id      = "vsw-xyz789"
  nat_gateway_name = "intranet-nat"
  network_type    = "intranet"
}
```

## 注意事项

- 对于 SNAT 条目，必须提供 `source_cidr` 或 `source_vswitch_id` 之一，但不能同时提供
- 当 `use_all_associated_eips = true` 时，所有关联的 EIP 都用于 SNAT
- 当 `use_all_associated_eips = false` 时，必须提供有效的 IP 地址列表 `snat_ips`
- `eip_affinity` 控制 EIP 亲和性：0 表示无亲和性，1 表示有亲和性
- SNAT 条目名称必须以字母开头，不能以 http:// 或 https:// 开头

