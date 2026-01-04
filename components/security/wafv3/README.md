<div align="right">

**English** | [中文](README-CN.md)

</div>

# WAFv3 Component

This component creates and manages Alibaba Cloud Web Application Firewall v3 (WAFv3) instances, defense templates, and defense rules.

## Features

- Creates WAFv3 instance
- Creates defense templates with configurable scenes and types
- Creates defense rules within templates
- Supports directory-based and inline configuration merging
- Directory configuration takes precedence over inline configuration

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| alicloud | >= 1.262.1 |

## Providers

| Name | Version |
|------|---------|
| alicloud | >= 1.262.1 |

## Modules

No modules.

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_wafv3_instance.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_instance) | resource | WAFv3 instance |
| [alicloud_wafv3_defense_template.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_defense_template) | resource | WAFv3 defense templates |
| [alicloud_wafv3_defense_rule.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/wafv3_defense_rule) | resource | WAFv3 defense rules |

## Usage

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates = [
    {
      template_name   = "ip-blacklist-template"
      description     = "IP blacklist template"
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

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `templates` | List of defense templates to be created | `list(object)` | `[]` | No | - |
| `rules` | List of rules to be configured | `list(object)` | `[]` | No | - |
| `templates_dir` | Directory path containing template configuration files | `string` | `null` | No | Supports .json, .yaml, .yml |
| `rules_dir` | Directory path containing rule configuration files | `string` | `null` | No | Supports .json, .yaml, .yml |

### templates Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `template_name` | The name of the defense template | `string` | Yes | - |
| `description` | The description of the defense template | `string` | No | `""` |
| `defense_scene` | The defense scene | `string` | Yes | Must be: `ip_blacklist`, `waf_group`, `cc`, `custom_acl`, `whitelist`, `waf_base_compliance`, `waf_base_sema` |
| `template_type` | The template type | `string` | No | `"user_custom"` | Must be: `system`, `user_custom`, `user_default` |
| `template_origin` | The template origin | `string` | No | `"custom"` | Must be: `system`, `custom` |
| `status` | The status of the defense template | `number` | No | `1` | Must be: `0` (disabled) or `1` (enabled) |
| `resources` | The list of protected objects to be bound | `set(string)` | No | `null` | Available since v1.257.0 |

### rules Object

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `rule_name` | The name of the defense rule | `string` | Yes | - |
| `defense_scene` | The defense scene | `string` | Yes | Must be: `ip_blacklist`, `waf_group`, `cc`, `custom_acl`, `whitelist`, `waf_base_compliance`, `waf_base_sema` |
| `template_id` | The template name (used as ID) | `string` | Yes | - |
| `rule_action` | The action of the rule | `string` | Yes | Must be: `monitor` or `block` |
| `remote_addr` | The remote addresses to block or monitor | `list(string)` | Yes | - |
| `status` | The status of the defense rule | `number` | No | `1` | Must be: `0` (disabled) or `1` (enabled) |
| `defense_origin` | The defense origin | `string` | No | `"custom"` | Must be: `custom`, `system` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The ID of the WAFv3 instance |
| `instance_status` | The status of the WAFv3 instance |
| `template_ids` | The IDs of the defense templates (map of template_name => defense_template_id) |
| `rule_ids` | The IDs of the defense rules (map of rule_name => rule_id) |

## Examples

### Basic WAFv3 Setup

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

### WAFv3 with Templates and Rules

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates = [
    {
      template_name   = "ip-blacklist-template"
      description     = "IP blacklist for blocking malicious IPs"
      defense_scene   = "ip_blacklist"
      template_type   = "user_custom"
      template_origin = "custom"
      status          = 1
      resources       = ["alb-abc123", "alb-xyz789"]
    },
    {
      template_name   = "cc-protection-template"
      description     = "CC attack protection"
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

### With Directory Configuration

```hcl
module "wafv3" {
  source = "./components/security/wafv3"

  templates_dir = "./templates"
  rules_dir     = "./rules"
}
```

## Notes

- Defense templates must be created before creating defense rules
- Directory configuration files (JSON/YAML) are merged with inline configuration
- Directory configuration takes precedence when both are provided
- Template uniqueness is determined by template_name
- Rule uniqueness is determined by rule_name

