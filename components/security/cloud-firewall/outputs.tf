output "cloud_firewall_instance_id" {
  description = "The ID of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].id, null)
}

output "cloud_firewall_instance_status" {
  description = "The status of the cloud firewall instance"
  value       = try(alicloud_cloud_firewall_instance.main[0].status, null)
}

output "member_account_ids" {
  description = "The list of member account IDs managed by the cloud firewall"
  value       = local.all_member_account_ids
}

output "internet_control_policy_count" {
  description = "The number of internet control policies created"
  value       = length(local.internet_all_policies)
}

output "internet_control_policies" {
  description = "List of internet control policies with their ACL UUIDs"
  value = [
    for policy in local.internet_all_policies : {
      description           = policy.description
      source                = policy.source
      destination           = policy.destination
      proto                 = policy.proto
      dest_port             = try(policy.dest_port, null)
      acl_action            = policy.acl_action
      direction             = policy.direction
      source_type           = policy.source_type
      destination_type      = policy.destination_type
      dest_port_group       = try(policy.dest_port_group, null)
      dest_port_type        = try(policy.dest_port_type, null)
      ip_version            = try(policy.ip_version, null)
      domain_resolve_type   = try(policy.domain_resolve_type, null)
      start_time            = try(policy.start_time, null)
      end_time              = try(policy.end_time, null)
      repeat_type           = try(policy.repeat_type, "Permanent")
      repeat_start_time     = try(policy.repeat_start_time, null)
      repeat_end_time       = try(policy.repeat_end_time, null)
      repeat_days           = try(policy.repeat_days, null)
      application_name_list = policy.application_name_list
      release               = try(policy.release, null)
      lang                  = try(policy.lang, "zh")
      acl_uuid              = alicloud_cloud_firewall_control_policy.internet[policy.key].acl_uuid
    }
  ]
}

output "address_books" {
  description = "Map of address books created, keyed by group_name"
  value = {
    for name, book in alicloud_cloud_firewall_address_book.address_books : name => {
      group_name  = book.group_name
      group_type  = book.group_type
      id          = book.id
      description = book.description
    }
  }
}

output "vpc_cen_tr_firewalls" {
  description = "Map of VPC CEN TR Firewalls created, keyed by transit_router_id"
  value = {
    for tr_id, firewall in alicloud_cloud_firewall_vpc_cen_tr_firewall.vpc_firewalls : tr_id => {
      id = firewall.id
    }
  }
}

output "vpc_firewall_control_policies" {
  description = "List of VPC firewall control policies created with their details"
  value = [
    for policy in local.vpc_firewall_control_policies : {
      cen_id                  = policy.cen_id
      description             = policy.description
      source                  = policy.source
      destination             = policy.destination
      proto                   = policy.proto
      acl_action              = policy.acl_action
      source_type             = policy.source_type
      destination_type        = policy.destination_type
      dest_port               = try(policy.dest_port, null)
      dest_port_group         = try(policy.dest_port_group, null)
      dest_port_type          = try(policy.dest_port_type, null)
      application_name_list   = policy.application_name_list
      release                 = try(policy.release, null)
      member_uid              = try(policy.member_uid, null)
      domain_resolve_type     = try(policy.domain_resolve_type, null)
      repeat_type             = try(policy.repeat_type, "Permanent")
      repeat_days             = try(policy.repeat_days, null)
      repeat_end_time         = try(policy.repeat_end_time, null)
      repeat_start_time       = try(policy.repeat_start_time, null)
      start_time              = try(policy.start_time, null)
      end_time                = try(policy.end_time, null)
      lang                    = try(policy.lang, "zh")
      acl_uuid                = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].acl_uuid, null)
      application_id          = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].application_id, null)
      source_group_cidrs      = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].source_group_cidrs, null)
      source_group_type       = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].source_group_type, null)
      destination_group_cidrs = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].destination_group_cidrs, null)
      destination_group_type  = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].destination_group_type, null)
      dest_port_group_ports   = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].dest_port_group_ports, null)
      hit_times               = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].hit_times, null)
      create_time             = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].create_time, null)
      order                   = try(alicloud_cloud_firewall_vpc_firewall_control_policy.vpc_policies[policy.key].order, null)
    }
  ]
}

output "nat_firewalls" {
  description = "Map of NAT Gateway Firewalls created, keyed by nat_gateway_id"
  value = {
    for nat_gw_id, firewall in alicloud_cloud_firewall_nat_firewall.nat_firewalls : nat_gw_id => {
      id = firewall.id
    }
  }
}

output "nat_firewall_control_policies" {
  description = "List of NAT Gateway firewall control policies created with their details"
  value = [
    for policy in local.nat_firewall_control_policies : {
      nat_gateway_id        = policy.nat_gateway_id
      description           = policy.description
      source                = policy.source
      destination           = policy.destination
      proto                 = policy.proto
      acl_action            = policy.acl_action
      source_type           = policy.source_type
      destination_type      = policy.destination_type
      dest_port             = try(policy.dest_port, null)
      dest_port_group       = try(policy.dest_port_group, null)
      dest_port_type        = try(policy.dest_port_type, null)
      application_name_list = policy.application_name_list
      release               = try(policy.release, null)
      domain_resolve_type   = try(policy.domain_resolve_type, null)
      repeat_type           = try(policy.repeat_type, "Permanent")
      repeat_days           = try(policy.repeat_days, null)
      repeat_end_time       = try(policy.repeat_end_time, null)
      repeat_start_time     = try(policy.repeat_start_time, null)
      start_time            = try(policy.start_time, null)
      end_time              = try(policy.end_time, null)
      ip_version            = try(policy.ip_version, 4)
      direction             = "out"
      acl_uuid              = try(alicloud_cloud_firewall_nat_firewall_control_policy.nat_policies[policy.key].acl_uuid, null)
    }
  ]
}
