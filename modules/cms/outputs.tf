output "basic_cloud_monitor_service_id" {
  description = "The ID of the Basic CloudMonitor service"
  value       = alicloud_cloud_monitor_service_basic_public.basic.id
}

output "enterprise_cloud_monitor_service_id" {
  description = "The ID of the Enterprise CloudMonitor service (null if not enabled)"
  value       = length(alicloud_cloud_monitor_service_enterprise_public.enterprise) > 0 ? alicloud_cloud_monitor_service_enterprise_public.enterprise[0].id : null
}

output "alarm_contacts" {
  description = "Information about created alarm contacts"
  value = [
    for name, contact in alicloud_cms_alarm_contact.contacts : {
      id                     = contact.id
      name                   = contact.alarm_contact_name
      description            = contact.describe
      channels_aliim         = contact.channels_aliim
      channels_ding_web_hook = contact.channels_ding_web_hook
      channels_mail          = contact.channels_mail
      channels_sms           = contact.channels_sms
      lang                   = contact.lang
    }
  ]
}

output "alarm_contact_groups" {
  description = "Information about created alarm contact groups"
  value = [
    for name, group in alicloud_cms_alarm_contact_group.groups : {
      id                = group.id
      name              = group.alarm_contact_group_name
      contacts          = group.contacts
      description       = group.describe
      enable_subscribed = try(group.enable_subscribed, null)
    }
  ]
}

output "contact_id_map" {
  description = "Mapping of contact names to their IDs for easy reference"
  value = {
    for name, contact in alicloud_cms_alarm_contact.contacts :
    name => contact.id
  }
}
