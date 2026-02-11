<div align="right">

**中文** | [English](README.md)

</div>

# CEN 路由策略组件

该组件用于创建和管理云企业网（CEN）路由策略，支持灵活的配置方式。

## 功能特性

- 创建多个 CEN 路由策略
- 支持三种配置方式：
  - 通过 Terraform 变量直接配置
  - 从单个或多个 YAML/JSON 文件加载
  - 从包含 YAML/JSON 文件的目录加载
- 支持匹配条件和路由操作
- 自动策略规范化和验证
- 基于优先级的灵活路由控制

## 重要说明

路由策略按优先级评估（1-100，数字越小优先级越高）。当路由匹配策略的所有条件时，将执行策略行为（允许/拒绝）。不匹配所有条件的路由默认允许通过。

更多信息请参考：
- [Terraform 资源文档](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_map)
- [阿里云 API 文档](https://www.alibabacloud.com/help/zh/cen/developer-reference/api-cbn-2017-09-12-createcenroutemap)

## 前置要求

| Name | Version |
|------|---------|
| terraform | >= 1.2 |
| alicloud | >= 1.120.0 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.120.0 |

## Modules

无模块。

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_cen_route_map.route_map](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cen_route_map) | resource | CEN 路由策略 |

## 使用方法

### 方式一：直接配置

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null # null 表示系统/默认路由表

  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "允许来自 VPN 的 BGP 路由"
      
      # 匹配条件
      source_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      source_child_instance_types = ["VPN"]
      route_types                 = ["BGP"]
      
      # 执行操作
      preference = 100
    },
    {
      transmit_direction = "RegionOut"
      priority           = 20
      map_result         = "Permit"
      description        = "设置发往 VPN 的路由优先级"
      
      destination_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      destination_child_instance_types = ["VPN"]
      prepend_as_path                  = ["65001", "65001"]
      preference                       = 110
    }
  ]
}
```

### 方式二：从文件加载

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_file_paths = ["./policies/vpn-policies.yaml"]
}
```

**策略文件示例（YAML）- 数组格式：**

```yaml
# vpn-policies.yaml
# 注意：tr_region_id 和 transit_router_route_table_id 在 Terraform 配置中定义
# 此文件只包含策略定义，可跨不同路由表复用
# 文件必须包含策略对象数组
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: 允许来自 VPN 的 BGP 路由
  source_instance_ids:
    - vpn-xxxxxxxxxxxxx
  route_types:
    - BGP
  preference: 100

- transmit_direction: RegionOut
  priority: 20
  map_result: Permit
  description: 设置发往 VPN 的路由优先级
  destination_instance_ids:
    - vpn-xxxxxxxxxxxxx
  preference: 110
```

### 方式三：从目录加载

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  config_directory = "./route-policies"
}
```

将处理目录及其子目录中的所有 `.json`、`.yaml` 和 `.yml` 文件。您可以指定多个目录：

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_dir_paths = [
    "./route-policies/shared",
    "./route-policies/region-specific"
  ]
}
```

### 方式四：组合配置

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id = "cen-xxxxxxxxxxxxx"

  route_policies = [
    {
  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  # 直接配置的策略
  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "直接配置的策略"
    }
  ]
  
  # 从文件加载额外策略
  policy_file_paths = ["./policies/additional-policies.yaml"]
  
  # 从目录加载更多策略
  policy_dir_paths = ["./route-policies"]
}
```

## 输入参数

| 参数名 | 说明 | 类型 | 默认值 | 必填 |
|--------|------|------|--------|------|
| `cen_id` | CEN 实例 ID | `string` | - | 是 |
| `tr_region_id` | 转发路由器所在的地域 ID | `string` | - | 是 |
| `transit_router_route_table_id` | 路由表 ID。若为 `null`，则使用默认系统路由表 | `string` | `null` | 否 |
| `route_policies` | 路由策略列表（直接配置） | `list(object)` | `[]` | 否 |
| `policy_file_paths` | 路由策略文件路径列表（YAML/JSON）。每个元素应该是文件路径 | `list(string)` | `[]` | 否 |
| `policy_dir_paths` | 包含路由策略文件的目录路径列表（YAML/JSON）。文件必须包含策略对象数组 | `list(string)` | `[]` | 否 |

### 策略对象结构（`route_policies` 中的元素）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `transmit_direction` | `string` | 是 | 策略方向：`RegionIn`（入地域网关）或 `RegionOut`（出地域网关） |
| `priority` | `number` | 是 | 优先级（1-100，数字越小优先级越高） |
| `map_result` | `string` | 是 | 策略行为：`Permit`（允许）或 `Deny`（拒绝） |
| `description` | `string` | 否 | 策略描述（1-256 个字符） |
| `next_priority` | `number` | 否 | 关联的下一条策略优先级（仅 Permit 时可用） |

#### 匹配条件

| 字段 | 类型 | 说明 |
|------|------|------|
| `cidr_match_mode` | `string` | CIDR 匹配模式：`Include`（模糊匹配）或 `Complete`（精确匹配） |
| `as_path_match_mode` | `string` | AS Path 匹配模式：`Include` 或 `Complete` |
| `community_match_mode` | `string` | Community 匹配模式：`Include` 或 `Complete` |
| `match_asns` | `list(string)` | 要匹配的 AS 号码列表（最多 32 个） |
| `match_community_set` | `list(string)` | 要匹配的 Community 列表（最多 32 个） |
| `route_types` | `list(string)` | 路由类型：`System`、`Custom`、`BGP` |
| `source_instance_ids` | `list(string)` | 源实例 ID 列表（最多 32 个） |
| `source_instance_ids_reverse_match` | `bool` | 源实例反向匹配 |
| `source_route_table_ids` | `list(string)` | 源路由表 ID 列表（最多 32 个） |
| `source_region_ids` | `list(string)` | 源地域 ID 列表（最多 32 个） |
| `source_child_instance_types` | `list(string)` | 源实例类型：`VPC`、`VBR`、`CCN`、`VPN` |
| `destination_instance_ids` | `list(string)` | 目的实例 ID 列表（最多 32 个） |
| `destination_instance_ids_reverse_match` | `bool` | 目的实例反向匹配 |
| `destination_route_table_ids` | `list(string)` | 目的路由表 ID 列表（最多 32 个） |
| `destination_child_instance_types` | `list(string)` | 目的实例类型：`VPC`、`VBR`、`CCN`、`VPN` |
| `destination_cidr_blocks` | `list(string)` | 目的 CIDR 地址段列表（最多 32 个） |

#### 执行操作

| 字段 | 类型 | 说明 |
|------|------|------|
| `community_operate_mode` | `string` | Community 操作模式：`Additive`（添加）或 `Replace`（替换） |
| `prepend_as_path` | `list(string)` | 要附加的 AS Path（最多 32 个 AS 号码） |
| `preference` | `number` | 路由优先级 |
| `operate_community_set` | `list(string)` | 要添加/替换的 Community 值（最多 32 个） |

## 输出参数

| 参数名 | 说明 |
|--------|------|
| `route_map_ids` | 所有路由策略 ID 的列表（`route_map_id`） |
| `route_maps` | 所有路由策略详细信息的列表，包括 `id`、`route_map_id`、地域、方向、优先级、状态等 |

## 使用示例

### 示例 1：VPN 路由过滤

```hcl
module "vpn_route_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null

  route_policies = [
    {
      transmit_direction = "RegionIn"
      priority           = 10
      map_result         = "Permit"
      description        = "允许来自 VPN 的 BGP 路由，优先级设为 100"
      
      source_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      source_child_instance_types = ["VPN"]
      route_types                 = ["BGP"]
      
      preference = 100
    }
  ]
}
```

### 示例 2：拒绝特定 CIDR 地址段

```hcl
module "deny_cidr_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null

  route_policies = [
    {
      transmit_direction = "RegionOut"
      priority           = 20
      map_result         = "Deny"
      description        = "拒绝私有 IP 范围"
      
      destination_cidr_blocks = [
        "192.168.100.0/24",
        "10.10.10.0/24"
      ]
      cidr_match_mode = "Complete"
    }
  ]
}
```

### 示例 3：AS Path 附加并指定路由表

```hcl
module "as_path_policy" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxx"

  route_policies = [
    {
      transmit_direction = "RegionOut"
      priority           = 30
      map_result         = "Permit"
      description        = "为发往 VPN 的路由附加 AS Path"
      
      destination_instance_ids         = ["vpn-xxxxxxxxxxxxx"]
      destination_child_instance_types = ["VPN"]
      
      prepend_as_path = ["65001", "65001"]
    }
  ]
}
```

### 示例 4：从 YAML 文件加载

创建文件 `route-policies/vpn-policies.yaml`：

```yaml
# 注意：tr_region_id 和 transit_router_route_table_id 在 Terraform 配置中定义
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: 允许 VPN BGP 路由
  source_instance_ids:
    - vpn-xxxxxxxxxxxxx
  source_child_instance_types:
    - VPN
  route_types:
    - BGP
  preference: 100

- transmit_direction: RegionOut
  priority: 20
  map_result: Permit
  description: 设置发往 VPN 的路由优先级
  destination_instance_ids:
    - vpn-xxxxxxxxxxxxx
  preference: 110
```

然后在 Terraform 中使用：

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_file_paths = ["./route-policies/vpn-policies.yaml"]
}
```

### 示例 5：从目录加载

```hcl
module "cen_route_map" {
  source = "./components/network/cen-route-map"

  cen_id                        = "cen-xxxxxxxxxxxxx"
  tr_region_id                  = "cn-shanghai"
  transit_router_route_table_id = null
  
  policy_dir_paths = ["./route-policies"]
}
```

将加载 `./route-policies` 目录及其子目录中的所有 `.json`、`.yaml` 和 `.yml` 文件。

## 注意事项

- 路由策略按优先级评估（数字越小优先级越高）
- 匹配所有条件的路由将执行策略行为（允许/拒绝）
- 不匹配所有条件的路由默认允许通过
- 当 `map_result` 为 `Permit` 时，可设置 `next_priority` 关联下一条策略
- 每个策略必须有唯一的 `transmit_direction` 和 `priority` 组合（在同一路由表内）
- 如果不指定 `transit_router_route_table_id`，策略将关联到默认系统路由表
- Community 值必须符合 RFC 1997 格式（n:m，其中 n 和 m 为 1-65535）
- AS 号码必须为 1-4294967295
- 描述不能以 `http://` 或 `https://` 开头
- 列表型匹配条件和操作最多支持 32 项

## 配置文件格式

策略文件应只包含策略定义。`tr_region_id` 和 `transit_router_route_table_id` 在外层 Terraform 配置中定义，使策略文件可在不同路由表间复用。

**注意：** 策略文件必须包含策略对象数组。不支持单个策略对象格式。

### YAML 格式（策略数组）

```yaml
# policies.yaml
- transmit_direction: RegionIn
  priority: 10
  map_result: Permit
  description: 策略 1
  
- transmit_direction: RegionOut
  priority: 20
  map_result: Deny
  description: 策略 2
```

### JSON 格式（策略数组）

```json
[
  {
    "transmit_direction": "RegionIn",
    "priority": 10,
    "map_result": "Permit",
    "description": "策略 1"
  },
  {
    "transmit_direction": "RegionOut",
    "priority": 20,
    "map_result": "Deny",
    "description": "策略 2"
  }
]
```

