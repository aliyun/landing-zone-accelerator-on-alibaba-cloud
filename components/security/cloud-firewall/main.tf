# Merge directory and inline configurations
# Directory configurations take precedence over inline configurations
locals {
  member_account_files = var.member_account_ids_dir != null ? fileset(var.member_account_ids_dir, "*.{json,yaml,yml}") : []
  member_account_file_configs_raw = [
    for file in local.member_account_files :
    endswith(file, ".json") ? jsondecode(file("${var.member_account_ids_dir}/${file}")) : yamldecode(file("${var.member_account_ids_dir}/${file}"))
  ]
  member_account_file_configs = flatten([
    for cfg in local.member_account_file_configs_raw : 
    try(cfg[*], cfg)
  ])
  all_member_account_ids = concat(
    [for cfg in local.member_account_file_configs : cfg.account_id],
    [for id in var.member_account_ids : id if !contains([for cfg in local.member_account_file_configs : cfg.account_id], id)]
  )

  internet_acl_rules_files = var.internet_acl_rules_dir != null ? fileset(var.internet_acl_rules_dir, "*.{json,yaml,yml}") : []
  internet_acl_rules_file_configs_raw = [
    for file in local.internet_acl_rules_files :
    endswith(file, ".json") ? jsondecode(file("${var.internet_acl_rules_dir}/${file}")) : yamldecode(file("${var.internet_acl_rules_dir}/${file}"))
  ]
  internet_acl_rules_file_configs = flatten([
    for cfg in local.internet_acl_rules_file_configs_raw : 
    try(cfg[*], cfg)
  ])
  all_internet_acl_rules = concat(
    local.internet_acl_rules_file_configs,
    [for r in var.internet_acl_rules : r if !contains([for fc in local.internet_acl_rules_file_configs : try(fc.description, "")], try(r.description, ""))]
  )
}

# Enable Cloud Firewall service
resource "alicloud_cloud_firewall_instance" "main" {
  count = var.create_cloud_firewall_instance ? 1 : 0

  payment_type = var.cloud_firewall_payment_type
  spec         = var.cloud_firewall_instance_type
  band_width   = var.cloud_firewall_bandwidth
}

# Configure internet boundary protection for SLB resources
resource "alicloud_cloud_firewall_control_policy" "internet_protection" {
  count = var.enable_internet_protection ? 1 : 0
  
  depends_on = [alicloud_cloud_firewall_instance.main]
  
  description      = "Internet boundary protection for SLB resources"
  source           = var.internet_protection_source
  source_type      = "net"
  destination      = var.internet_protection_destination
  destination_type = "net"
  proto            = "TCP"
  dest_port        = var.internet_protection_port
  acl_action       = "accept"
  direction        = "in"
  application_name = var.internet_protection_application
}

# Add member accounts to Cloud Firewall
resource "alicloud_cloud_firewall_instance_member" "members" {

  depends_on = [alicloud_cloud_firewall_instance.main]

  for_each = {
    for account_id in local.all_member_account_ids : account_id => account_id
  }

  member_uid = each.value
}

# Configure internet boundary firewall rules
resource "alicloud_cloud_firewall_control_policy" "internet" {
  depends_on = [alicloud_cloud_firewall_instance.main]

  for_each = {
    for rule in local.all_internet_acl_rules : "${rule.description}-${rule.source_cidr}-${rule.destination_cidr}-${rule.destination_port}-${rule.direction}" => rule
  }

  description      = each.value.description
  source           = each.value.source_cidr
  source_type      = var.control_policy_source_type
  destination      = each.value.destination_cidr
  destination_type = var.control_policy_destination_type
  proto            = each.value.ip_protocol
  dest_port        = each.value.destination_port
  acl_action       = each.value.policy
  direction        = each.value.direction
  application_name = var.control_policy_application_name
}