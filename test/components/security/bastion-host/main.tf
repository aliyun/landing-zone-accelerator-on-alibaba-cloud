# Load configuration from JSON file
locals {
  # config = jsondecode(file("${path.module}/inputs/create_bastion.json"))
  config = jsondecode(file("${path.module}/inputs/attachment_bastion_hosts.json"))
  # config = jsondecode(file("${path.module}/inputs/use_file_path.json"))
  # config = jsondecode(file("${path.module}/inputs/use_dir_path.json"))
}

provider "alicloud" {
  region = try(local.config.region_id, "cn-hangzhou")
}

module "bastion_host" {
  source = "../../../../components/security/bastion-host"

  # Required variables
  create_bastion_host_slr = try(local.config.create_bastion_host_slr, true)
  create_bastion_host = try(local.config.create_bastion_host, true)
  existing_bastionhost_instance_id = try(local.config.existing_bastionhost_instance_id, null)
  
  # Bastion Host instance configuration variables
  bastionhost_description   = local.config.bastionhost_description
  bastionhost_license_code  = local.config.bastionhost_license_code
  bastionhost_plan_code     = local.config.bastionhost_plan_code
  bastionhost_storage       = local.config.bastionhost_storage
  bastionhost_bandwidth     = local.config.bastionhost_bandwidth
  bastionhost_period        = try(local.config.bastionhost_period, null)
  bastionhost_vswitch_id    = try(local.config.bastionhost_vswitch_id, null)
  bastionhost_security_group_ids = try(local.config.bastionhost_security_group_ids, [])
  bastionhost_slave_vswitch_id  = try(local.config.bastionhost_slave_vswitch_id, null)
  bastionhost_tags               = try(local.config.bastionhost_tags, null)
  bastionhost_resource_group_id  = try(local.config.bastionhost_resource_group_id, null)
  bastionhost_enable_public_access = try(local.config.bastionhost_enable_public_access, null)
  bastionhost_ad_auth_server      = try(local.config.bastionhost_ad_auth_server, null)
  bastionhost_ldap_auth_server   = try(local.config.bastionhost_ldap_auth_server, null)
  bastionhost_renew_period        = try(local.config.bastionhost_renew_period, 1)
  bastionhost_renewal_status      = try(local.config.bastionhost_renewal_status, null)
  bastionhost_renewal_period_unit = try(local.config.bastionhost_renewal_period_unit, null)
  bastionhost_public_white_list   = try(local.config.bastionhost_public_white_list, [])
  
  # Bastion Host groups configuration
  bastionhost_host_groups = try(local.config.bastionhost_host_groups, [])

  # Bastion Host hosts configuration
  bastionhost_hosts = try(local.config.bastionhost_hosts, [])
  host_file_paths   = try(local.config.host_file_paths, [])
  host_dir_paths    = try(local.config.host_dir_paths, [])
}

output "bastionhost_instance_id" {
  description = "The ID of the bastion host instance"
  value       = module.bastion_host.bastionhost_instance_id
}

output "bastionhost_instance_info" {
  description = "The information of the Bastion Host instance"
  value       = module.bastion_host.bastionhost_instance_info
}

# Output the Bastion Host host groups
output "bastionhost_host_group_maps" {
  description = "The host groups of the Bastion Host"
  value       = module.bastion_host.bastionhost_host_group_maps
}

# Output the Bastion Host hosts
output "bastionhost_hosts_list" {
  description = "The hosts of the Bastion Host"
  value       = module.bastion_host.bastionhost_hosts_list
}

output "bastionhost_host_accounts_list" {
  description = "The accounts of the Bastion Host"
  value       = module.bastion_host.bastionhost_host_accounts_list
}