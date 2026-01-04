<div align="right">

**中文** | [English](README.md)

</div>

# CEN VPC Attachment 模块

该模块用于将 VPC 连接到阿里云云企业网（CEN）转发路由器，实现跨 VPC 和跨地域的网络连接。

## 功能特性

- 将 VPC 连接到 CEN 转发路由器
- 支持跨账号 VPC 连接（自动处理授权）
- 配置主备交换机以实现高可用
- 支持路由表关联和传播
- 自动创建服务关联角色（如需要）

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
| alicloud.vpc | >= 1.262.1 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.cen_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | CEN 账号信息 |
| [alicloud_account.vpc_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | VPC 账号信息 |
| [alicloud_ram_roles.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/ram_roles) | data source | CEN 服务关联角色查询 |
| [alicloud_resource_manager_service_linked_role.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | CEN 服务关联角色 |
| [alicloud_cen_instance_grant.cen_instance_grant](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance_grant) | resource | 跨账号 CEN 实例授权 |
| [alicloud_cen_transit_router_vpc_attachment.vpc_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource | VPC 到转发路由器的连接 |
| [alicloud_cen_transit_router_route_table_association.route_table_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | 路由表关联（可选） |
| [alicloud_cen_transit_router_route_table_propagation.route_table_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | 路由表传播（可选） |

## 使用方法

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-1234567890abcdef0"
  cen_transit_router_id = "tr-1234567890abcdef0"
  vpc_id                = "vpc-1234567890abcdef0"
  
  primary_vswitch = {
    vswitch_id = "vsw-abc123"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-xyz789"
    zone_id    = "cn-hangzhou-i"
  }
  
  route_table_association_enabled = true
  route_table_propagation_enabled = true
  transit_router_route_table_id   = "vtb-1234567890abcdef0"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | 要连接的 CEN 实例 ID | `string` | - | 是 | - |
| `cen_transit_router_id` | 要创建 VPC 连接的 CEN 转发路由器 ID | `string` | - | 是 | - |
| `vpc_id` | 要连接到 CEN 转发路由器的 VPC ID | `string` | - | 是 | - |
| `primary_vswitch` | VPC 连接的主交换机信息 | `object` | - | 是 | 必须包含 `vswitch_id` 和 `zone_id` |
| `secondary_vswitch` | VPC 连接的备交换机信息 | `object` | - | 是 | 必须包含 `vswitch_id` 和 `zone_id` |
| `transit_router_route_table_id` | 用于关联和传播的转发路由器路由表 ID | `string` | `""` | 否 | 启用路由表功能时需要 |
| `transit_router_attachment_name` | 转发路由器 VPC 连接名称 | `string` | `""` | 否 | - |
| `transit_router_attachment_description` | 转发路由器 VPC 连接描述 | `string` | `""` | 否 | - |
| `route_table_association_enabled` | 是否启用路由表关联 | `bool` | `false` | 否 | - |
| `route_table_propagation_enabled` | 是否启用路由表传播 | `bool` | `false` | 否 | - |

### 交换机对象结构

`primary_vswitch` 和 `secondary_vswitch` 必须具有以下结构：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `vswitch_id` | `string` | 是 | 交换机 ID |
| `zone_id` | `string` | 是 | 交换机所在的可用区 ID |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `transit_router_attachment_id` | CEN 转发路由器 VPC 连接 ID |
| `route_table_association_id` | 路由表关联资源 ID（如果启用） |
| `route_table_propagation_id` | 路由表传播资源 ID（如果启用） |

## 使用示例

### 基础 VPC 连接

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-abc123"
  cen_transit_router_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  primary_vswitch = {
    vswitch_id = "vsw-primary"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-secondary"
    zone_id    = "cn-hangzhou-i"
  }
}
```

### 带路由表功能

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  cen_instance_id       = "cen-abc123"
  cen_transit_router_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  primary_vswitch = {
    vswitch_id = "vsw-primary"
    zone_id    = "cn-hangzhou-h"
  }
  
  secondary_vswitch = {
    vswitch_id = "vsw-secondary"
    zone_id    = "cn-hangzhou-i"
  }
  
  transit_router_route_table_id   = "vtb-route-table"
  route_table_association_enabled = true
  route_table_propagation_enabled = true
  
  transit_router_attachment_name        = "production-vpc-attachment"
  transit_router_attachment_description = "Production VPC attachment to CEN"
}
```

## 注意事项

- 需要两个 provider：`alicloud.cen` 用于 CEN 资源，`alicloud.vpc` 用于 VPC 资源
- 当 CEN 和 VPC 在不同账号时，自动处理跨账号连接
- 主备交换机应位于不同的可用区以实现高可用
- 路由表关联和传播需要指定 `transit_router_route_table_id`
- 连接创建可能需要最多 15 分钟，删除可能需要最多 30 分钟

