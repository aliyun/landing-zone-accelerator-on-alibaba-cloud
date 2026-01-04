<div align="right">

**中文** | [English](README.md)

</div>

# Guardrails Detective 组件

该组件用于创建和管理阿里云配置审计检测性防护规则（合规审计规则），用于检测不合规的资源。

## 功能特性

- 创建配置聚合器（RD、FOLDER 或 CUSTOM 类型）
- 创建包含多个规则的合规包
- 创建基于模板的规则（托管规则）
- 创建基于函数计算的自定义规则
- 支持从文件（JSON/YAML）加载配置或内联定义
- 可选使用现有聚合器

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

| Name | Source | Description |
|------|--------|-------------|
| enable_config_service | ../../../modules/config-configuration-recorder | 开通配置审计服务 |

## 创建的资源

| Name | Type | Description |
|------|------|-------------|
| [alicloud_config_aggregator.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregator) | resource | 配置聚合器（可选，当不使用现有聚合器时） |
| [alicloud_config_aggregate_config_rule.template](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_config_rule) | resource | 基于模板的配置规则 |
| [alicloud_config_aggregate_config_rule.custom_fc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_config_rule) | resource | 基于函数计算的自定义配置规则 |
| [alicloud_config_aggregate_compliance_pack.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_compliance_pack) | resource | 合规包（可选） |

## 使用方法

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  aggregator_name        = "enterprise"
  aggregator_description = "企业配置聚合器"
  aggregator_type        = "RD"
  
  enable_compliance_pack = true
  compliance_pack_name   = "LandingZone合规包"
  risk_level            = 1

  template_based_rules = [
    {
      rule_name          = "ECSInstanceNoPublicIP"
      description        = "ECS 实例不应有公网 IP"
      source_template_id = "ecs-instance-no-public-ip"
      risk_level         = 1
    }
  ]
}
```

## 输入参数

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `use_existing_aggregator` | 是否使用现有配置聚合器 | `bool` | `false` | No | - |
| `existing_aggregator_id` | 要使用的现有聚合器 ID | `string` | `null` | No | 当 `use_existing_aggregator = true` 时必需 |
| `aggregator_name` | 配置聚合器名称 | `string` | `"enterprise"` | No | 1-128 个字符 |
| `aggregator_description` | 配置聚合器描述 | `string` | `""` | No | 非空时 1-256 个字符 |
| `aggregator_type` | 配置聚合器类型 | `string` | `"RD"` | No | 必须是：`RD`、`FOLDER` 或 `CUSTOM` |
| `aggregator_folder_id` | FOLDER 类型聚合器的文件夹 ID | `string` | `null` | No | 当 `aggregator_type = "FOLDER"` 时必需 |
| `aggregator_accounts` | CUSTOM 类型聚合器的账号列表 | `list(object)` | `[]` | No | 当 `aggregator_type = "CUSTOM"` 时必需 |
| `aggregator_accounts_dir` | 包含聚合账号配置文件的目录路径 | `string` | `null` | No | JSON/YAML 文件，与 `aggregator_accounts` 合并 |
| `enable_compliance_pack` | 是否启用合规包 | `bool` | `true` | No | - |
| `compliance_pack_name` | 合规包名称 | `string` | `"LandingZoneCompliancePack"` | No | 1-128 个字符 |
| `risk_level` | 合规包风险等级 | `number` | `1` | No | 必须是：1、2、3 或 4 |
| `template_based_rules` | 基于模板的配置规则列表 | `list(object)` | `[]` | No | 参见模板规则结构 |
| `template_based_rules_dir` | 包含模板规则配置文件的目录路径 | `string` | `null` | No | JSON/YAML 文件，与 `template_based_rules` 合并 |
| `custom_fc_rules` | 基于函数计算的自定义规则列表 | `list(object)` | `[]` | No | 参见自定义 FC 规则结构 |

### 基于模板的规则对象结构

`template_based_rules` 中每个规则必须具有以下结构：

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `rule_name` | `string` | - | Yes | 规则名称 | 1-128 个字符 |
| `description` | `string` | - | Yes | 规则描述 | - |
| `source_template_id` | `string` | - | Yes | 源模板标识符 | - |
| `input_parameters` | `map(string)` | `{}` | No | 规则的输入参数 | - |
| `maximum_execution_frequency` | `string` | `"TwentyFour_Hours"` | No | 最大执行频率 | 必须是：`One_Hour`、`Three_Hours`、`Six_Hours`、`Twelve_Hours`、`TwentyFour_Hours` |
| `scope_compliance_resource_types` | `list(string)` | `[]` | No | 范围内的资源类型 | - |
| `risk_level` | `number` | `1` | No | 风险等级 | 1-4 |
| `trigger_types` | `string` | `"ConfigurationItemChangeNotification"` | No | 触发类型 | - |
| `tag_key_scope` | `string` | `null` | No | 标签键范围 | - |
| `tag_value_scope` | `string` | `null` | No | 标签值范围 | - |
| `region_ids_scope` | `string` | `null` | No | 地域 ID 范围 | - |
| `exclude_resource_ids_scope` | `string` | `null` | No | 排除的资源 ID | - |
| `resource_group_ids_scope` | `list(string)` | `[]` | No | 资源组 ID 范围 | - |
| `add_to_compliance_pack` | `bool` | `true` | No | 是否添加到合规包 | - |

### 自定义 FC 规则对象结构

`custom_fc_rules` 中每个规则必须具有以下结构：

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `rule_name` | `string` | - | Yes | 规则名称 | 1-128 个字符 |
| `description` | `string` | - | Yes | 规则描述 | - |
| `source_arn` | `string` | - | Yes | 函数计算函数 ARN | 有效的 FC 函数 ARN 格式 |
| `input_parameters` | `map(string)` | `{}` | No | 输入参数 | - |
| `maximum_execution_frequency` | `string` | `"TwentyFour_Hours"` | No | 最大执行频率 | 必须是：`One_Hour`、`Three_Hours`、`Six_Hours`、`Twelve_Hours`、`TwentyFour_Hours` |
| `scope_compliance_resource_types` | `list(string)` | `[]` | No | 范围内的资源类型 | - |
| `risk_level` | `number` | `1` | No | 风险等级 | 1-4 |
| `trigger_types` | `string` | `"ConfigurationItemChangeNotification"` | No | 触发类型 | - |
| `tag_key_scope` | `string` | `null` | No | 标签键范围 | - |
| `tag_value_scope` | `string` | `null` | No | 标签值范围 | - |
| `region_ids_scope` | `string` | `null` | No | 地域 ID 范围 | - |
| `exclude_resource_ids_scope` | `string` | `null` | No | 排除的资源 ID | - |
| `resource_group_ids_scope` | `list(string)` | `[]` | No | 资源组 ID 范围 | - |
| `add_to_compliance_pack` | `bool` | `true` | No | 是否添加到合规包 | - |

## 输出参数

| Name | Description |
|------|-------------|
| `aggregator_id` | 配置聚合器 ID（现有或新创建的） |
| `compliance_pack_id` | 合规包 ID |
| `rule_ids` | 所有创建的配置规则 ID 列表 |
| `template_rule_count` | 创建的基于模板的规则数量 |
| `custom_fc_rule_count` | 创建的自定义 FC 规则数量 |

## 使用示例

### 基础检测性防护规则

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  aggregator_name        = "enterprise"
  aggregator_type        = "RD"
  enable_compliance_pack = true
  
  template_based_rules = [
    {
      rule_name          = "ECSInstanceNoPublicIP"
      description        = "ECS 实例不应有公网 IP"
      source_template_id = "ecs-instance-no-public-ip"
      risk_level         = 1
    }
  ]
}
```

### 使用现有聚合器

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  use_existing_aggregator = true
  existing_aggregator_id  = "ca-xxxxxxxxxxxxxxxxx"
  
  enable_compliance_pack = true
  template_based_rules = [
    {
      rule_name          = "Rule1"
      description        = "规则描述"
      source_template_id = "template-id"
    }
  ]
}
```

### 自定义聚合器类型

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  aggregator_name = "custom-aggregator"
  aggregator_type = "CUSTOM"
  
  aggregator_accounts = [
    {
      account_id   = "123456789012"
      account_name = "account-1"
    }
  ]
  
  template_based_rules = [...]
}
```

## 注意事项

- 创建聚合器前会自动开通配置审计服务
- RD 类型聚合器自动包含资源目录中的所有账号
- 每个账号只能有一个 RD 类型聚合器
- 文件配置优先于内联配置（同名时）
- 通过设置 `add_to_compliance_pack = true` 可将规则添加到合规包
- 自定义 FC 规则需要有效的函数计算函数 ARN

