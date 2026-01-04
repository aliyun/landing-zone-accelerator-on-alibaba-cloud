output "aggregator_id" {
  description = "The ID of the config aggregator (existing or newly created)."
  value       = local.aggregator_id
}

output "compliance_pack_id" {
  description = "The ID of the compliance pack."
  value       = var.enable_compliance_pack ? alicloud_config_aggregate_compliance_pack.default[0].id : null
}

output "rule_ids" {
  description = "The IDs of all created config rules."
  value = concat(
    [for rule in alicloud_config_aggregate_config_rule.template : rule.id],
    [for rule in alicloud_config_aggregate_config_rule.custom_fc : rule.id]
  )
}

output "template_rule_count" {
  description = "Number of template-based rules created."
  value       = length(alicloud_config_aggregate_config_rule.template)
}

output "custom_fc_rule_count" {
  description = "Number of custom FC rules created."
  value       = length(alicloud_config_aggregate_config_rule.custom_fc)
}