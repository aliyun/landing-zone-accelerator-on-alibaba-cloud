# Merge directory and inline configurations
# Directory configurations take precedence over inline configurations
locals {
  templates_files = var.templates_dir != null ? fileset(var.templates_dir, "*.{json,yaml,yml}") : []
  templates_file_configs = [
    for file in local.templates_files :
    endswith(file, ".json") ? jsondecode(file("${var.templates_dir}/${file}")) : yamldecode(file("${var.templates_dir}/${file}"))
  ]
  all_templates = concat(
    local.templates_file_configs,
    [for t in var.templates : t if !contains([for fc in local.templates_file_configs : fc.template_name], t.template_name)]
  )

  rules_files = var.rules_dir != null ? fileset(var.rules_dir, "*.{json,yaml,yml}") : []
  rules_file_configs = [
    for file in local.rules_files :
    endswith(file, ".json") ? jsondecode(file("${var.rules_dir}/${file}")) : yamldecode(file("${var.rules_dir}/${file}"))
  ]
  all_rules = concat(
    local.rules_file_configs,
    [for r in var.rules : r if !contains([for fc in local.rules_file_configs : fc.rule_name], r.rule_name)]
  )
}

# Create WAFv3 instance
resource "alicloud_wafv3_instance" "default" {
}

# Create WAFv3 defense templates
resource "alicloud_wafv3_defense_template" "default" {
  for_each = { for template in local.all_templates : template.template_name => template }

  instance_id           = alicloud_wafv3_instance.default.id
  defense_template_name = each.value.template_name
  description           = try(each.value.description, "")
  defense_scene         = each.value.defense_scene
  template_type         = try(each.value.template_type, "user_custom")
  template_origin       = try(each.value.template_origin, "custom")
  status                = try(each.value.status, 1)
  resources             = try(each.value.resources, null)
}

# Create WAFv3 defense rules
resource "alicloud_wafv3_defense_rule" "default" {
  for_each = { for rule in local.all_rules : rule.rule_name => rule }

  instance_id    = alicloud_wafv3_instance.default.id
  template_id    = alicloud_wafv3_defense_template.default[each.value.template_id].defense_template_id
  rule_name      = each.value.rule_name
  defense_scene  = each.value.defense_scene
  defense_type   = "template"
  rule_status    = try(each.value.status, 1)
  defense_origin = try(each.value.defense_origin, "custom")

  config {
    rule_action = each.value.rule_action
    remote_addr = each.value.remote_addr
  }
}
