<div align="right">

**中文** | [English](README.md)

</div>

# Cloud Firewall 组件

该组件用于创建和管理阿里云云防火墙实例、成员账号管理和互联网边界防火墙规则。

## 功能特性

- 创建云防火墙实例
- 管理成员账号以实现集中式防火墙管理
- 配置 SLB 资源的互联网边界防护
- 配置互联网 ACL 规则
- 支持基于目录和内联配置的合并
- 目录配置优先于内联配置

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
| [alicloud_cloud_firewall_instance.main](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance) | resource | 云防火墙实例 |
| [alicloud_cloud_firewall_instance_member.members](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_instance_member) | resource | 成员账号 |
| [alicloud_cloud_firewall_control_policy.internet_protection](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | 互联网边界防护策略 |
| [alicloud_cloud_firewall_control_policy.internet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/cloud_firewall_control_policy) | resource | 互联网 ACL 规则 |

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

  enable_internet_protection        = true
  internet_protection_source         = "0.0.0.0/0"
  internet_protection_destination   = "10.0.0.0/8"

  internet_acl_rules = [
    {
      description      = "允许来自互联网的 HTTP"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "80"
      destination_port = "80"
      policy           = "accept"
      direction        = "in"
      priority         = 1
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
| `cloud_firewall_payment_type` | 云防火墙实例付费类型 | `string` | `"PayAsYouGo"` | No | - |
| `member_account_ids` | 要管理的成员账号 ID 列表 | `list(string)` | `[]` | No | - |
| `member_account_ids_dir` | 包含成员账号配置文件的目录路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |
| `internet_acl_rules` | 互联网 ACL 规则列表 | `list(object)` | `[]` | No | 有效的规则配置 |
| `internet_acl_rules_dir` | 包含互联网 ACL 规则配置文件的目录路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |
| `enable_internet_protection` | 是否启用互联网边界防护 | `bool` | `false` | No | - |
| `internet_protection_source` | 互联网边界防护的源 CIDR | `string` | `"0.0.0.0/0"` | No | - |
| `internet_protection_destination` | 互联网边界防护的目标 CIDR | `string` | `"0.0.0.0/0"` | No | - |
| `internet_protection_application` | 互联网边界防护的应用名称 | `string` | `"ANY"` | No | - |
| `internet_protection_port` | 互联网边界防护的端口 | `string` | `"80"` | No | - |
| `control_policy_application_name` | 控制策略的应用名称 | `string` | `"ANY"` | No | - |
| `control_policy_source_type` | 控制策略的源类型 | `string` | `"net"` | No | - |
| `control_policy_destination_type` | 控制策略的目标类型 | `string` | `"net"` | No | - |

### internet_acl_rules 对象

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `description` | 规则描述 | `string` | Yes |
| `source_cidr` | 源 CIDR 块 | `string` | Yes |
| `destination_cidr` | 目标 CIDR 块 | `string` | Yes |
| `ip_protocol` | IP 协议（TCP、UDP 等） | `string` | Yes |
| `source_port` | 源端口 | `string` | Yes |
| `destination_port` | 目标端口 | `string` | Yes |
| `policy` | 策略动作（accept、drop） | `string` | Yes |
| `direction` | 流量方向（in、out） | `string` | Yes |
| `priority` | 规则优先级 | `number` | Yes |

## 输出参数

| Name | Description |
|------|-------------|
| `cloud_firewall_instance_id` | 云防火墙实例 ID |
| `cloud_firewall_instance_status` | 云防火墙实例状态 |
| `member_account_ids` | 由云防火墙管理的成员账号 ID 列表 |
| `internet_acl_rule_count` | 创建的互联网 ACL 规则数量 |
| `internet_protection_enabled` | 是否启用互联网边界防护 |
| `internet_protection_policy_id` | 互联网边界防护策略 ID |

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

### 使用目录配置

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  member_account_ids_dir = "./member_accounts"
  internet_acl_rules_dir = "./acl_rules"
}
```

### 互联网边界防护

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  enable_internet_protection        = true
  internet_protection_source         = "0.0.0.0/0"
  internet_protection_destination   = "10.0.0.0/8"
  internet_protection_application   = "HTTP"
  internet_protection_port          = "80"
}
```

### 互联网 ACL 规则

```hcl
module "cloud_firewall" {
  source = "./components/security/cloud-firewall"

  internet_acl_rules = [
    {
      description      = "允许来自互联网的 HTTPS"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "443"
      destination_port = "443"
      policy           = "accept"
      direction        = "in"
      priority         = 1
    },
    {
      description      = "阻止来自互联网的 SSH"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "10.0.1.0/24"
      ip_protocol      = "TCP"
      source_port      = "22"
      destination_port = "22"
      policy           = "drop"
      direction        = "in"
      priority         = 2
    }
  ]
}
```

## 注意事项

- 必须先创建云防火墙实例，然后才能添加成员账号或配置规则
- 成员账号添加到防火墙以实现集中管理
- 互联网边界防护为 SLB 资源提供保护
- 互联网 ACL 规则允许对流量进行细粒度控制
- 目录配置文件（JSON/YAML）与内联配置合并
- 当同时提供两者时，目录配置优先
- 规则唯一性由 description、source_cidr、destination_cidr、destination_port 和 direction 确定
- 可以为资源添加标签以便更好地组织
