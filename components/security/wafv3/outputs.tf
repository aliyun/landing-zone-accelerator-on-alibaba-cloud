output "instance_id" {
  description = "The ID of the WAFv3 instance."
  value       = alicloud_wafv3_instance.default.instance_id
}

output "instance_status" {
  description = "The status of the WAFv3 instance."
  value       = alicloud_wafv3_instance.default.status
}

output "template_ids" {
  description = "The IDs of the defense templates."
  value = {
    for k, template in alicloud_wafv3_defense_template.default : template.defense_template_name => template.defense_template_id
  }
}

output "rule_ids" {
  description = "The IDs of the defense rules."
  value = {
    for k, rule in alicloud_wafv3_defense_rule.default : rule.rule_name => rule.rule_id
  }
}
