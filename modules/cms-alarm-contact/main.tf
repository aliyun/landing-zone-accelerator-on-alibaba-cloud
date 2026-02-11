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

resource "alicloud_cms_alarm_contact_group" "groups" {
  for_each = {
    for group in var.alarm_contact_groups :
    group.name => group
  }

  alarm_contact_group_name = each.value.name
  contacts                 = each.value.contacts
  describe                 = each.value.description
  enable_subscribed        = try(each.value.enable_subscribed, true)
}


