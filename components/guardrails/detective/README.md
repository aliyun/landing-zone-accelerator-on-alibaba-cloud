<div align="right">

**English** | [中文](README-CN.md)

</div>

# Guardrails Detective Component

This component creates and manages Alibaba Cloud Config detective guardrails (compliance audit rules) for detecting non-compliant resources.

## Features

- Creates Config aggregators (RD, FOLDER, or CUSTOM type)
- Creates compliance packs containing multiple rules
- Creates template-based rules (managed rules)
- Creates custom Function Compute-based rules
- Supports loading configurations from files (JSON/YAML) or inline definitions
- Optionally uses existing aggregators

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

| Name | Source | Description |
|------|--------|-------------|
| enable_config_service | ../../../modules/config-configuration-recorder | Enable Config service |

## Resources

| Name | Type | Description |
|------|------|-------------|
| [alicloud_config_aggregator.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregator) | resource | Config aggregator (optional, when not using existing) |
| [alicloud_config_aggregate_config_rule.template](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_config_rule) | resource | Template-based config rules |
| [alicloud_config_aggregate_config_rule.custom_fc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_config_rule) | resource | Custom Function Compute-based config rules |
| [alicloud_config_aggregate_compliance_pack.default](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/config_aggregate_compliance_pack) | resource | Compliance pack (optional) |

## Usage

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  aggregator_name        = "enterprise"
  aggregator_description = "Enterprise Config Aggregator"
  aggregator_type        = "RD"
  
  enable_compliance_pack = true
  compliance_pack_name   = "LandingZoneCompliancePack"
  risk_level            = 1

  template_based_rules = [
    {
      rule_name          = "ECSInstanceNoPublicIP"
      description        = "ECS instances should not have public IP"
      source_template_id = "ecs-instance-no-public-ip"
      risk_level         = 1
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required | Constraints |
|------|-------------|------|---------|----------|-------------|
| `use_existing_aggregator` | Whether to use an existing config aggregator | `bool` | `false` | No | - |
| `existing_aggregator_id` | The ID of existing aggregator to use | `string` | `null` | No | Required when `use_existing_aggregator = true` |
| `aggregator_name` | The name of the config aggregator | `string` | `"enterprise"` | No | 1-128 characters |
| `aggregator_description` | The description of the config aggregator | `string` | `""` | No | 1-256 characters if not empty |
| `aggregator_type` | The type of the config aggregator | `string` | `"RD"` | No | Must be: `RD`, `FOLDER`, or `CUSTOM` |
| `aggregator_folder_id` | The folder ID for FOLDER type aggregator | `string` | `null` | No | Required when `aggregator_type = "FOLDER"` |
| `aggregator_accounts` | List of accounts for CUSTOM type aggregator | `list(object)` | `[]` | No | Required when `aggregator_type = "CUSTOM"` |
| `aggregator_accounts_dir` | Directory path containing aggregator account config files | `string` | `null` | No | JSON/YAML files, merged with `aggregator_accounts` |
| `enable_compliance_pack` | Whether to enable compliance pack | `bool` | `true` | No | - |
| `compliance_pack_name` | The name of the compliance pack | `string` | `"LandingZoneCompliancePack"` | No | 1-128 characters |
| `risk_level` | The risk level of the compliance pack | `number` | `1` | No | Must be: 1, 2, 3, or 4 |
| `template_based_rules` | List of template-based config rules | `list(object)` | `[]` | No | See template rule structure below |
| `template_based_rules_dir` | Directory path containing template rule config files | `string` | `null` | No | JSON/YAML files, merged with `template_based_rules` |
| `custom_fc_rules` | List of custom Function Compute-based rules | `list(object)` | `[]` | No | See custom FC rule structure below |

### Template-Based Rule Object Structure

Each rule in `template_based_rules` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `rule_name` | `string` | - | Yes | Rule name | 1-128 characters |
| `description` | `string` | - | Yes | Rule description | - |
| `source_template_id` | `string` | - | Yes | Source template identifier | - |
| `input_parameters` | `map(string)` | `{}` | No | Input parameters for the rule | - |
| `maximum_execution_frequency` | `string` | `"TwentyFour_Hours"` | No | Maximum execution frequency | Must be: `One_Hour`, `Three_Hours`, `Six_Hours`, `Twelve_Hours`, `TwentyFour_Hours` |
| `scope_compliance_resource_types` | `list(string)` | `[]` | No | Resource types in scope | - |
| `risk_level` | `number` | `1` | No | Risk level | 1-4 |
| `trigger_types` | `string` | `"ConfigurationItemChangeNotification"` | No | Trigger types | - |
| `tag_key_scope` | `string` | `null` | No | Tag key scope | - |
| `tag_value_scope` | `string` | `null` | No | Tag value scope | - |
| `region_ids_scope` | `string` | `null` | No | Region IDs scope | - |
| `exclude_resource_ids_scope` | `string` | `null` | No | Excluded resource IDs | - |
| `resource_group_ids_scope` | `list(string)` | `[]` | No | Resource group IDs scope | - |
| `add_to_compliance_pack` | `bool` | `true` | No | Whether to add to compliance pack | - |

### Custom FC Rule Object Structure

Each rule in `custom_fc_rules` must have the following structure:

| Field | Type | Default | Required | Description | Constraints |
|-------|------|---------|----------|-------------|-------------|
| `rule_name` | `string` | - | Yes | Rule name | 1-128 characters |
| `description` | `string` | - | Yes | Rule description | - |
| `source_arn` | `string` | - | Yes | Function Compute function ARN | Valid FC function ARN format |
| `input_parameters` | `map(string)` | `{}` | No | Input parameters | - |
| `maximum_execution_frequency` | `string` | `"TwentyFour_Hours"` | No | Maximum execution frequency | Must be: `One_Hour`, `Three_Hours`, `Six_Hours`, `Twelve_Hours`, `TwentyFour_Hours` |
| `scope_compliance_resource_types` | `list(string)` | `[]` | No | Resource types in scope | - |
| `risk_level` | `number` | `1` | No | Risk level | 1-4 |
| `trigger_types` | `string` | `"ConfigurationItemChangeNotification"` | No | Trigger types | - |
| `tag_key_scope` | `string` | `null` | No | Tag key scope | - |
| `tag_value_scope` | `string` | `null` | No | Tag value scope | - |
| `region_ids_scope` | `string` | `null` | No | Region IDs scope | - |
| `exclude_resource_ids_scope` | `string` | `null` | No | Excluded resource IDs | - |
| `resource_group_ids_scope` | `list(string)` | `[]` | No | Resource group IDs scope | - |
| `add_to_compliance_pack` | `bool` | `true` | No | Whether to add to compliance pack | - |

## Outputs

| Name | Description |
|------|-------------|
| `aggregator_id` | The ID of the config aggregator (existing or newly created) |
| `compliance_pack_id` | The ID of the compliance pack |
| `rule_ids` | The IDs of all created config rules |
| `template_rule_count` | Number of template-based rules created |
| `custom_fc_rule_count` | Number of custom FC rules created |

## Examples

### Basic Detective Guardrails

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  aggregator_name        = "enterprise"
  aggregator_type        = "RD"
  enable_compliance_pack = true
  
  template_based_rules = [
    {
      rule_name          = "ECSInstanceNoPublicIP"
      description        = "ECS instances should not have public IP"
      source_template_id = "ecs-instance-no-public-ip"
      risk_level         = 1
    }
  ]
}
```

### Use Existing Aggregator

```hcl
module "detective_guardrails" {
  source = "./components/guardrails/detective"

  use_existing_aggregator = true
  existing_aggregator_id  = "ca-xxxxxxxxxxxxxxxxx"
  
  enable_compliance_pack = true
  template_based_rules = [
    {
      rule_name          = "Rule1"
      description        = "Rule description"
      source_template_id = "template-id"
    }
  ]
}
```

### Custom Aggregator Type

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

## Notes

- Config service is automatically enabled before creating aggregator
- RD type aggregator automatically includes all accounts in the resource directory
- Only one RD type aggregator can exist per account
- File configurations take priority over inline configurations for matching names
- Rules can be added to compliance pack by setting `add_to_compliance_pack = true`
- Custom FC rules require valid Function Compute function ARN
