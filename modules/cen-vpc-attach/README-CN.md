<div align="right">

**中文** | [English](README.md)

</div>

# CEN VPC Attachment 模块

该模块用于将 VPC 连接到阿里云云企业网（CEN）转发路由器，实现跨 VPC 和跨地域的网络连接。

## 功能特性

- 将 VPC 连接到 CEN 转发路由器
- 支持跨账号 VPC 连接（需要显式配置授权）
- 配置多个交换机（至少2个）以实现高可用
- 支持路由表关联和传播
- 在 VPC 系统路由表中创建路由条目，使用转发路由器连接作为下一跳
- 自动创建服务关联角色（如需要）

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
| alicloud.vpc | >= 1.267.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_account.cen_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | CEN 账号信息 |
| [alicloud_account.vpc_account](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/account) | data source | VPC 账号信息 |
| [alicloud_resource_manager_service_linked_role.cen_service_role](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/resource_manager_service_linked_role) | resource | CEN 服务关联角色 |
| [alicloud_cen_instance_grant.cen_instance_grant](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_instance_grant) | resource | 跨账号 CEN 实例授权 |
| [alicloud_cen_transit_router_vpc_attachment.vpc_attachment](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_vpc_attachment) | resource | VPC 到转发路由器的连接 |
| [alicloud_cen_transit_router_route_table_association.route_table_association](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_association) | resource | 路由表关联（可选） |
| [alicloud_cen_transit_router_route_table_propagation.route_table_propagation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_transit_router_route_table_propagation) | resource | 路由表传播（可选） |
| [alicloud_route_entry.vpc_route_entry](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/route_entry) | resource | VPC 路由条目，使用转发路由器连接作为下一跳（可选） |

## 使用方法

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-jhwbspfj5lnxxxxxxxx"
  cen_tr_id = "tr-uf6e6h5vv5eigxxxxxx"
  vpc_id                = "vpc-uf6v10ktt3tnxxxxxxxx"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-uf62k55n02gqxxxxxxxx"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-uf62w4c2ofg6xxxxxxxx"
      zone_id    = "cn-hangzhou-i"
    }
  ]
  
  cen_tr_route_table_association_enabled = true
  cen_tr_route_table_propagation_enabled = true
  cen_tr_route_table_id    = "vtb-uf6edldu59p7vyxxxxx"
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 | 限制条件 |
|--------|------|------|--------|------|----------|
| `cen_instance_id` | 要连接的 CEN 实例 ID | `string` | - | 是 | - |
| `cen_tr_id` | 要创建 VPC 连接的 CEN 转发路由器 ID | `string` | - | 是 | - |
| `vpc_id` | 要连接到 CEN 转发路由器的 VPC ID | `string` | - | 是 | - |
| `vpc_attachment_vswitches` | VPC 连接的交换机信息列表 | `list(object)` | - | 是 | 至少需要2个交换机。每个对象必须包含 `vswitch_id`。`zone_id` 为可选，如果不提供将自动查询 |
| `cen_tr_route_table_id` | 用于关联和传播的转发路由器路由表 ID | `string` | `""` | 否 | 启用路由表功能时需要 |
| `cen_tr_attachment_name` | 转发路由器 VPC 连接名称 | `string` | `""` | 否 | 2-128 个字符，只能包含字母/数字/下划线/连字符，必须以字母开头 |
| `cen_tr_attachment_description` | 转发路由器 VPC 连接描述 | `string` | `""` | 否 | 2-256 个字符，必须以字母开头，不能以 http:// 或 https:// 开头 |
| `cen_tr_route_table_association_enabled` | 是否启用路由表关联 | `bool` | `false` | 否 | - |
| `cen_tr_route_table_propagation_enabled` | 是否启用路由表传播 | `bool` | `false` | 否 | - |
| `cen_tr_attachment_auto_publish_route_enabled` | 是否启用企业版转发路由器自动向 VPC 发布路由 | `bool` | `false` | 否 | - |
| `cen_tr_attachment_force_delete` | 是否强制删除 VPC 连接。为 true 时，默认删除所有相关依赖 | `bool` | `false` | 否 | - |
| `cen_tr_attachment_payment_type` | 计费方式 | `string` | `"PayAsYouGo"` | 否 | 必须为 PayAsYouGo |
| `cen_tr_attachment_tags` | VPC 连接资源的标签 | `map(string)` | `{}` | 否 | - |
| `cen_tr_attachment_options` | VPC 连接的 TransitRouterVpcAttachmentOptions | `map(string)` | `{}` | 否 | - |
| `cen_tr_attachment_resource_type` | 转发路由器 VPC 连接的资源类型 | `string` | `"VPC"` | 否 | 必须为 VPC |
| `vpc_route_table_id` | 要添加路由条目的 VPC 路由表 ID | `string` | `null` | 否 | 当 vpc_route_entries 不为空时必填 |
| `vpc_route_entries` | 要添加到 VPC 路由表的路由条目列表 | `list(object)` | `[]` | 否 | 所有条目使用转发路由器连接作为下一跳（nexthop_type 固定为 Attachment） |
| `cen_service_linked_role_exists` | CEN 服务关联角色是否已存在。如果为 true，模块将不会创建服务关联角色 | `bool` | `false` | 否 | - |
| `create_cen_instance_grant` | 是否为跨账号连接创建 CEN 实例授权。**当 CEN 和 VPC 在不同账号时，必须设置为 `true`；在同一账号时，必须设置为 `false`。**  | `bool` | `false` | 否 | - |

### 交换机对象结构

`vpc_attachment_vswitches` 列表中的每个元素必须具有以下结构：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `vswitch_id` | `string` | 是 | 交换机 ID |
| `zone_id` | `string` | 否 | 交换机所在的可用区 ID。如果不提供，将使用交换机 ID 自动查询 |

### 路由条目对象结构

`vpc_route_entries` 列表中的每个元素必须具有以下结构：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `destination_cidrblock` | `string` | 是 | 路由条目的目标 CIDR 网段（有效的 IPv4 CIDR） |
| `name` | `string` | 否 | 路由条目名称（1-128 个字符，不能以 http:// 或 https:// 开头） |
| `description` | `string` | 否 | 路由条目描述（1-256 个字符，不能以 http:// 或 https:// 开头） |

**注意**：所有路由条目将自动使用转发路由器连接作为下一跳（`nexthop_type` 固定为 `Attachment`）。

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `transit_router_attachment_id` | CEN 转发路由器 VPC 连接 ID |
| `route_table_association_id` | 路由表关联资源 ID（如果启用） |
| `route_table_propagation_id` | 路由表传播资源 ID（如果启用） |
| `vpc_route_entry_ids` | 为转发路由器连接创建的 VPC 路由条目 ID 列表 |

## 使用示例

### 基础 VPC 连接

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    }
  ]

  # 替代方案：可以省略 zone_id，将自动查询
  # vpc_attachment_vswitches = [
  #   {
  #     vswitch_id = "vsw-primary"
  #   },
  #   {
  #     vswitch_id = "vsw-secondary"
  #   }
  # ]
}
```

### 带路由表功能

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    },
    {
      vswitch_id = "vsw-tertiary"
      zone_id    = "cn-hangzhou-j"
    }
  ]
  
  cen_tr_route_table_id    = "vtb-route-table"
  cen_tr_route_table_association_enabled  = true
  cen_tr_route_table_propagation_enabled  = true
  
  cen_tr_attachment_name        = "production-vpc-attachment"
  cen_tr_attachment_description = "Production VPC attachment to CEN"
}
```

### 使用 VPC 路由条目

```hcl
module "cen_vpc_attach" {
  source = "./modules/cen-vpc-attach"

  providers = {
    alicloud.cen_tr = alicloud.cen_tr
    alicloud.vpc    = alicloud.vpc
  }

  cen_instance_id       = "cen-abc123"
  cen_tr_id = "tr-xyz789"
  vpc_id                = "vpc-123456"
  
  vpc_attachment_vswitches = [
    {
      vswitch_id = "vsw-primary"
      zone_id    = "cn-hangzhou-h"
    },
    {
      vswitch_id = "vsw-secondary"
      zone_id    = "cn-hangzhou-i"
    }
  ]
  
  # 路由条目将使用转发路由器连接作为下一跳
  vpc_route_table_id = "vtb-uf6edldu59p7vyxxxxx"
  vpc_route_entries = [
    {
      destination_cidrblock = "10.10.0.0/14"
      name                  = "route-to-tr"
      description           = "路由到转发路由器"
    }
  ]
}
```

## 注意事项

- 需要两个 provider：`alicloud.cen_tr` 用于 CEN 资源，`alicloud.vpc` 用于 VPC 资源
- **跨账号连接**：当 CEN 和 VPC 在不同账号时，必须设置 `create_cen_instance_grant = true` 来创建授权。当它们在同一账号时，必须设置为 `false`。模块会验证您的配置，如果配置不匹配会报错。
- 至少需要2个交换机，且应位于不同的可用区以实现高可用
- 路由表关联和传播需要指定 `cen_tr_route_table_id`
- VPC 路由条目需要指定 `vpc_route_table_id`（当 `vpc_route_entries` 不为空时）
- VPC 路由条目将添加到指定的 VPC 路由表，使用转发路由器连接作为下一跳（`nexthop_type` 固定为 `Attachment`）
- 连接创建可能需要最多 15 分钟，删除可能需要最多 30 分钟

