# Contact Information
module "contact" {
  source = "../../../../components/account-factory/baseline/contact"

  providers = {
    alicloud = alicloud.default
  }

  contacts = [
    {
      name     = "ZhangSan"
      email    = "zhangsan@example.com"
      mobile   = "<MOBILE>"
      position = "Technical Director"
    },
    {
      name     = "LiSi"
      email    = "lisi@example.com"
      mobile   = "<MOBILE>"
      position = "Maintenance Director"
    }
  ]

  notification_recipient_mode = "append"
}

output "contact" {
  description = "Contact output"
  value       = module.contact
}

