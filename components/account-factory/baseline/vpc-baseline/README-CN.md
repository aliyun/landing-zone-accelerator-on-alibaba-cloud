<div align="right">

**中文** | [English](README.md)

</div>

## 基线 VPC 组件

该组件用于在账号基线中批量创建多个 VPC（通过 `modules/vpc`），并可选：

- 将多个 VPC Attach 到 CEN 转发路由器（通过 `modules/cen-vpc-attach`）

## 功能特性

- 为账号基线批量创建多个 VPC、VSwitch 及可选 Network ACL
- 可选：将所有 VPC Attach 到 CEN 转发路由器，共享通用 CEN 配置
- 每个 VPC 可以有自己的 CEN attachment 设置，同时共享通用的 CEN 配置

## 前置要求

| 名称      | 版本      |
|-----------|-----------|
| terraform | >= 1.2   |
| alicloud  | >= 1.267.0 |

## Providers

| 名称         | 版本      |
|--------------|-----------|
| alicloud      | >= 1.267.0 |
| alicloud.vpc  | >= 1.267.0 |
| alicloud.cen_tr | >= 1.267.0 |

该组件要求 `alicloud` provider 暴露以下 **configuration aliases**（见 `versions.tf` 以及 stack 级 provider 配置）：

- `alicloud.vpc` —— 用于 VPC 资源
- `alicloud.cen_tr` —— 用于 CEN / 转发路由器 Attach 相关资源

如果在纯 Terraform 工程中直接引用该组件（而不是通过 `tfcomponent.yaml`），需要在根模块中显式定义这些 alias，并在 module 上进行映射，例如：

```hcl
provider "alicloud" {
  alias  = "vpc"
  region = "cn-hangzhou"
}

module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # 通用 CEN 配置（所有 VPC 共享）
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxx"
  cen_tr_id             = "tr-xxxxx"
  cen_tr_route_table_id = "vtb-xxxxx"

  # VPC 网络配置
  vpcs = [
    {
      vpc_name = "VPC-Prod-1"
      vpc_cidr = "10.0.0.0/16"
      vswitches = [
        {
          cidr_block = "10.0.1.0/24"
          zone_id    = "cn-hangzhou-h"
          purpose    = "TR"
        },
        {
          cidr_block = "10.0.2.0/24"
          zone_id    = "cn-hangzhou-i"
          purpose    = "TR"
        },
        {
          cidr_block = "10.0.3.0/24"
          zone_id    = "cn-hangzhou-j"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "To_VPC-Prod-1"
        vpc_route_entries = [
          {
            destination_cidrblock = "0.0.0.0/0"
          }
        ]
      }
    }
  ]
}
```

## 使用示例

### 方法 1: 直接配置

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # 通用 CEN 配置
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  vpcs = [
    {
      vpc_name = "VPC-SH-Prod-App"
      vpc_cidr = "10.220.0.0/16"
      vswitches = [
        {
          vswitch_name = "vsw-sh-prod-app-01"
          vswitch_cidr = "10.220.1.0/24"
          zone_id      = "cn-shanghai-e"
          purpose      = "TR"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "tr-attach-sh-prod-app"
      }
    }
  ]
}
```

### 方法 2: 从目录加载

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # 通用 CEN 配置
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  vpc_dir_path = "./vpcs"
}
```

目录及其子目录中的所有 `.json`、`.yaml` 和 `.yml` 文件将被处理。每个文件必须包含单个 VPC 对象。

**示例 VPC 文件 (YAML) - 单个 VPC 对象:**

```yaml
# vpc-sh-prod-app.yaml
vpc_name: VPC-SH-Prod-App
vpc_cidr: 10.220.0.0/16
vswitches:
  - vswitch_name: vsw-sh-prod-app-01
    vswitch_cidr: 10.220.1.0/24
    zone_id: cn-shanghai-e
    purpose: TR
  - vswitch_name: vsw-sh-prod-app-02
    vswitch_cidr: 10.220.2.0/24
    zone_id: cn-shanghai-f
    purpose: TR
cen_attachment:
  cen_tr_attachment_name: tr-attach-sh-prod-app
```
}
```

### 方法 4: 组合配置

```hcl
module "baseline_vpc_networkings" {
  source = "./components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc
    alicloud.cen_tr = alicloud.cen_tr
  }

  # 通用 CEN 配置
  cen_attachment_enabled = true
  cen_instance_id       = "cen-xxxxxxxxxxxxx"
  cen_tr_id             = "tr-xxxxxxxxxxxxx"
  cen_tr_route_table_id = "vtb-xxxxxxxxxxxxx"

  # 直接配置的 VPC
  vpcs = [
    {
      vpc_name = "VPC-SH-Prod-App"
      vpc_cidr = "10.220.0.0/16"
      vswitches = [
        {
          vswitch_name = "vsw-sh-prod-app-01"
          vswitch_cidr = "10.220.1.0/24"
          zone_id      = "cn-shanghai-e"
          purpose      = "TR"
        }
      ]
      cen_attachment = {
        cen_tr_attachment_name = "tr-attach-sh-prod-app"
      }
    }
  ]

  # 从目录加载更多 VPC（每个文件包含单个 VPC 对象）
  vpc_dir_path = "./vpcs"
}
```

## 输入参数

| 名称 | 描述 | 类型 | 默认值 | 必填 |
|------|------|------|--------|------|
| `cen_attachment_enabled` | 是否为所有 VPC 启用 CEN 转发路由器 attachment | `bool` | `false` | 否 |
| `cen_instance_id` | CEN 实例 ID（所有 VPC 共享） | `string` | `null` | 否 |
| `cen_tr_id` | CEN 转发路由器 ID（所有 VPC 共享） | `string` | `null` | 否 |
| `cen_tr_route_table_id` | CEN 转发路由器路由表 ID（所有 VPC 共享） | `string` | `""` | 否 |
| `cen_service_linked_role_exists` | CEN 服务关联角色是否已存在。如果为 true，模块将不会创建服务关联角色。如果为 false，模块将创建它 | `bool` | `true` | 否 |
| `create_cen_instance_grant` | 是否为跨账号连接创建 CEN 实例授权。**当 CEN 和 VPC 在不同账号时，必须设置为 `true`；在同一账号时，必须设置为 `false`。** 底层模块会根据实际账号 ID 验证此配置 | `bool` | `true` | 否 |
| `vpcs` | VPC 网络配置列表 | `list(object)` | `[]` | 否 |
| `vpc_dir_path` | 包含 VPC 配置文件的目录路径（YAML/JSON）。该目录中的每个文件必须包含单个 VPC 对象。文件将被加载并与 vpcs 合并 | `string` | `null` | 否 |

### vpcs 对象

`vpcs` 列表中的每个 VPC 可以包含以下结构：

| 名称 | 描述 | 类型 | 必填 |
|------|------|------|------|
| `vpc_name` | VPC 名称 | `string` | 是 |
| `vpc_cidr` | VPC CIDR 网段 | `string` | 是 |
| `vpc_description` | VPC 描述 | `string` | 否 |
| `enable_ipv6` | 是否启用 IPv6 | `bool` | 否 |
| `ipv6_isp` | IPv6 CIDR 类型 | `string` | 否 |
| `resource_group_id` | 资源组 ID | `string` | 否 |
| `user_cidrs` | 用户 CIDR 列表 | `list(string)` | 否 |
| `ipv4_cidr_mask` | 从 IPAM 地址池分配 VPC 的掩码 | `number` | 否 |
| `ipv4_ipam_pool_id` | IPAM 地址池 ID | `string` | 否 |
| `ipv6_cidr_block` | VPC 的 IPv6 CIDR 网段 | `string` | 否 |
| `vpc_tags` | VPC 标签 | `map(string)` | 否 |
| `vswitches` | VSwitch 列表 | `list(object)` | 是 |
| `enable_acl` | 是否启用 VPC Network ACL | `bool` | 否 |
| `acl_name` | Network ACL 名称 | `string` | 否 |
| `acl_description` | Network ACL 描述 | `string` | 否 |
| `acl_tags` | Network ACL 标签 | `map(string)` | 否 |
| `ingress_acl_entries` | 入方向 ACL 规则列表 | `list(object)` | 否 |
| `egress_acl_entries` | 出方向 ACL 规则列表 | `list(object)` | 否 |
| `cen_attachment` | VPC 特定的 CEN attachment 配置 | `object` | 否 |

### vswitches 对象

`vswitches` 列表中的每个 vswitch 可以包含以下结构：

| 名称 | 描述 | 类型 | 必填 |
|------|------|------|------|
| `cidr_block` | VSwitch 的 CIDR 网段 | `string` | 是 |
| `zone_id` | VSwitch 所在的可用区 ID | `string` | 是 |
| `vswitch_name` | VSwitch 名称 | `string` | 否 |
| `description` | VSwitch 描述 | `string` | 否 |
| `enable_ipv6` | 是否启用 IPv6 | `bool` | 否 |
| `ipv6_cidr_block_mask` | IPv6 CIDR 网段掩码 | `number` | 否 |
| `tags` | VSwitch 标签 | `map(string)` | 否 |
| `purpose` | VSwitch 用途：`null` 或 `"TR"`。`purpose="TR"` 的 VSwitch 用于转发路由器 attachment | `string` | 否 |

### cen_attachment 对象（VPC 特定）

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| `cen_tr_attachment_name` | 转发路由器 VPC attachment 名称 | `string` | `""` |
| `cen_tr_attachment_description` | 转发路由器 VPC attachment 描述 | `string` | `""` |
| `cen_tr_route_table_association_enabled` | 是否启用路由表关联 | `bool` | `true` |
| `cen_tr_route_table_propagation_enabled` | 是否启用路由表传播 | `bool` | `true` |
| `cen_tr_attachment_auto_publish_route_enabled` | 是否自动发布路由 | `bool` | `false` |
| `cen_tr_attachment_force_delete` | 是否强制删除 attachment | `bool` | `false` |
| `cen_tr_attachment_payment_type` | attachment 付费类型 | `string` | `"PayAsYouGo"` |
| `cen_tr_attachment_tags` | 转发路由器 VPC attachment 标签 | `map(string)` | `{}` |
| `cen_tr_attachment_options` | 转发路由器 VPC attachment 选项 | `map(string)` | `{"ipv6Support" = "disable"}` |
| `cen_tr_attachment_resource_type` | attachment 资源类型 | `string` | `"VPC"` |
| `vpc_route_entries` | 添加到 VPC 路由表的路由条目列表 | `list(object)` | `[]` |

## 输出

| 名称 | 描述 |
|------|------|
| `vpcs` | 所有创建的 VPC 的映射，以 vpc_name 为键，包含 VPC 详情和 CEN attachment ID |
| `vpc_ids` | VPC ID 映射，以 vpc_name 为键 |
| `cen_tr_attachment_ids` | CEN 转发路由器 attachment ID 映射，以 vpc_name 为键（如果未启用 attachment 则为 null） |

## 注意事项

- 所有 VPC 共享相同的 CEN 实例、转发路由器和路由表配置
- 当 `cen_attachment_enabled` 为 `true` 时，必须提供 `cen_instance_id`、`cen_tr_id` 和 `cen_tr_route_table_id`
- **跨账号连接**：当 CEN 和 VPC 在不同账号时，必须设置 `create_cen_instance_grant = true` 来创建授权。当它们在同一账号时，必须设置为 `false`。
- 通过 `purpose="TR"` 标识的 VSwitch 会自动用于转发路由器 attachment
- 每个启用 CEN attachment 的 VPC 必须至少有 2 个 VSwitch 的 `purpose="TR"`
- VPC 使用 `for_each` 创建，因此每个 VPC 名称必须唯一

