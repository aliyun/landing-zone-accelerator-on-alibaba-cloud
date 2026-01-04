# Merge directory and inline configurations
# Directory configurations take precedence over inline configurations
locals {
  aggregator_accounts_files = var.aggregator_accounts_dir != null ? fileset(var.aggregator_accounts_dir, "*.{json,yaml,yml}") : []
  aggregator_accounts_file_configs = [
    for file in local.aggregator_accounts_files :
    endswith(file, ".json") ? jsondecode(file("${var.aggregator_accounts_dir}/${file}")) : yamldecode(file("${var.aggregator_accounts_dir}/${file}"))
  ]
  all_aggregator_accounts = concat(
    local.aggregator_accounts_file_configs,
    [for a in var.aggregator_accounts : a if !contains([for fc in local.aggregator_accounts_file_configs : fc.account_id], a.account_id)]
  )

  template_based_rules_files = var.template_based_rules_dir != null ? fileset(var.template_based_rules_dir, "*.{json,yaml,yml}") : []
  template_based_rules_file_configs_raw = [
    for file in local.template_based_rules_files :
    endswith(file, ".json") ? jsondecode(file("${var.template_based_rules_dir}/${file}")) : yamldecode(file("${var.template_based_rules_dir}/${file}"))
  ]
  template_based_rules_file_configs = flatten([
    for cfg in local.template_based_rules_file_configs_raw : 
    try(cfg[*], cfg)
  ])
  all_template_based_rules = concat(
    local.template_based_rules_file_configs,
    [for r in var.template_based_rules : r if !contains([for fc in local.template_based_rules_file_configs : fc.rule_name], r.rule_name)]
  )
}

# Enable Config service
module "enable_config_service" {
  source = "../../../modules/config-configuration-recorder"
}

# Create Config aggregator
# Note: Refer to components/log-archive/config to avoid duplicates
resource "alicloud_config_aggregator" "default" {
  count           = var.use_existing_aggregator ? 0 : 1
  aggregator_name = var.aggregator_name
  aggregator_type = var.aggregator_type
  description     = var.aggregator_description
  folder_id       = var.aggregator_type == "FOLDER" ? var.aggregator_folder_id : null

  dynamic "aggregator_accounts" {
    for_each = var.aggregator_type == "CUSTOM" ? local.all_aggregator_accounts : []
    content {
      account_id   = aggregator_accounts.value.account_id
      account_name = aggregator_accounts.value.account_name
      account_type = "ResourceDirectory"
    }
  }

  depends_on = [module.enable_config_service]
}

# Get aggregator ID (use existing or create new)
locals {
  aggregator_id = var.use_existing_aggregator ? var.existing_aggregator_id : alicloud_config_aggregator.default[0].id
}

# Create template-based Config rules
resource "alicloud_config_aggregate_config_rule" "template" {
  for_each = {
    for rule in local.all_template_based_rules : rule.rule_name => rule
  }

  aggregate_config_rule_name  = each.value.rule_name
  description                 = each.value.description
  source_identifier           = each.value.source_template_id
  source_owner                = "ALIYUN"
  input_parameters            = try(each.value.input_parameters, {})
  maximum_execution_frequency = try(each.value.maximum_execution_frequency, "TwentyFour_Hours")
  resource_types_scope        = try(each.value.scope_compliance_resource_types, [])
  risk_level                  = try(each.value.risk_level, 1)
  config_rule_trigger_types   = try(each.value.trigger_types, "ConfigurationItemChangeNotification")
  aggregator_id               = local.aggregator_id
  tag_key_scope               = try(each.value.tag_key_scope, null)
  tag_value_scope             = try(each.value.tag_value_scope, null)
  region_ids_scope            = try(each.value.region_ids_scope, null)
  exclude_resource_ids_scope  = try(each.value.exclude_resource_ids_scope, null)
  resource_group_ids_scope    = try(length(each.value.resource_group_ids_scope) > 0 ? join(",", each.value.resource_group_ids_scope) : null, null)
}

# Create Function Compute custom rules
resource "alicloud_config_aggregate_config_rule" "custom_fc" {
  for_each = {
    for rule in var.custom_fc_rules : rule.rule_name => rule
  }

  aggregate_config_rule_name  = each.value.rule_name
  description                 = each.value.description
  source_identifier           = each.value.source_arn
  source_owner                = "CUSTOM_FC"
  input_parameters            = each.value.input_parameters
  maximum_execution_frequency = each.value.maximum_execution_frequency
  resource_types_scope        = each.value.scope_compliance_resource_types
  risk_level                  = each.value.risk_level
  config_rule_trigger_types   = each.value.trigger_types
  aggregator_id               = local.aggregator_id
  tag_key_scope               = each.value.tag_key_scope
  tag_value_scope             = each.value.tag_value_scope
  region_ids_scope            = each.value.region_ids_scope
  exclude_resource_ids_scope  = each.value.exclude_resource_ids_scope
  resource_group_ids_scope    = length(each.value.resource_group_ids_scope) > 0 ? join(",", each.value.resource_group_ids_scope) : null
}

# Create compliance pack (optional)
resource "alicloud_config_aggregate_compliance_pack" "default" {
  count                          = var.enable_compliance_pack ? 1 : 0
  aggregate_compliance_pack_name = var.compliance_pack_name
  description                    = "Compliance pack for Landing Zone"
  risk_level                     = var.risk_level
  aggregator_id                  = local.aggregator_id

  # Add rules to compliance pack (only rules with add_to_compliance_pack = true)
  dynamic "config_rule_ids" {
    for_each = var.enable_compliance_pack ? concat(
      [
        for rule in local.all_template_based_rules : alicloud_config_aggregate_config_rule.template[rule.rule_name].config_rule_id
        if try(rule.add_to_compliance_pack, true)
      ],
      [
        for rule in var.custom_fc_rules : alicloud_config_aggregate_config_rule.custom_fc[rule.rule_name].config_rule_id
        if try(rule.add_to_compliance_pack, true)
      ]
    ) : []

    content {
      config_rule_id = config_rule_ids.value
    }
  }

  depends_on = [
    alicloud_config_aggregate_config_rule.template,
    alicloud_config_aggregate_config_rule.custom_fc
  ]
}