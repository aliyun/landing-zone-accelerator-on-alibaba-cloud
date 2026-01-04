# Enable CloudMonitor Basic edition
resource "alicloud_cloud_monitor_service_basic_public" "basic" {
}

# Create CloudMonitor service linked role
resource "alicloud_resource_manager_service_linked_role" "slr" {
  service_name = "cloudmonitor.aliyuncs.com"
}

# Enable CloudMonitor Enterprise edition (optional)
resource "alicloud_cloud_monitor_service_enterprise_public" "enterprise" {
  count = var.enable_enterprise ? 1 : 0
}

# Create alarm contacts
resource "alicloud_cms_alarm_contact" "contacts" {
  for_each = {
    for contact in var.alarm_contacts :
    contact.name => contact
  }

  alarm_contact_name     = each.value.name
  describe               = each.value.description
  channels_aliim         = each.value.channels_aliim
  channels_ding_web_hook = each.value.channels_ding_web_hook
  channels_mail          = each.value.channels_mail
  channels_sms           = each.value.channels_sms
  lang                   = each.value.lang
}

# Create alarm contact groups
resource "alicloud_cms_alarm_contact_group" "groups" {
  for_each = {
    for group in var.alarm_contact_groups :
    group.name => group
  }

  alarm_contact_group_name = each.value.name
  contacts                 = each.value.contacts
  describe                 = each.value.description
  enable_subscribed        = each.value.enable_subscribed
}
