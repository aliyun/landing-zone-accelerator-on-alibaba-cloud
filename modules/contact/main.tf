# Create MSC contacts
resource "alicloud_msc_sub_contact" "this" {
  for_each = { for c in var.contacts : c.name => c }

  contact_name = each.value.name
  email        = each.value.email
  mobile       = each.value.mobile
  position     = each.value.position
}

# Get existing MSC subscriptions
data "alicloud_msc_sub_subscriptions" "this" {}

# Collect contact IDs for subscription configuration
locals {
  contact_ids = [for c in alicloud_msc_sub_contact.this : c.id]
}

# Configure MSC subscription notifications
resource "alicloud_msc_sub_subscription" "this" {
  for_each = {
    for sub in data.alicloud_msc_sub_subscriptions.this.subscriptions : sub.item_name => sub
  }

  item_name      = each.key
  contact_ids    = var.notification_recipient_mode == "overwrite" ? local.contact_ids : distinct(concat(try(each.value.contact_ids, []), local.contact_ids))
  email_status   = each.value.email_status
  pmsg_status    = each.value.pmsg_status
  sms_status     = each.value.sms_status
  tts_status     = each.value.tts_status
  webhook_status = each.value.webhook_status
  webhook_ids    = try(each.value.webhook_ids, [])
}
