<div align="right">

**中文** | [English](README.md)

</div>

# DMZ VPC Egress 模块

该模块通过 CEN 转发路由器和 NAT 网关配置从 VPC 通过 DMZ VPC 的互联网出站路由。

## 功能特性

- 配置 VPC 路由表，将互联网流量路由到转发路由器
- 配置 DMZ VPC 路由表，将 VPC CIDR 路由到转发路由器
- 配置 NAT 网关 SNAT 条目用于互联网出站
- 如果未指定，自动发现系统路由表
- 支持多个 EIP 地址用于 SNAT

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.267.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.267.0 |
| alicloud.dmz | >= 1.267.0 |
| alicloud.vpc | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_route_tables.route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/route_tables) | data source | VPC 路由表查询（用于系统路由表） |
| [alicloud_route_tables.dmz_route_table](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/route_tables) | data source | DMZ VPC 路由表查询（用于系统路由表） |
| [alicloud_nat_gateways.nat_gateway](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/nat_gateways) | data source | NAT 网关查询（用于 EIP 地址和 SNAT 表 ID） |
| [alicloud_route_entry.route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | VPC 路由表中的路由条目（0.0.0.0/0 -> 转发路由器） |
| [alicloud_route_entry.dmz_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | DMZ VPC 路由表中的路由条目（VPC CIDR -> 转发路由器） |
| [alicloud_snat_entry.snat](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/snat_entry) | resource | DMZ NAT 网关中的 SNAT 条目 |

## 使用方法

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-uf6v10ktt3tnxxxxxxxx"
  vpc_tr_attachment_id = "tr-attach-2ze0xxxxxxxxxxxxxxxx"
  vpc_cidr_block       = "192.168.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-2ze0xxxxxxxxxxxxxxxx"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-2ze0xxxxxxxxxxxxxxxx"
  dmz_nat_gateway_id         = "ngw-uf6hg6eaaqz70xxxxxx"
  dmz_eip_addresses         = ["47.96.XX.XX", "47.96.XX.YY"]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `vpc_id` | 需要互联网出站的 VPC ID | `string` | - | 是 | - |
| `vpc_route_table_id` | VPC 中的路由表 ID | `string` | `null` | 否 | 如果未指定，将使用系统路由表 |
| `vpc_tr_attachment_id` | VPC 转发路由器连接 ID | `string` | - | 是 | - |
| `vpc_route_entry_destination_cidrblock` | VPC 路由条目的目标 CIDR 块 | `string` | `"0.0.0.0/0"` | 否 | 有效的 IPv4 CIDR 块。默认为 0.0.0.0/0 用于互联网出站 |
| `vpc_cidr_block` | 从 VPC 路由到 DMZ 的 CIDR 块 | `string` | - | 是 | 有效的 IPv4 CIDR 块 |
| `dmz_vpc_id` | DMZ VPC ID | `string` | - | 是 | - |
| `dmz_route_table_id` | DMZ VPC 中的路由表 ID | `string` | `null` | 否 | 如果未指定，将使用系统路由表 |
| `dmz_vpc_tr_attachment_id` | DMZ VPC 转发路由器连接 ID | `string` | - | 是 | - |
| `dmz_nat_gateway_id` | DMZ VPC 中的 NAT 网关 ID | `string` | - | 是 | - |
| `dmz_snat_table_id` | SNAT 表 ID | `string` | `null` | 否 | 如果未指定，将使用第一个 SNAT 表 |
| `dmz_eip_addresses` | 用于 SNAT 的 EIP 地址列表 | `list(string)` | `[]` | 否 | 有效的 IPv4 地址。如果为空，使用与 NAT 网关关联的 EIP |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `nat_gateway_snat_entry_id` | SNAT 条目 ID |
| `route_table_id` | 使用的 VPC 路由表 ID |
| `dmz_route_table_id` | 使用的 DMZ VPC 路由表 ID |
| `snat_table_id` | 使用的 SNAT 表 ID |
| `eip_addresses` | 用于 SNAT 的 EIP 地址 |

## 使用示例

### 基础 DMZ 出站配置

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  dmz_eip_addresses         = ["47.96.1.1", "47.96.1.2"]
}
```

### 使用系统路由表

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  # vpc_route_table_id 和 dmz_route_table_id 未指定 - 将使用系统路由表
}
```

### 从 NAT 网关自动发现 EIP

```hcl
module "dmz_vpc_egress" {
  source = "./modules/dmz-vpc-egress"

  vpc_id                = "vpc-abc123"
  vpc_tr_attachment_id = "tr-attach-xyz789"
  vpc_cidr_block       = "10.0.0.0/16"
  
  dmz_vpc_id                = "vpc-dmz-abc123"
  dmz_vpc_tr_attachment_id  = "tr-attach-dmz-xyz789"
  dmz_nat_gateway_id         = "ngw-abc123"
  # dmz_eip_addresses 未指定 - 将使用与 NAT 网关关联的 EIP
}
```

## 注意事项

- 需要两个 provider：`alicloud.vpc` 用于 VPC 资源，`alicloud.dmz` 用于 DMZ VPC 资源
- 如果未指定路由表 ID，将自动发现系统路由表
- 如果未指定 EIP 地址，将从 NAT 网关自动发现
- 如果未指定 SNAT 表 ID，将从 NAT 网关自动发现
- 模块将 VPC 的所有互联网流量（0.0.0.0/0）路由到转发路由器
- 模块将 VPC CIDR 从 DMZ VPC 路由到转发路由器以处理返回流量
- SNAT 条目允许 VPC 资源通过 DMZ NAT 网关访问互联网

