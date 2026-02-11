<div align="right">

**中文** | [English](README.md)

</div>

# 安全组模块

该模块用于创建和管理阿里云安全组及其规则。

## 功能特性

- 创建可配置参数的安全组
- 创建多个安全组规则（入站/出站）

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
| [alicloud_security_group.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource | 安全组 |
| [alicloud_security_group_rule.this](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource | 安全组规则 |

## 使用方法

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  description         = "Web 服务器安全组"
  security_group_type = "normal"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      nic_type    = "internet"
      description = "允许 HTTP 访问"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "443/443"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      nic_type    = "internet"
      description = "允许 HTTPS 访问"
    },
    {
      type        = "egress"
      ip_protocol = "all"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      description = "允许所有出站流量"
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `vpc_id` | 要创建安全组的 VPC ID | `string` | - | Yes | - |
| `security_group_name` | 安全组名称 | `string` | `null` | No | 2-128 个字符，以字母开头，不能以 http:// 或 https:// 开头 |
| `description` | 安全组描述 | `string` | `null` | No | 2-256 个字符，不能以 http:// 或 https:// 开头 |
| `inner_access_policy` | 安全组内网互通策略 | `string` | `null` | No | 必须为：`Accept` 或 `Drop` |
| `resource_group_id` | 安全组所属的资源组 ID | `string` | `null` | No | - |
| `security_group_type` | 安全组类型 | `string` | `"normal"` | No | 必须为：`normal` 或 `enterprise` |
| `tags` | 分配给安全组的标签映射 | `map(string)` | `{}` | No | - |
| `rules` | 要创建的安全组规则列表 | `list(object)` | `[]` | No | 见规则对象结构说明 |

### 规则对象结构

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `type` | 安全组规则类型 | `string` | - | Yes | 必须为：`ingress` 或 `egress` |
| `ip_protocol` | 安全组规则的传输层协议 | `string` | - | Yes | 必须为：`tcp`、`udp`、`icmp`、`icmpv6`、`gre`、`all` |
| `policy` | 安全组规则的动作 | `string` | `"accept"` | No | 必须为：`accept` 或 `drop` |
| `priority` | 安全组规则的优先级 | `number` | `1` | No | 必须在 1 到 100 之间 |
| `cidr_ip` | 目标 IP 地址范围（IPv4） | `string` | `null` | No | 不能与 `ipv6_cidr_ip` 同时设置 |
| `ipv6_cidr_ip` | 源 IPv6 CIDR 地址块 | `string` | `null` | No | 不能与 `cidr_ip` 同时设置 |
| `source_security_group_id` | 同一地域内的目标安全组 ID | `string` | `null` | No | 如果设置，`nic_type` 只能为 `intranet` |
| `source_group_owner_account` | 跨账号授权时目标安全组所属的阿里云账号 ID | `string` | `null` | No | 如果设置了 `cidr_ip` 则无效 |
| `prefix_list_id` | 源/目标前缀列表 ID | `string` | `null` | No | 如果设置了 `cidr_ip`、`source_security_group_id` 或 `ipv6_cidr_ip` 则会被忽略 |
| `port_range` | 与 IP 协议相关的端口号范围 | `string` | `"-1/-1"` | No | 对于 tcp/udp：1-65535，格式："起始/结束" |
| `nic_type` | 网络类型 | `string` | `"internet"` | No | 必须为：`internet` 或 `intranet` |
| `description` | 安全组规则的描述 | `string` | `null` | No | 1-512 个字符 |

## 输出参数

| Name | Description |
|------|-------------|
| `security_group_id` | 安全组 ID |
| `security_group_name` | 安全组名称 |
| `rule_ids` | 安全组规则 ID 列表 |
| `rules` | 安全组规则列表，包含 ID 和详细信息（包括 `rule_id` 和所有规则属性） |

## 使用示例

### 基础安全组

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  description         = "Web 服务器安全组"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}
```

### 包含多个规则的安全组

```hcl
module "security_group" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "app-sg"
  description         = "应用服务器安全组"
  security_group_type = "enterprise"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "8080/8080"
      cidr_ip     = "10.0.0.0/8"
      policy      = "accept"
      priority    = 1
      nic_type    = "intranet"
      description = "允许内网访问应用端口"
    },
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "192.168.1.0/24"
      policy      = "accept"
      priority    = 10
      nic_type    = "intranet"
      description = "允许从管理网络 SSH 访问"
    },
    {
      type        = "egress"
      ip_protocol = "all"
      cidr_ip     = "0.0.0.0/0"
      policy      = "accept"
      priority    = 1
      description = "允许所有出站流量"
    }
  ]
}
```

### 使用源安全组的安全组

```hcl
module "web_sg" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "web-sg"
  
  rules = [
    {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
  ]
}

module "app_sg" {
  source = "./modules/security-group"

  vpc_id              = "vpc-xxxxxxxxxxxxx"
  security_group_name = "app-sg"
  
  rules = [
    {
      type                     = "ingress"
      ip_protocol              = "tcp"
      port_range               = "8080/8080"
      source_security_group_id = module.web_sg.security_group_id
      nic_type                 = "intranet"
      description              = "允许来自 web 安全组的访问"
    }
  ]
}
```

## 注意事项

- `vpc_id` 是必填项，不能为空
- 安全组规则使用组合键来防止因顺序改变导致的资源重建
- 每个规则只能设置 `cidr_ip`、`ipv6_cidr_ip`、`source_security_group_id` 或 `prefix_list_id` 中的一个
- 当设置了 `source_security_group_id` 时，`nic_type` 只能为 `intranet`
- 对于 `tcp` 和 `udp` 协议，`port_range` 必须为 "起始/结束" 格式（例如："80/80" 或 "8000/9000"）
- 对于其他协议，`port_range` 应为 "-1/-1"
- `priority` 决定规则评估的顺序（数字越小优先级越高）
- `policy` 决定是接受还是丢弃匹配的流量

