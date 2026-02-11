output "security_groups" {
  description = "Map of all created security groups, keyed by security_group_name."
  value = {
    for key, sg_module in module.security_group : key => {
      security_group_id   = sg_module.security_group_id
      security_group_name = sg_module.security_group_name
      vpc_id              = var.vpc_id
      rules               = sg_module.rules
      rule_ids            = sg_module.rule_ids
    }
  }
}

output "security_group_ids" {
  description = "Map of security group IDs, keyed by security_group_name."
  value = {
    for key, sg_module in module.security_group :
    key => sg_module.security_group_id
  }
}

