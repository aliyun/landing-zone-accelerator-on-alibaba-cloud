# Test cloud firewall component
# Cloud Firewall protects at the network boundary level (VPC, SLB, NAT Gateway)
module "cloud_firewall" {
  source = "../../../../components/security/cloud-firewall"

  # Cloud Firewall instance configuration
  create_cloud_firewall_instance = true
  cloud_firewall_instance_type   = "payg_version"
  cloud_firewall_bandwidth       = 100

  # Member account management (inline configuration)
  member_account_ids = []

  # Member account management (directory-based configuration)
  member_account_ids_dir = "${path.module}/member_accounts"

  # Internet ACL rules (inline configuration)
  internet_acl_rules = [
    {
      description      = "Allow HTTP traffic (configured inline)"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "0.0.0.0/0"
      ip_protocol      = "TCP"
      source_port      = "80"
      destination_port = "80/80"
      policy           = "accept"
      direction        = "in"
      priority         = 100
    },
    {
      description      = "Allow HTTPS traffic (configured inline)"
      source_cidr      = "0.0.0.0/0"
      destination_cidr = "0.0.0.0/0"
      ip_protocol      = "TCP"
      source_port      = "443"
      destination_port = "443/443"
      policy           = "accept"
      direction        = "in"
      priority         = 110
    }
  ]

  # Internet ACL rules (directory-based configuration)
  internet_acl_rules_dir = "${path.module}/internet_acl_rules"

  # Resource protection
  enable_internet_protection      = true
  internet_protection_source      = "0.0.0.0/0"
  internet_protection_destination = "0.0.0.0/0"
  internet_protection_application = "ANY"
  internet_protection_port        = "80/80"
}

output "cloud_firewall_instance_id" {
  value = module.cloud_firewall.cloud_firewall_instance_id
}

output "member_account_ids" {
  value = module.cloud_firewall.member_account_ids
}

output "internet_acl_rule_count" {
  value = module.cloud_firewall.internet_acl_rule_count
}

output "internet_protection_enabled" {
  value = module.cloud_firewall.internet_protection_enabled
}
