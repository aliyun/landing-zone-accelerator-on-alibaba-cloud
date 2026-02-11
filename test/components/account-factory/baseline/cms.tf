# CMS Service
module "cms_service" {
  source = "../../../../modules/cms-service"

  providers = {
    alicloud = alicloud.default
  }

  enable_enterprise = true
}

# CMS Alarm Contact
module "cms_alarm_contact" {
  source = "../../../../modules/cms-alarm-contact"

  providers = {
    alicloud = alicloud.default
  }

  alarm_contacts = [
    {
      name          = "admin"
      description   = "Primary administrator"
      channels_mail = "admin@example.com"
      channels_sms  = "<MOBILE>"
      lang          = "zh-cn"
    },
    {
      name          = "ops-team"
      description   = "Operations team"
      channels_mail = "ops@example.com"
      channels_sms  = "<MOBILE>"
      lang          = "en"
    }
  ]

  alarm_contact_groups = [
    {
      name              = "critical-alerts"
      contacts          = ["admin", "ops-team"]
      description       = "Critical alerts group"
      enable_subscribed = true
    }
  ]
}

# output "cms_service" {
#   description = "CMS service output"
#   value       = module.cms_service
# }

output "cms_alarm_contact" {
  description = "CMS alarm contact output"
  value       = module.cms_alarm_contact
}

