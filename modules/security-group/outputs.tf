output "security_group_id" {
  description = "The ID of the security group."
  value       = alicloud_security_group.this.id
}

output "security_group_name" {
  description = "The name of the security group."
  value       = alicloud_security_group.this.security_group_name
}

output "rule_ids" {
  description = "List of security group rule IDs."
  value       = [for rule in alicloud_security_group_rule.this : rule.security_group_rule_id]
}

output "rules" {
  description = "List of security group rules with their IDs."
  value = [
    for rule in alicloud_security_group_rule.this : {
      rule_id                    = rule.security_group_rule_id
      type                       = rule.type
      ip_protocol                = rule.ip_protocol
      policy                     = rule.policy
      priority                   = rule.priority
      cidr_ip                    = rule.cidr_ip
      ipv6_cidr_ip               = rule.ipv6_cidr_ip
      source_security_group_id   = rule.source_security_group_id
      source_group_owner_account = rule.source_group_owner_account
      prefix_list_id             = rule.prefix_list_id
      port_range                 = rule.port_range
      nic_type                   = rule.nic_type
      description                = rule.description
    }
  ]
}

