module "bastion-host-slr" {
  count = var.create_bastion_host_slr ? 1 : 0

  source  = "terraform-alicloud-modules/service-linked-role/alicloud"
  version = "1.2.0"
  service_linked_role_with_service_names = [
    "bastion_host"
  ]
}

locals {
  # Extract bastionhost hosts from files
  # File format: array of bastionhost host objects only
  file_bastionhost_hosts = concat(
    # Files from host_file_paths
    flatten([
      for file in var.host_file_paths : (
        endswith(file, ".yaml") || endswith(file, ".yml") ?
        yamldecode(file(file)) :
        jsondecode(file(file))
      )
    ]),
    # Files from host_dir_paths (multiple directories)
    flatten([
      for dir in var.host_dir_paths : [
        for file in fileset(dir, "**/*.{json,yaml,yml}") : (
          endswith(file, ".yaml") || endswith(file, ".yml") ?
          yamldecode(file("${dir}/${file}")) :
          jsondecode(file("${dir}/${file}"))
        )
      ]
    ])
  )

  all_bastionhost_hosts = concat(var.bastionhost_hosts, local.file_bastionhost_hosts)
}

# Enable Bastion Host service
resource "alicloud_bastionhost_instance" "default" {
  count = var.create_bastion_host ? 1 : 0

  # Required parameters for bastion host instance
  description           = var.bastionhost_description
  license_code          = var.bastionhost_license_code
  plan_code             = var.bastionhost_plan_code
  storage               = var.bastionhost_storage
  bandwidth             = var.bastionhost_bandwidth
  period                = var.bastionhost_period
  vswitch_id            = var.bastionhost_vswitch_id
  slave_vswitch_id      = var.bastionhost_slave_vswitch_id
  security_group_ids    = var.bastionhost_security_group_ids
  tags                  = var.bastionhost_tags
  resource_group_id     = var.bastionhost_resource_group_id
  enable_public_access  = var.bastionhost_enable_public_access
  renew_period          = var.bastionhost_renew_period
  renewal_status        = var.bastionhost_renewal_status
  renewal_period_unit   = var.bastionhost_renewal_period_unit
  public_white_list     = var.bastionhost_public_white_list

  dynamic "ad_auth_server" {
    for_each = var.bastionhost_ad_auth_server != null ? var.bastionhost_ad_auth_server : []
    content {
      server         = ad_auth_server.value.server
      standby_server = try(ad_auth_server.value.standby_server, null)
      port           = ad_auth_server.value.port
      domain         = ad_auth_server.value.domain
      account        = ad_auth_server.value.account
      password       = try(ad_auth_server.value.password, null)
      filter         = try(ad_auth_server.value.filter, null)
      name_mapping   = try(ad_auth_server.value.name_mapping, null)
      email_mapping  = try(ad_auth_server.value.email_mapping, null)
      mobile_mapping = try(ad_auth_server.value.mobile_mapping, null)
      is_ssl         = ad_auth_server.value.is_ssl
      base_dn        = ad_auth_server.value.base_dn
    }
  }

  dynamic "ldap_auth_server" {
    for_each = var.bastionhost_ldap_auth_server != null ? var.bastionhost_ldap_auth_server : []
    content {
      server             = ldap_auth_server.value.server
      standby_server     = try(ldap_auth_server.value.standby_server, null)
      port               = ldap_auth_server.value.port
      login_name_mapping = try(ldap_auth_server.value.login_name_mapping, null)
      account            = ldap_auth_server.value.account
      password           = try(ldap_auth_server.value.password, null)
      filter             = try(ldap_auth_server.value.filter, null)
      name_mapping       = try(ldap_auth_server.value.name_mapping, null)
      email_mapping      = try(ldap_auth_server.value.email_mapping, null)
      mobile_mapping     = try(ldap_auth_server.value.mobile_mapping, null)
      is_ssl             = try(ldap_auth_server.value.is_ssl, null)
      base_dn            = ldap_auth_server.value.base_dn
    }
  }

  depends_on = [
    module.bastion-host-slr
  ]
}

locals {
  bastion_instance_id = var.create_bastion_host ? alicloud_bastionhost_instance.default[0].id : var.existing_bastionhost_instance_id
  
  # Split hosts into two arrays based on whether existing_host_id is null
  created_bastionhost_hosts = [for host in local.all_bastionhost_hosts : host if try(host.existing_host_id, null) == null]
  existing_bastionhost_hosts = [for host in local.all_bastionhost_hosts : host if try(host.existing_host_id, null) != null]
}

# Import ECS instances to Bastion Host
resource "alicloud_bastionhost_host" "hosts" {
  count = length(local.created_bastionhost_hosts)

  instance_id           = local.bastion_instance_id
  active_address_type   = local.created_bastionhost_hosts[count.index].host_config.active_address_type
  comment               = try(local.created_bastionhost_hosts[count.index].host_config.comment, null)
  host_name             = try(local.created_bastionhost_hosts[count.index].host_config.host_name, null)
  host_private_address  = try(local.created_bastionhost_hosts[count.index].host_config.host_private_address, null)
  host_public_address   = try(local.created_bastionhost_hosts[count.index].host_config.host_public_address, null)
  instance_region_id    = try(local.created_bastionhost_hosts[count.index].host_config.instance_region_id, null)
  os_type               = local.created_bastionhost_hosts[count.index].host_config.os_type
  source                = local.created_bastionhost_hosts[count.index].host_config.source
  source_instance_id    = try(local.created_bastionhost_hosts[count.index].host_config.source_instance_id, null)

  depends_on = [
    alicloud_bastionhost_instance.default
  ]
}

# Create Bastion Host asset groups
resource "alicloud_bastionhost_host_group" "groups" {
  count = length(var.bastionhost_host_groups)
  
  instance_id           = local.bastion_instance_id
  host_group_name       = var.bastionhost_host_groups[count.index].host_group_name
  comment               = try(var.bastionhost_host_groups[count.index].comment, null)

  depends_on = [
    alicloud_bastionhost_instance.default
  ]
}

data "alicloud_bastionhost_host_groups" "all" {
  instance_id = local.bastion_instance_id

  depends_on = [
    alicloud_bastionhost_instance.default,
    alicloud_bastionhost_host_group.groups
  ]
}

locals {
  bastionhost_groups_ids = {
    for group in data.alicloud_bastionhost_host_groups.all.groups : group.host_group_name => group.host_group_id
  }

  bastionhost_account_attachments = concat(
    flatten([
      for idx, host in local.created_bastionhost_hosts : [
        for account in try(host.host_accounts, []) : {
          host_id               = try(alicloud_bastionhost_host.hosts[idx].host_id, null)
          instance_id           = local.bastion_instance_id
          host_account_name     = account.host_account_name
          pass_phrase           = try(account.pass_phrase, null)
          password              = try(account.password, null)
          private_key           = try(account.private_key, null)
          protocol_name         = account.protocol_name
        }
      ]
    ]),
    flatten([
      for host in local.existing_bastionhost_hosts : [
        for account in try(host.host_accounts, []) : {
          host_id               = try(host.existing_host_id, null)
          instance_id           = local.bastion_instance_id
          host_account_name     = account.host_account_name
          pass_phrase           = try(account.pass_phrase, null)
          password              = try(account.password, null)
          private_key           = try(account.private_key, null)
          protocol_name         = account.protocol_name
        }
      ]
    ])
  )
  
  bastionhost_group_attachments = concat(
    flatten([
      for idx, host in local.created_bastionhost_hosts : [
        for group_name in try(host.host_group_names, []) : {
          host_id       = try(alicloud_bastionhost_host.hosts[idx].host_id, null)
          host_group_id = try(local.bastionhost_groups_ids[group_name], null)
          instance_id   = local.bastion_instance_id
        }
      ]
      if try((host.host_group_names != null && length(host.host_group_names) > 0), false)
    ]),
    flatten([
      for host in local.existing_bastionhost_hosts : [
        for group_name in try(host.host_group_names, []) : {
          host_id       = try(host.existing_host_id, null)
          host_group_id = try(local.bastionhost_groups_ids[group_name], null)
          instance_id   = local.bastion_instance_id
        }
      ]
      if try((host.host_group_names != null && length(host.host_group_names) > 0), false)
    ])
  )
}

# Create host accounts for specified hosts
resource "alicloud_bastionhost_host_account" "accounts" {
  count = length(local.bastionhost_account_attachments)

  host_id           = local.bastionhost_account_attachments[count.index].host_id
  instance_id       = local.bastionhost_account_attachments[count.index].instance_id
  host_account_name = local.bastionhost_account_attachments[count.index].host_account_name
  pass_phrase       = local.bastionhost_account_attachments[count.index].pass_phrase
  password          = local.bastionhost_account_attachments[count.index].password
  private_key       = local.bastionhost_account_attachments[count.index].private_key
  protocol_name     = local.bastionhost_account_attachments[count.index].protocol_name

  depends_on = [
    alicloud_bastionhost_instance.default,
    alicloud_bastionhost_host.hosts
  ]
}

resource "alicloud_bastionhost_host_attachment" "default" {
  count = length(local.bastionhost_group_attachments)

  host_group_id = local.bastionhost_group_attachments[count.index].host_group_id
  host_id       = local.bastionhost_group_attachments[count.index].host_id
  instance_id   = local.bastionhost_group_attachments[count.index].instance_id

  depends_on = [
    alicloud_bastionhost_instance.default,
    alicloud_bastionhost_host.hosts,
    alicloud_bastionhost_host_account.accounts,
    alicloud_bastionhost_host_group.groups
  ]
}