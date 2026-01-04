terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "~> 1.262.1"
    }
  }
}

# Provider configuration
provider "alicloud" {
  region = "cn-hangzhou"
}

# Test WAFv3 component
module "wafv3" {
  source = "../../../../components/security/wafv3"

  templates = [
    {
      template_name   = "test-template-inline"
      description     = "Test defense template inline"
      defense_scene   = "ip_blacklist"
      template_type   = "user_custom"
      template_origin = "custom"
      status          = 1
    }
  ]

  rules = [
    {
      rule_name      = "ip-blacklist-rule-inline"
      defense_scene  = "ip_blacklist"
      template_id    = "test-template-inline"
      rule_action    = "monitor"
      remote_addr    = ["1.1.1.1", "2.2.2.2"]
      status         = 1
      defense_origin = "custom"
    }
  ]
  templates_dir = "${path.module}/templates"
  rules_dir     = "${path.module}/rules"
}

