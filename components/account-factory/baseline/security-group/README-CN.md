<div align="right">

**中文** | [English](README.md)

</div>

## 基线安全组组件

该组件用于在 VPC 中批量创建多个安全组（通过 `modules/security-group`）。

## 功能特性

- 为 VPC 基线批量创建多个安全组
- 支持直接配置和从外部配置文件加载两种方式
- 每个安全组可以有自己的规则和设置

## 前置要求

| 名称      | 版本      |
|-----------|-----------|
| terraform | >= 1.2   |
| alicloud  | >= 1.267.0 |

## Providers

| 名称         | 版本      |
|--------------|-----------|
| alicloud      | >= 1.267.0 |

## 使用示例

### 方法 1: 直接配置

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  security_groups = [
    {
      security_group_name = "sg-web-server"
      description         = "Web 服务器安全组"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "Production"
        Application = "Web"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "80/80"
          description = "允许来自任何地方的 HTTP 流量"
        },
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "443/443"
          description = "允许来自任何地方的 HTTPS 流量"
        }
      ]
    },
    {
      security_group_name = "sg-database"
      description         = "数据库服务器安全组"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "Production"
        Application = "Database"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "10.0.0.0/8"
          port_range  = "3306/3306"
          description = "允许来自 VPC 的 MySQL 流量"
        }
      ]
    }
  ]
}
```

### 方法 2: 从目录加载

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  security_group_dir_path = "./security-groups"
}
```

目录及其子目录中的所有 `.json`、`.yaml` 和 `.yml` 文件将被处理。每个文件必须包含单个安全组对象。

**示例安全组文件 (YAML) - 单个安全组对象:**

```yaml
# sg-web-server.yaml
security_group_name: sg-web-server
description: Web 服务器安全组
inner_access_policy: Accept
security_group_type: normal
tags:
  Environment: Production
  Application: Web
rules:
  - type: ingress
    ip_protocol: tcp
    policy: accept
    priority: 1
    cidr_ip: 0.0.0.0/0
    port_range: 80/80
    description: 允许来自任何地方的 HTTP 流量
  - type: ingress
    ip_protocol: tcp
    policy: accept
    priority: 1
    cidr_ip: 0.0.0.0/0
    port_range: 443/443
    description: 允许来自任何地方的 HTTPS 流量
```

### 方法 3: 组合配置

```hcl
module "baseline_security_groups" {
  source = "./components/account-factory/baseline/security-group"

  vpc_id = "vpc-xxxxxxxxxxxxx"

  # 直接配置的安全组
  security_groups = [
    {
      security_group_name = "sg-web-server"
      description         = "Web 服务器安全组"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "80/80"
          description = "允许来自任何地方的 HTTP 流量"
        }
      ]
    }
  ]

  # 从目录加载更多安全组
  security_group_dir_path = "./security-groups"
}
```

## 输入参数

| 名称 | 描述 | 类型 | 默认值 | 必填 |
|------|------|------|--------|------|
| `vpc_id` | 创建安全组的 VPC ID | `string` | - | 是 |
| `security_groups` | 安全组配置列表 | `list(object)` | `[]` | 否 |
| `security_group_dir_path` | 包含安全组配置文件的目录路径（YAML/JSON）。该目录中的每个文件必须包含单个安全组对象。文件将被加载并与 security_groups 合并 | `string` | `null` | 否 |

### security_groups 对象

`security_groups` 列表中的每个安全组可以包含以下结构：

| 名称 | 描述 | 类型 | 必填 |
|------|------|------|------|
| `security_group_name` | 安全组名称 | `string` | 是 |
| `description` | 安全组描述 | `string` | 否 |
| `inner_access_policy` | 内网访问控制策略。有效值：`Accept`、`Drop` | `string` | 否 |
| `resource_group_id` | 资源组 ID | `string` | 否 |
| `security_group_type` | 安全组类型。有效值：`normal`、`enterprise` | `string` | 否 |
| `tags` | 安全组标签 | `map(string)` | 否 |
| `rules` | 安全组规则列表 | `list(object)` | 否 |

### rules 对象

`rules` 列表中的每条规则可以包含以下结构：

| 名称 | 描述 | 类型 | 默认值 |
|------|------|------|--------|
| `type` | 规则类型。有效值：`ingress`、`egress` | `string` | - |
| `ip_protocol` | IP 协议。有效值：`tcp`、`udp`、`icmp`、`icmpv6`、`gre`、`all` | `string` | - |
| `policy` | 规则策略。有效值：`accept`、`drop` | `string` | `"accept"` |
| `priority` | 规则优先级（1-100） | `number` | `1` |
| `cidr_ip` | CIDR IP 地址 | `string` | - |
| `ipv6_cidr_ip` | IPv6 CIDR IP 地址 | `string` | - |
| `source_security_group_id` | 源安全组 ID | `string` | - |
| `source_group_owner_account` | 源安全组所属账号 | `string` | - |
| `prefix_list_id` | 前缀列表 ID | `string` | - |
| `port_range` | 端口范围（例如："80/80"、"80/90"、"-1/-1" 表示所有端口） | `string` | `"-1/-1"` |
| `nic_type` | 网络接口类型。有效值：`internet`、`intranet` | `string` | `"internet"` |
| `description` | 规则描述 | `string` | - |

## 输出

| 名称 | 描述 |
|------|------|
| `security_groups` | 所有创建的安全组的映射，以 security_group_name 为键，包含安全组详情和规则 |
| `security_group_ids` | 安全组 ID 映射，以 security_group_name 为键 |
| `security_group_names` | 安全组名称映射，以 security_group_name 为键 |

## 注意事项

- 安全组使用 `for_each` 创建，因此每个安全组名称在 VPC 内必须唯一
- 从目录加载时，每个文件必须包含单个安全组对象
- 直接配置和从目录加载的安全组会被合并，如果存在重复名称，直接配置的优先级更高
- 所有安全组都在由 `vpc_id` 指定的同一 VPC 中创建

