output "contacts" {
  description = "List of contacts"
  value = [
    for c in var.contacts : {
      name     = c.name
      email    = c.email
      mobile   = c.mobile
      position = c.position
      id       = try(alicloud_msc_sub_contact.this[c.name].id, null)
    }
  ]
}
