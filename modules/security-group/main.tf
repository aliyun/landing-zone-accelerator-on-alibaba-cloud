resource "alicloud_security_group" "this" {
  vpc_id              = var.vpc_id
  security_group_name = var.security_group_name
  description         = var.description
  inner_access_policy = var.inner_access_policy
  resource_group_id   = var.resource_group_id
  security_group_type = var.security_group_type
  tags                = var.tags
}

resource "alicloud_security_group_rule" "this" {
  count = length(var.rules)

  security_group_id          = alicloud_security_group.this.id
  type                       = var.rules[count.index].type
  ip_protocol                = var.rules[count.index].ip_protocol
  policy                     = var.rules[count.index].policy
  priority                   = var.rules[count.index].priority
  cidr_ip                    = var.rules[count.index].cidr_ip
  ipv6_cidr_ip               = var.rules[count.index].ipv6_cidr_ip
  source_security_group_id   = var.rules[count.index].source_security_group_id
  source_group_owner_account = var.rules[count.index].source_group_owner_account
  prefix_list_id             = var.rules[count.index].prefix_list_id
  port_range                 = var.rules[count.index].port_range
  nic_type                   = var.rules[count.index].nic_type
  description                = var.rules[count.index].description
}

