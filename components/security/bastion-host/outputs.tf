# Output the Bastion Host instance ID
output "bastionhost_instance_id" {
  description = "The ID of the Bastion Host instance"
  value       = var.create_bastion_host ? alicloud_bastionhost_instance.default[0].id : var.existing_bastionhost_instance_id
}

output "bastionhost_instance_info" {
  description = "The information of the Bastion Host instance"
  value = var.create_bastion_host ? {
    instance_id = alicloud_bastionhost_instance.default[0].id
    description = alicloud_bastionhost_instance.default[0].description
    license_code = alicloud_bastionhost_instance.default[0].license_code
    plan_code = alicloud_bastionhost_instance.default[0].plan_code
    storage = alicloud_bastionhost_instance.default[0].storage
    bandwidth = alicloud_bastionhost_instance.default[0].bandwidth
    period = alicloud_bastionhost_instance.default[0].period
    vswitch_id = alicloud_bastionhost_instance.default[0].vswitch_id
    slave_vswitch_id = alicloud_bastionhost_instance.default[0].slave_vswitch_id
    security_group_ids = alicloud_bastionhost_instance.default[0].security_group_ids
    tags = alicloud_bastionhost_instance.default[0].tags
    resource_group_id = alicloud_bastionhost_instance.default[0].resource_group_id
    enable_public_access = alicloud_bastionhost_instance.default[0].enable_public_access
    renew_period = alicloud_bastionhost_instance.default[0].renew_period
    renewal_status = alicloud_bastionhost_instance.default[0].renewal_status
    renewal_period_unit = alicloud_bastionhost_instance.default[0].renewal_period_unit
    public_white_list = alicloud_bastionhost_instance.default[0].public_white_list
  } : {
    instance_id           = var.existing_bastionhost_instance_id
    description          = null
    license_code         = null
    plan_code            = null
    storage              = null
    bandwidth            = null
    period               = null
    vswitch_id           = null
    slave_vswitch_id     = null
    security_group_ids   = null
    tags                 = null
    resource_group_id    = null
    enable_public_access = null
    renew_period         = null
    renewal_status       = null
    renewal_period_unit  = null
    public_white_list    = null
  }
}

# Output the Bastion Host host groups
output "bastionhost_host_group_maps" {
  description = "The host groups of the Bastion Host"
  value = {
    for group in alicloud_bastionhost_host_group.groups : group.host_group_name => group
  }
}

# Output the Bastion Host hosts
output "bastionhost_hosts_list" {
  description = "The hosts of the Bastion Host"
  value = [
    for idx, host in alicloud_bastionhost_host.hosts : merge(host, {
      host_group_names = try(local.created_bastionhost_hosts[idx].host_group_names, [])
    })
  ]
}

output "bastionhost_host_accounts_list" {
  description = "The accounts of the Bastion Host"
  # value = alicloud_bastionhost_host_account.accounts[*].password
  value = [
    for idx, account in alicloud_bastionhost_host_account.accounts : {
      host_account_id   = account.host_account_id
      host_account_name = account.host_account_name
      host_id           = account.host_id
      instance_id       = account.instance_id
      protocol_name     = account.protocol_name
      password          = try(local.bastionhost_account_attachments[idx].password, null)
      pass_phrase       = try(local.bastionhost_account_attachments[idx].pass_phrase, null)
    }
  ]
}