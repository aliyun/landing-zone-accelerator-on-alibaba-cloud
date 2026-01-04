<div align="right">

**中文** | [English](README.md)

</div>

# WAFv3 组件

该组件用于创建和管理阿里云 Web 应用防火墙 v3（WAFv3）实例、防护模板和防护规则。

## 功能特性

- 创建 WAFv3 实例
- 创建可配置场景和类型的防护模板
- 在模板内创建防护规则
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
| [alicloud_wafv3_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_instance) | resource | WAFv3 实例 |
| [alicloud_wafv3_defense_template.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_defense_template) | resource | WAFv3 防护模板 |
| [alicloud_wafv3_defense_rule.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_defense_rule) | resource | WAFv3 防护规则 |

## 使用方法

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates = [
    {
      template_name   = "ip-blacklist-template"
      description     = "IP 黑名单模板"
      defense_scene   = "ip_blacklist"
      template_type   = "user_custom"
      template_origin = "custom"
      status          = 1
      resources       = ["alb-abc123", "alb-xyz789"]
    }
  ]

  rules = [
    {
      rule_name     = "block-malicious-ips"
      defense_scene = "ip_blacklist"
      template_id   = "ip-blacklist-template"
      rule_action   = "block"
      remote_addr   = ["192.168.1.100", "10.0.0.50"]
      status        = 1
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `templates` | 要创建的防护模板列表 | `list(object)` | `[]` | No | - |
| `rules` | 要配置的规则列表 | `list(object)` | `[]` | No | - |
| `templates_dir` | 包含模板配置文件的目录路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |
| `rules_dir` | 包含规则配置文件的目录路径 | `string` | `null` | No | 支持 .json, .yaml, .yml |

### templates 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `template_name` | 防护模板名称 | `string` | Yes | - |
| `description` | 防护模板描述 | `string` | No | `""` |
| `defense_scene` | 防护场景 | `string` | Yes | 必须是：`ip_blacklist`, `waf_group`, `cc`, `custom_acl`, `whitelist`, `waf_base_compliance`, `waf_base_sema` |
| `template_type` | 模板类型 | `string` | No | `"user_custom"` | 必须是：`system`, `user_custom`, `user_default` |
| `template_origin` | 模板来源 | `string` | No | `"custom"` | 必须是：`system`, `custom` |
| `status` | 防护模板状态 | `number` | No | `1` | 必须是：`0`（禁用）或 `1`（启用） |
| `resources` | 要绑定的受保护对象列表 | `set(string)` | No | `null` | 自 v1.257.0 版本起可用 |

### rules 对象

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `rule_name` | 防护规则名称 | `string` | Yes | - |
| `defense_scene` | 防护场景 | `string` | Yes | 必须是：`ip_blacklist`, `waf_group`, `cc`, `custom_acl`, `whitelist`, `waf_base_compliance`, `waf_base_sema` |
| `template_id` | 模板名称（用作 ID） | `string` | Yes | - |
| `rule_action` | 规则动作 | `string` | Yes | 必须是：`monitor` 或 `block` |
| `remote_addr` | 要阻止或监控的远程地址 | `list(string)` | Yes | - |
| `status` | 防护规则状态 | `number` | No | `1` | 必须是：`0`（禁用）或 `1`（启用） |
| `defense_origin` | 防护来源 | `string` | No | `"custom"` | 必须是：`custom`, `system` |

## 输出参数

| Name | Description |
|------|-------------|
| `instance_id` | WAFv3 实例 ID |
| `instance_status` | WAFv3 实例状态 |
| `template_ids` | 防护模板 ID（模板名称 => 防护模板 ID 的映射） |
| `rule_ids` | 防护规则 ID（规则名称 => 规则 ID 的映射） |

## 使用示例

### 基础 WAFv3 配置

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates = [
    {
      template_name = "basic-template"
      defense_scene = "waf_group"
    }
  ]
}
```

### WAFv3 带模板和规则

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates = [
    {
      template_name   = "ip-blacklist-template"
      description     = "用于阻止恶意 IP 的 IP 黑名单"
      defense_scene   = "ip_blacklist"
      template_type   = "user_custom"
      template_origin = "custom"
      status          = 1
      resources       = ["alb-abc123", "alb-xyz789"]
    },
    {
      template_name   = "cc-protection-template"
      description     = "CC 攻击防护"
      defense_scene   = "cc"
      template_type   = "user_custom"
      template_origin = "custom"
      status          = 1
    }
  ]

  rules = [
    {
      rule_name     = "block-malicious-ips"
      defense_scene = "ip_blacklist"
      template_id   = "ip-blacklist-template"
      rule_action   = "block"
      remote_addr   = ["192.168.1.100", "10.0.0.50"]
      status        = 1
    },
    {
      rule_name     = "monitor-suspicious-ips"
      defense_scene = "ip_blacklist"
      template_id   = "ip-blacklist-template"
      rule_action   = "monitor"
      remote_addr   = ["192.168.1.200"]
      status        = 1
    }
  ]
}
```

### 使用目录配置

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates_dir = "./templates"
  rules_dir     = "./rules"
}
```

## 注意事项

- 在创建防护规则之前必须先创建防护模板
- 目录配置文件（JSON/YAML）会与内联配置合并
- 当同时提供目录配置和内联配置时，目录配置优先
- 模板唯一性由 template_name 确定
- 规则唯一性由 rule_name 确定

