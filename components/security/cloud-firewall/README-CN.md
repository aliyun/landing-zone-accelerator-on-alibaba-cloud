<div align="right">

**中文** | [English](README.md)

</div>

# Cloud Firewall 组件

该组件用于创建和管理阿里云云防火墙实例、成员账号管理和互联网控制策略。

## 功能特性

- 创建云防火墙实例
- 管理成员账号以实现集中式防火墙管理
- 配置互联网控制策略
- 创建 VPC CEN TR 防火墙（每个转发路由器对应一个防火墙）
- 创建 NAT 网关防火墙
- 创建 NAT 网关防火墙控制策略
- 支持基于文件和内联配置
- 文件配置优先于内联配置（如果提供了文件路径，内联配置将被忽略）
- 创建 VPC 防火墙控制策略

## 重要说明

**⚠️ 计费模式限制**：本组件支持按量付费和包年包月1.0计费模式，不支持包年包月2.0计费模式。

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
| [alicloud_cloud_firewall_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance) | resource | 云防火墙实例 |
| [alicloud_cloud_firewall_instance_member.members](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance_member) | resource | 成员账号 |
| [alicloud_cloud_firewall_address_book.address_books](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_address_book) | resource | 地址簿 |
| [alicloud_cloud_firewall_control_policy.internet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | 互联网控制策略 |
| [alicloud_cloud_firewall_control_policy_order.in](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy_order) | resource | 入站策略优先级顺序 |
| [alicloud_cloud_firewall_control_policy_order.out](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy_order) | resource | 出站策略优先级顺序 |
| [alicloud_cloud_firewall_policy_advanced_config.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_policy_advanced_config) | resource | 高级策略设置 |
| [alicloud_cloud_firewall_vpc_cen_tr_firewall.vpc_firewalls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_vpc_cen_tr_firewall) | resource | VPC CEN TR 防火墙（每个转发路由器对应一个防火墙） |
| [alicloud_cloud_firewall_nat_firewall.nat_firewalls](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_nat_firewall) | resource | NAT 网关防火墙 |
| [alicloud_cloud_firewall_nat_firewall_control_policy.nat_policies](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_nat_firewall_control_policy) | resource | NAT 网关防火墙控制策略 |

## 使用方法

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium"
  cloud_firewall_bandwidth       = 100
  cloud_firewall_payment_type    = "PayAsYouGo"

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]

  internet_control_policies = [
    {
      description           = "允许来自互联网的 HTTP"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "80"
      acl_action            = "accept"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["HTTP"]
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `create_cloud_firewall_instance` | 是否创建云防火墙实例 | `bool` | `true` | No | - |
| `cloud_firewall_instance_type` | 云防火墙实例类型 | `string` | `"premium"` | No | 有效的实例类型 |
| `cloud_firewall_bandwidth` | 云防火墙实例带宽 | `number` | `100` | No | - |
| `cloud_firewall_payment_type` | 云防火墙实例付费类型。有效值：PayAsYouGo（按量付费）、Subscription（包年包月，仅支持1.0版本，不支持2.0版本） | `string` | `"PayAsYouGo"` | No | - |
| `cloud_firewall_period` | 预付费周期。有效值：1, 3, 6, 12, 24, 36。当 payment_type 为 Subscription 时必填 | `number` | `null` | No | - |
| `cloud_firewall_renewal_duration` | 自动续费时长。有效值：1, 2, 3, 6, 12。当 renewal_status 为 AutoRenewal 且 payment_type 为 Subscription 时必填 | `number` | `null` | No | - |
| `cloud_firewall_renewal_duration_unit` | 自动续费周期单位。有效值：Month, Year | `string` | `null` | No | - |
| `cloud_firewall_renewal_status` | 是否自动续费。有效值：AutoRenewal, ManualRenewal。默认：ManualRenewal。仅在 payment_type 为 Subscription 时生效 | `string` | `"ManualRenewal"` | No | - |
| `cloud_firewall_modify_type` | 修改类型。有效值：Upgrade, Downgrade。执行更新操作时必填 | `string` | `null` | No | - |
| `cloud_firewall_cfw_log` | 是否使用日志审计。有效值：true, false。当 payment_type 为 PayAsYouGo 时，cfw_log 只能设置为 true | `bool` | `null` | No | - |
| `cloud_firewall_cfw_log_storage` | 日志存储容量。当 payment_type 为 PayAsYouGo 或 cfw_log 为 false 时，此参数将被忽略 | `number` | `null` | No | - |
| `cloud_firewall_ip_number` | 可保护的公网 IP 数量。有效值：20 到 4000 | `number` | `null` | No | 见下方说明 |
| `member_account_ids` | 要管理的成员账号 ID 列表 | `list(string)` | `[]` | No | - |
| `member_account_id_file_path` | 成员账号配置文件的路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |
| `internet_control_policies` | 互联网控制策略列表 | `list(object)` | `[]` | No | 有效的策略配置。如果提供了文件路径，则忽略此参数 |
| `internet_control_policy_in_file_path` | 入站（in）互联网控制策略配置文件路径（JSON/YAML）。文件必须包含策略对象数组。如果提供，则忽略内联 `internet_control_policies` 中 direction="in" 的策略 | `string` | `null` | No | 支持 .json, .yaml, .yml。必须是数组格式 |
| `internet_control_policy_out_file_path` | 出站（out）互联网控制策略配置文件路径（JSON/YAML）。文件必须包含策略对象数组。如果提供，则忽略内联 `internet_control_policies` 中 direction="out" 的策略 | `string` | `null` | No | 支持 .json, .yaml, .yml。必须是数组格式 |
| `internet_switch` | 访问控制策略严格模式。有效值：on, off | `string` | `null` | No | - |
| `address_books` | 云防火墙地址簿列表 | `list(object)` | `[]` | No | 见下方 address_books 对象说明 |
| `vpc_cen_tr_firewalls` | VPC CEN TR 防火墙配置列表。每个转发路由器对应一个防火墙 | `list(object)` | `[]` | No | 见下方 vpc_cen_tr_firewalls 对象说明 |
| `vpc_firewall_control_policies` | 按 cen_id 分组的 VPC 防火墙控制策略配置列表。每个配置包含 cen_id、control_policies（内联）和可选的 control_policy_file_path（文件配置）。文件配置优先于内联配置 | `list(object)` | `[]` | No | 见下方 vpc_firewall_control_policies 对象说明 |
| `nat_firewalls` | NAT 网关防火墙配置列表 | `list(object)` | `[]` | No | 见下方 nat_firewalls 对象说明 |
| `nat_firewall_control_policies` | 按 nat_gateway_id 分组的 NAT 网关防火墙控制策略配置列表。每个配置包含 nat_gateway_id、control_policies（内联）和可选的 control_policy_file_path（文件配置）。文件配置优先于内联配置。direction 固定为 'out'，new_order 固定为 1 | `list(object)` | `[]` | No | 见下方 nat_firewall_control_policies 对象说明 |

### address_books 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `group_name` | 地址簿名称 | `string` | Yes | - |
| `group_type` | 地址簿类型。有效值：port, ackLabel, ipv6, ip, domain, ackNamespace, tag | `string` | Yes | - |
| `description` | 地址簿描述 | `string` | Yes | - |
| `auto_add_tag_ecs` | 是否自动将匹配标签的 ECS IP 地址添加到地址簿。有效值：0, 1 | `number` | No | - |
| `tag_relation` | ECS 标签匹配的逻辑关系。有效值：and, or | `string` | No | `"and"` |
| `lang` | 请求和响应内容的语言。有效值：zh, en | `string` | No | - |
| `address_list` | 地址列表 | `list(string)` | No | `[]` |
| `ecs_tags` | ECS 标签列表 | `list(object)` | No | `[]` |

#### ecs_tags 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `tag_key` | 要匹配的 ECS 标签键 | `string` | No | - |
| `tag_value` | 要匹配的 ECS 标签值 | `string` | No | - |

### vpc_cen_tr_firewalls 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `transit_router_id` | 转发路由器实例 ID | `string` | Yes | - |
| `cen_id` | CEN 实例 ID | `string` | Yes | - |
| `firewall_name` | 云防火墙名称 | `string` | Yes | - |
| `region_no` | 转发路由器实例的地域 ID | `string` | Yes | - |
| `route_mode` | 路由模式。有效值：managed（自动模式）、manual（手动模式） | `string` | Yes | - |
| `firewall_vpc_cidr` | 自动模式下必填，防火墙 VPC 的 CIDR | `string` | Yes | - |
| `firewall_subnet_cidr` | 自动模式下必填，防火墙 VPC 中用于存储防火墙 ENI 的子网 CIDR | `string` | Yes | - |
| `tr_attachment_master_cidr` | 自动模式下必填，防火墙 VPC 中用于连接 TR 的主网段 CIDR | `string` | Yes | - |
| `tr_attachment_slave_cidr` | 自动模式下必填，防火墙 VPC 中用于连接 TR 的备网段 CIDR | `string` | Yes | - |
| `firewall_description` | 防火墙描述 | `string` | No | - |
| `tr_attachment_master_zone` | 交换机主可用区 | `string` | No | - |
| `tr_attachment_slave_zone` | 交换机备可用区 | `string` | No | - |

### vpc_firewall_control_policies 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `cen_id` | CEN 实例 ID（vpc_firewall_id）。当 VPC 防火墙保护通过云企业网连接的两个 VPC 之间的流量时，策略组 ID 使用云企业网实例 ID | `string` | Yes | - |
| `control_policies` | 该 CEN 的内联控制策略列表。如果提供了 control_policy_file_path，则忽略此参数 | `list(object)` | No | `[]` | 见下方 control_policies 对象说明 |
| `control_policy_file_path` | 该 CEN 的控制策略配置文件路径（JSON/YAML）。文件必须包含策略对象数组。文件配置优先于 control_policies | `string` | No | - | 支持 .json, .yaml, .yml。必须是数组格式 |

#### control_policies 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `description` | VPC 防火墙访问控制策略描述信息 | `string` | Yes | - |
| `source` | VPC 防火墙访问控制策略中的源地址 | `string` | Yes | - |
| `source_type` | 访问控制策略中源地址的类型。有效值：net, group | `string` | Yes | - |
| `destination` | 访问控制策略中的目标地址。如果 destination_type 设置为 net，值必须是 CIDR 块。如果 destination_type 设置为 group，值必须是地址簿。如果 destination_type 设置为 domain，值必须是域名 | `string` | Yes | - |
| `destination_type` | 访问控制策略中目标地址的类型。有效值：net, group, domain | `string` | Yes | - |
| `proto` | 访问控制策略中的协议类型。有效值：ANY, TCP, UDP, ICMP | `string` | Yes | - |
| `acl_action` | 云防火墙对流量执行的操作。有效值：accept, drop, log | `string` | Yes | - |
| `dest_port` | 访问控制策略中的目标端口。当 dest_port_type 设置为 port 时必填 | `string` | No | - |
| `dest_port_group` | 访问控制策略中目标端口地址簿名称。当 dest_port_type 设置为 group 时必填 | `string` | No | - |
| `dest_port_type` | 访问控制策略中目标端口的类型。有效值：port, group | `string` | No | - |
| `application_name_list` | 访问控制策略支持的应用类型列表。有效值：ANY, HTTP, HTTPS, MQTT, Memcache, MongoDB, MySQL, RDP, Redis, SMTP, SMTPS, SSH, SSL, VNC。如果 proto 为 TCP，可以是任何有效值。如果 proto 为 UDP、ICMP 或 ANY，只能为 ["ANY"] | `list(string)` | Yes | - |
| `release` | 访问控制策略的启用状态。策略创建后默认启用。有效值：true（启用）, false（禁用） | `bool` | No | - |
| `member_uid` | 当前阿里云账号的成员账号 UID | `string` | No | - |
| `domain_resolve_type` | 访问控制策略的域名解析方式。有效值：FQDN, DNS, FQDN_AND_DNS。自 v1.267.0 起可用 | `string` | No | - |
| `repeat_type` | 策略有效期内的重复类型。有效值：Permanent, None, Daily, Weekly, Monthly。自 v1.267.0 起可用 | `string` | No | `"Permanent"` |
| `repeat_days` | 策略周期性生效的星期几或月份中的日期。如果 repeat_type 为 Weekly，有效值：0 到 6。如果 repeat_type 为 Monthly，有效值：1 到 31。自 v1.267.0 起可用 | `list(number)` | No | - |
| `repeat_end_time` | 策略有效期的重复结束时间。自 v1.267.0 起可用 | `string` | No | - |
| `repeat_start_time` | 策略有效期的重复开始时间。自 v1.267.0 起可用 | `string` | No | - |
| `start_time` | 策略有效期的开始时间。UNIX 时间戳（秒）。必须为整点或半点。自 v1.267.0 起可用 | `number` | No | - |
| `end_time` | 策略有效期的结束时间。UNIX 时间戳（秒）。必须为整点或半点，且至少比 start_time 晚 30 分钟。自 v1.267.0 起可用 | `number` | No | - |
| `lang` | 请求和响应中的内容语言。有效值：zh, en | `string` | No | `"zh"` |

**注意：** 由于 Terraform 的并行执行模型，`order` 字段固定设置为 1。由于 Terraform 并行创建资源，无法保证策略创建顺序与数组索引匹配。将 order 设置为 1 可确保新创建的策略具有最高优先级（order 值越小，优先级越高）。如果需要特定的排序，请在 Terraform 外部管理策略或使用单独的顺序 apply 操作。

### internet_control_policies 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `description` | 规则描述 | `string` | Yes | - |
| `source` | 访问控制策略中的源地址 | `string` | Yes | - |
| `destination` | 访问控制策略中的目标地址 | `string` | Yes | - |
| `proto` | 访问控制策略支持的协议类型。有效值：ANY, TCP, UDP, ICMP | `string` | Yes | - |
| `dest_port` | 目标端口。当 dest_port_type 设置为 port 时必填 | `string` | No | - |
| `acl_action` | 云防火墙对流量执行的操作。有效值：accept, drop, log | `string` | Yes | - |
| `direction` | 访问控制策略适用的流量方向。有效值：in, out | `string` | Yes | - |
| `source_type` | 源地址类型。有效值：net, group, location | `string` | Yes | - |
| `destination_type` | 目标地址类型。有效值：net, group, domain, location | `string` | Yes | - |
| `application_name_list` | 访问控制策略支持的应用类型列表。有效值：ANY, HTTP, HTTPS, MQTT, Memcache, MongoDB, MySQL, RDP, Redis, SMTP, SMTPS, SSH, SSL, VNC。如果 proto 为 TCP，可以是任何有效值。如果 proto 为 UDP、ICMP 或 ANY，只能为 ANY | `list(string)` | Yes | - |
| `dest_port_group` | 目标端口地址簿名称。当 dest_port_type 设置为 group 时必填 | `string` | No | - |
| `dest_port_type` | 目标端口类型。有效值：port, group | `string` | No | - |
| `ip_version` | 访问控制策略支持的 IP 版本。有效值：4 (IPv4), 6 (IPv6) | `number` | No | `4` |
| `domain_resolve_type` | 域名解析方式。有效值：FQDN, DNS, FQDN_AND_DNS | `string` | No | - |
| `start_time` | 访问控制策略开始生效的时间。UNIX 时间戳（秒）。必须为整点或半点 | `number` | No | - |
| `end_time` | 访问控制策略停止生效的时间。UNIX 时间戳（秒）。必须为整点或半点，且至少比 start_time 晚 30 分钟。当 repeat_type 为 None、Daily、Weekly 或 Monthly 时必填 | `number` | No | - |
| `repeat_type` | 访问控制策略的重复类型 | `string` | No | `"Permanent"` |
| `repeat_start_time` | 重复周期的开始时间 | `string` | No | - |
| `repeat_end_time` | 重复周期的结束时间 | `string` | No | - |
| `repeat_days` | 重复周期的星期几 | `list(number)` | No | - |
| `release` | 是否释放策略 | `bool` | No | - |
| `lang` | 请求和响应内容的语言。有效值：zh, en | `string` | No | `"zh"` |

## 输出参数

| Name | Description |
|------|-------------|
| `cloud_firewall_instance_id` | 云防火墙实例 ID |
| `cloud_firewall_instance_status` | 云防火墙实例状态 |
| `member_account_ids` | 由云防火墙管理的成员账号 ID 列表 |
| `internet_control_policy_count` | 创建的互联网控制策略数量 |
| `internet_control_policies` | 包含 ACL UUID 的互联网控制策略列表 |
| `address_books` | 创建的地址簿映射，以 group_name 为键 |
| `vpc_cen_tr_firewalls` | 创建的 VPC CEN TR 防火墙映射，以 transit_router_id 为键 |
| `nat_firewalls` | 创建的 NAT 网关防火墙映射，以 nat_gateway_id 为键 |
| `nat_firewall_control_policies` | 创建的 NAT 网关防火墙控制策略列表，包含详细信息（包括 acl_uuid） |

## 使用示例

### 基础云防火墙实例

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "premium"
  cloud_firewall_bandwidth       = 100
}
```

### 带成员账号

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_ids = [
    "123456789012",
    "234567890123"
  ]
}
```

### 使用文件配置

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_id_file_path = "./member_accounts/accounts.json"
  
  # 入站策略文件（必须是数组格式）
  internet_control_policy_in_file_path = "./policies/inbound.json"
  
  # 出站策略文件（必须是数组格式）
  internet_control_policy_out_file_path = "./policies/outbound.json"
}
```

示例 `inbound.json`：
```json
[
  {
    "description": "允许来自互联网的 HTTP",
    "source": "0.0.0.0/0",
    "destination": "10.0.1.0/24",
    "proto": "TCP",
    "dest_port": "80/80",
    "acl_action": "accept",
    "direction": "in",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["HTTP"]
  },
  {
    "description": "允许来自互联网的 HTTPS",
    "source": "0.0.0.0/0",
    "destination": "10.0.1.0/24",
    "proto": "TCP",
    "dest_port": "443/443",
    "acl_action": "accept",
    "direction": "in",
    "source_type": "net",
    "destination_type": "net",
    "application_name_list": ["HTTPS"]
  }
]
```

**注意**：如果文件中没有 `direction` 字段，将自动设置为 "in"（入站文件）或 "out"（出站文件）。如果文件中存在 `direction` 字段但与文件类型不匹配（例如在入站文件中配置了 "out"），该规则将被过滤掉。

### 互联网 ACL 规则

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  internet_control_policies = [
    {
      description           = "允许来自互联网的 HTTPS"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "443"
      acl_action            = "accept"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["HTTPS"]
    },
    {
      description           = "阻止来自互联网的 SSH"
      source                = "0.0.0.0/0"
      destination           = "10.0.1.0/24"
      proto                 = "TCP"
      dest_port             = "22"
      acl_action            = "drop"
      direction             = "in"
      source_type           = "net"
      destination_type      = "net"
      application_name_list = ["SSH"]
    }
  ]
}
```

### VPC CEN TR 防火墙

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  vpc_cen_tr_firewalls = [
    {
      transit_router_id         = "tr-uf6e6h5vv5eigxxxxxx"
      cen_id                    = "cen-jhwbspfj5lnxxxxxxxx"
      firewall_name             = "vpc-firewall-1"
      region_no                 = "cn-hangzhou"
      route_mode                = "managed"
      firewall_vpc_cidr         = "10.0.0.0/16"
      firewall_subnet_cidr      = "10.0.1.0/24"
      tr_attachment_master_cidr = "10.0.2.0/24"
      tr_attachment_slave_cidr  = "10.0.3.0/24"
      firewall_description      = "转发路由器 1 的 VPC 防火墙"
      tr_attachment_master_zone = "cn-hangzhou-h"
      tr_attachment_slave_zone  = "cn-hangzhou-i"
    },
    {
      transit_router_id         = "tr-2zebnpl3f8z7i3xxxxxx"
      cen_id                    = "cen-jhwbspfj5lnxxxxxxxx"
      firewall_name             = "vpc-firewall-2"
      region_no                 = "cn-beijing"
      route_mode                = "managed"
      firewall_vpc_cidr         = "10.1.0.0/16"
      firewall_subnet_cidr      = "10.1.1.0/24"
      tr_attachment_master_cidr = "10.1.2.0/24"
      tr_attachment_slave_cidr  = "10.1.3.0/24"
    }
  ]
}
```

### NAT 网关防火墙

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  # ... 其他配置 ...

  nat_firewalls = [
    {
      nat_gateway_id = "ngw-uf6hg6eaaqz70xxxxxx"
      proxy_name     = "nat-firewall-1"
      region_no      = "cn-shanghai"
      vpc_id         = "vpc-uf6v10ktt3tnxxxxxxxx"
      nat_route_entry_list = [
        {
          route_table_id   = "vtb-uf6i7jiaadomxxxxxx"
          # destination_cidr 和 nexthop_id 可选，如果不提供会使用默认值
        }
      ]
      firewall_switch = "open"
      vswitch_auto    = true
      vswitch_cidr    = "172.16.5.0/24"
    }
  ]
}
```

**注意：**
- 每个 NAT 网关可以创建一个防火墙。防火墙以 `nat_gateway_id` 为键
- 在 `nat_route_entry_list` 中，`nexthop_type` 自动设置为 `"NatGateway"`，无法更改
- 如果路由条目中未提供 `nexthop_id`，将自动使用父防火墙配置中的 `nat_gateway_id`
- 如果路由条目中未提供 `destination_cidr`，将默认为 `"0.0.0.0/0"`
- 如果 `vswitch_auto` 为 `true`（自动模式），需要 `vswitch_cidr`
- 如果 `vswitch_auto` 为 `false`（手动模式），需要 `vswitch_id`

### NAT 网关防火墙控制策略

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  # ... 其他配置 ...

  nat_firewall_control_policies = [
    {
      nat_gateway_id = "ngw-uf6hg6eaaqz70xxxxxx"
      control_policies = [
        {
          description           = "允许 HTTPS 流量"
          source                = "10.0.0.0/8"
          destination           = "0.0.0.0/0"
          proto                 = "TCP"
          dest_port             = "443/443"
          acl_action            = "accept"
          source_type           = "net"
          destination_type      = "net"
          application_name_list = ["HTTPS"]
          ip_version            = 4
        }
      ]
    }
  ]
}
```

或使用文件配置：

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  nat_firewall_control_policies = [
    {
      nat_gateway_id            = "ngw-uf6hg6eaaqz70xxxxxx"
      control_policy_file_path  = "./configs/nat-gw-xxx-policies.json"
    }
  ]
}
```

**注意：**
- `direction` 自动设置为 `"out"`，无法更改（NAT 网关防火墙控制策略固定为出站）
- `new_order` 固定为 1，由于 Terraform 的并行执行模型，无法保证策略创建顺序与数组索引匹配。将 new_order 设置为 1 可确保新创建的策略具有最高优先级
- 文件配置（`control_policy_file_path`）优先于内联配置（`control_policies`），对于相同的 nat_gateway_id
- 每个 nat_gateway_id 可以有自己的文件或内联策略，或两者都有（文件优先）

## 注意事项

- **计费模式**：本组件支持按量付费和包年包月1.0计费模式，不支持包年包月2.0计费模式。
- 必须先创建云防火墙实例，然后才能添加成员账号、地址簿或配置策略
- 成员账号添加到防火墙以实现集中管理
- 可以创建地址簿来组织 IP 地址、域名、端口或 ECS 标签，供控制策略使用
- 互联网控制策略允许对流量进行细粒度控制，可以引用地址簿
- **文件配置优先级**：如果提供了文件路径（`internet_control_policy_in_file_path` 或 `internet_control_policy_out_file_path`），对应方向的内联 `internet_control_policies` 将被忽略
- **文件格式**：策略配置文件必须包含策略对象数组（不能是单个对象）
- **direction 字段处理**：
  - 如果文件中缺少 `direction` 字段，将自动设置（入站文件设置为 "in"，出站文件设置为 "out"）
  - 如果文件中存在 `direction` 字段但与文件类型不匹配（例如在入站文件中配置了 "out"），该规则将被过滤掉
- **策略优先级**：策略优先级顺序根据数组索引自动设置（从 1 开始），入站和出站策略分别独立管理
- 策略唯一性由 description、source、destination、dest_port 和 direction 确定
- **VPC CEN TR 防火墙**：每个转发路由器创建一个防火墙。每个防火墙配置必须具有唯一的 `transit_router_id`。VPC 防火墙依赖于将成员账号添加到云防火墙实例
- **VPC 防火墙控制策略优先级**：由于 Terraform 的并行执行模型，`order` 字段固定设置为 1。这确保新创建的策略具有最高优先级。如果需要特定的排序，请在 Terraform 外部管理策略或使用单独的顺序 apply 操作
- **NAT 网关防火墙**： 
  - 每个 NAT 网关可以创建一个防火墙。防火墙以 `nat_gateway_id` 为键
  - 在 `nat_route_entry_list` 中，`nexthop_type` 自动设置为 `"NatGateway"`，无法更改
  - 如果路由条目中未提供 `nexthop_id`，将自动使用父防火墙配置中的 `nat_gateway_id`
  - 如果路由条目中未提供 `destination_cidr`，将默认为 `"0.0.0.0/0"`
  - 如果 `vswitch_auto` 为 `true`（自动模式），需要 `vswitch_cidr`
  - 如果 `vswitch_auto` 为 `false`（手动模式），需要 `vswitch_id`
- **NAT 网关防火墙控制策略**： 
  - 策略按 `nat_gateway_id` 分组。每个配置包含 `nat_gateway_id`、可选的 `control_policies`（内联）和可选的 `control_policy_file_path`（文件配置）
  - 文件配置（`control_policy_file_path`）优先于内联配置（`control_policies`），对于相同的 nat_gateway_id
  - `direction` 自动设置为 `"out"`，无法更改
  - `new_order` 固定为 1，由于 Terraform 的并行执行限制，无法保证策略创建顺序与数组索引匹配。将 new_order 设置为 1 可确保新创建的策略具有最高优先级。如果需要特定的排序，请在 Terraform 外部管理策略
  - 文件配置必须包含策略对象数组（不包含 nat_gateway_id，因为它在配置中指定）

### ip_number 参数

`ip_number` 参数指定可保护的公网 IP 数量：
- **premium_version**：有效范围 [60, 1000]，默认值：20
- **enterprise_version**：有效范围 [60, 1000]，默认值：50
- **ultimate_version**：有效范围 [400, 4000]，默认值：400
