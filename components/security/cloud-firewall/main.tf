# Merge file and inline configurations, file config takes precedence
locals {
  member_account_file_config_raw = var.member_account_id_file_path != null ? (
    endswith(var.member_account_id_file_path, ".json") ? jsondecode(file(var.member_account_id_file_path)) : yamldecode(file(var.member_account_id_file_path))
  ) : null
  member_account_file_configs = var.member_account_id_file_path != null ? (
    try(local.member_account_file_config_raw[*], [local.member_account_file_config_raw])
  ) : []
  all_member_account_ids = concat(
    [for cfg in local.member_account_file_configs : cfg.account_id],
    [for id in var.member_account_ids : id if !contains([for cfg in local.member_account_file_configs : cfg.account_id], id)]
  )

  # Load inbound policies from file (must be an array)
  internet_control_policy_in_file_configs = var.internet_control_policy_in_file_path != null ? [
    for policy in(endswith(var.internet_control_policy_in_file_path, ".json") ? jsondecode(file(var.internet_control_policy_in_file_path)) : yamldecode(file(var.internet_control_policy_in_file_path))) : {
      description           = policy.description
      source                = policy.source
      destination           = policy.destination
      proto                 = policy.proto
      dest_port             = try(policy.dest_port, null)
      acl_action            = policy.acl_action
      direction             = try(policy.direction, "in")
      source_type           = policy.source_type
      destination_type      = policy.destination_type
      dest_port_group       = try(policy.dest_port_group, null)
      dest_port_type        = try(policy.dest_port_type, null)
      ip_version            = try(policy.ip_version, 4)
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
      key                   = md5("${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${try(policy.direction, "in")}:${policy.source_type}:${policy.destination_type}")
    }
  ] : []

  # Load outbound policies from file (must be an array)
  internet_control_policy_out_file_configs = var.internet_control_policy_out_file_path != null ? [
    for policy in(endswith(var.internet_control_policy_out_file_path, ".json") ? jsondecode(file(var.internet_control_policy_out_file_path)) : yamldecode(file(var.internet_control_policy_out_file_path))) : {
      description           = policy.description
      source                = policy.source
      destination           = policy.destination
      proto                 = policy.proto
      dest_port             = try(policy.dest_port, null)
      acl_action            = policy.acl_action
      direction             = try(policy.direction, "out")
      source_type           = policy.source_type
      destination_type      = policy.destination_type
      dest_port_group       = try(policy.dest_port_group, null)
      dest_port_type        = try(policy.dest_port_type, null)
      ip_version            = try(policy.ip_version, 4)
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
      key                   = md5("${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${try(policy.direction, "out")}:${policy.source_type}:${policy.destination_type}")
    }
  ] : []

  internet_in_policies = var.internet_control_policy_in_file_path != null ? [
    for policy in local.internet_control_policy_in_file_configs : policy
    if policy.direction == "in"
    ] : [
    for policy in var.internet_control_policies : merge(policy, { key = md5("${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.direction}:${policy.source_type}:${policy.destination_type}") })
    if policy.direction == "in"
  ]

  internet_out_policies = var.internet_control_policy_out_file_path != null ? [
    for policy in local.internet_control_policy_out_file_configs : policy
    if policy.direction == "out"
    ] : [
    for policy in var.internet_control_policies : merge(policy, { key = md5("${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.direction}:${policy.source_type}:${policy.destination_type}") })
    if policy.direction == "out"
  ]

  internet_all_policies = concat(local.internet_in_policies, local.internet_out_policies)

  # Process VPC firewall control policies grouped by cen_id
  # For each cen_id configuration, load policies from file if provided, otherwise use inline config
  # Order is set based on array index within each cen_id (starting from 1)
  vpc_firewall_control_policies_by_cen = {
    for config in var.vpc_firewall_control_policies : config.cen_id => {
      policies = config.control_policy_file_path != null ? [
        # Load from file
        for policy in(endswith(config.control_policy_file_path, ".json") ? jsondecode(file(config.control_policy_file_path)) : yamldecode(file(config.control_policy_file_path))) : {
          cen_id                = config.cen_id
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
          member_uid            = try(policy.member_uid, null)
          domain_resolve_type   = try(policy.domain_resolve_type, null)
          repeat_type           = try(policy.repeat_type, "Permanent")
          repeat_days           = try(policy.repeat_days, null)
          repeat_end_time       = try(policy.repeat_end_time, null)
          repeat_start_time     = try(policy.repeat_start_time, null)
          start_time            = try(policy.start_time, null)
          end_time              = try(policy.end_time, null)
          lang                  = try(policy.lang, "zh")
          key                   = md5("${config.cen_id}:${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.source_type}:${policy.destination_type}")
        }
        ] : [
        # Use inline config
        for policy in try(config.control_policies, []) : merge(policy, {
          cen_id = config.cen_id
          key    = md5("${config.cen_id}:${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.source_type}:${policy.destination_type}")
        })
      ]
    }
  }

  # Flatten policies with order based on index within each cen_id
  vpc_firewall_control_policies = flatten([
    for cen_id, config in local.vpc_firewall_control_policies_by_cen : [
      for idx, policy in config.policies : merge(policy, {
        order = idx + 1
      })
    ]
  ])

  # Process NAT Gateway firewall control policies grouped by nat_gateway_id
  # For each nat_gateway_id configuration, load policies from file if provided, otherwise use inline config
  # Direction is fixed to "out" and new_order is fixed to 1
  nat_firewall_control_policies_by_nat_gw = {
    for config in var.nat_firewall_control_policies : config.nat_gateway_id => {
      policies = config.control_policy_file_path != null ? [
        # Load from file
        for policy in(endswith(config.control_policy_file_path, ".json") ? jsondecode(file(config.control_policy_file_path)) : yamldecode(file(config.control_policy_file_path))) : {
          nat_gateway_id        = config.nat_gateway_id
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
          key                   = md5("${config.nat_gateway_id}:${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.source_type}:${policy.destination_type}")
        }
        ] : [
        # Otherwise use inline config
        for policy in try(config.control_policies, []) : merge(policy, {
          nat_gateway_id = config.nat_gateway_id
          key            = md5("${config.nat_gateway_id}:${policy.description}:${policy.source}:${policy.destination}:${policy.proto}:${try(policy.dest_port, "")}:${policy.acl_action}:${policy.source_type}:${policy.destination_type}")
        })
      ]
    }
  }

  # Flatten policies (new_order is fixed to 1 due to Terraform parallel execution limitations)
  # Note: The new_order field cannot be reliably set in Terraform due to parallel resource creation.
  # Setting new_order to 1 ensures newly created policies have the highest priority.
  nat_firewall_control_policies = flatten([
    for nat_gw_id, config in local.nat_firewall_control_policies_by_nat_gw : [
      for policy in config.policies : policy
    ]
  ])
}

# Enable Cloud Firewall service
resource "alicloud_cloud_firewall_instance" "main" {
  count = var.create_cloud_firewall_instance ? 1 : 0

  payment_type          = var.cloud_firewall_payment_type
  spec                  = var.cloud_firewall_instance_type
  band_width            = var.cloud_firewall_bandwidth
  period                = var.cloud_firewall_period
  renewal_duration      = var.cloud_firewall_renewal_duration
  renewal_duration_unit = var.cloud_firewall_renewal_duration_unit
  renewal_status        = var.cloud_firewall_renewal_status
  modify_type           = var.cloud_firewall_modify_type
  cfw_log               = var.cloud_firewall_cfw_log
  cfw_log_storage       = var.cloud_firewall_cfw_log_storage
  ip_number             = var.cloud_firewall_ip_number
}

# Add member accounts to Cloud Firewall
resource "alicloud_cloud_firewall_instance_member" "members" {
  for_each = {
    for account_id in local.all_member_account_ids : account_id => account_id
  }

  member_uid = each.value

  timeouts {
    delete = "10m"
  }

  depends_on = [alicloud_cloud_firewall_instance.main]
}

# Create address books
resource "alicloud_cloud_firewall_address_book" "address_books" {
  for_each = {
    for book in var.address_books : book.group_name => book
  }

  group_name       = each.value.group_name
  group_type       = each.value.group_type
  description      = each.value.description
  auto_add_tag_ecs = each.value.auto_add_tag_ecs
  tag_relation     = each.value.tag_relation
  lang             = each.value.lang
  address_list     = each.value.address_list
  dynamic "ecs_tags" {
    for_each = each.value.ecs_tags != null ? each.value.ecs_tags : []
    content {
      tag_key   = ecs_tags.value.tag_key
      tag_value = ecs_tags.value.tag_value
    }
  }

  depends_on = [alicloud_cloud_firewall_instance.main]
}

# Configure internet boundary firewall rules
resource "alicloud_cloud_firewall_control_policy" "internet" {
  for_each = {
    for policy in local.internet_all_policies : policy.key => policy
  }

  description           = each.value.description
  source                = each.value.source
  source_type           = each.value.source_type
  destination           = each.value.destination
  destination_type      = each.value.destination_type
  proto                 = each.value.proto
  dest_port             = try(each.value.dest_port, null)
  dest_port_group       = try(each.value.dest_port_group, null)
  dest_port_type        = try(each.value.dest_port_type, null)
  acl_action            = each.value.acl_action
  direction             = each.value.direction
  ip_version            = try(each.value.ip_version, null)
  domain_resolve_type   = try(each.value.domain_resolve_type, null)
  start_time            = try(each.value.start_time, null)
  end_time              = try(each.value.end_time, null)
  repeat_type           = try(each.value.repeat_type, "Permanent")
  repeat_start_time     = try(each.value.repeat_start_time, null)
  repeat_end_time       = try(each.value.repeat_end_time, null)
  repeat_days           = try(each.value.repeat_days, null)
  application_name_list = each.value.application_name_list
  release               = try(each.value.release, null)
  lang                  = try(each.value.lang, "zh")

  depends_on = [
    alicloud_cloud_firewall_instance.main,
    alicloud_cloud_firewall_address_book.address_books
  ]
}

# Set priority order for inbound policies (based on array index, starting from 1)
resource "alicloud_cloud_firewall_control_policy_order" "in" {
  for_each = {
    for idx, policy in local.internet_in_policies : policy.key => idx
  }

  acl_uuid  = alicloud_cloud_firewall_control_policy.internet[each.key].acl_uuid
  direction = "in"
  order     = each.value + 1

  depends_on = [alicloud_cloud_firewall_control_policy.internet]
}

# Set priority order for outbound policies (based on array index, starting from 1)
resource "alicloud_cloud_firewall_control_policy_order" "out" {
  for_each = {
    for idx, policy in local.internet_out_policies : policy.key => idx
  }

  acl_uuid  = alicloud_cloud_firewall_control_policy.internet[each.key].acl_uuid
  direction = "out"
  order     = each.value + 1

  depends_on = [alicloud_cloud_firewall_control_policy.internet]
}

# Configure advanced policy settings
resource "alicloud_cloud_firewall_policy_advanced_config" "main" {
  count = var.internet_switch != null ? 1 : 0

  internet_switch = var.internet_switch

  depends_on = [alicloud_cloud_firewall_instance.main]
}

# Create VPC CEN TR Firewalls (one firewall per transit router)
resource "alicloud_cloud_firewall_vpc_cen_tr_firewall" "vpc_firewalls" {
  for_each = {
    for firewall in var.vpc_cen_tr_firewalls : firewall.transit_router_id => firewall
  }

  transit_router_id         = each.value.transit_router_id
  cen_id                    = each.value.cen_id
  firewall_name             = each.value.firewall_name
  region_no                 = each.value.region_no
  route_mode                = each.value.route_mode
  firewall_vpc_cidr         = each.value.firewall_vpc_cidr
  firewall_subnet_cidr      = each.value.firewall_subnet_cidr
  tr_attachment_master_cidr = each.value.tr_attachment_master_cidr
  tr_attachment_slave_cidr  = each.value.tr_attachment_slave_cidr
  firewall_description      = try(each.value.firewall_description, null)
  tr_attachment_master_zone = try(each.value.tr_attachment_master_zone, null)
  tr_attachment_slave_zone  = try(each.value.tr_attachment_slave_zone, null)

  depends_on = [alicloud_cloud_firewall_instance_member.members]
}

# Create VPC Firewall Control Policies
# Note: The order field is fixed to 1 due to Terraform's parallel execution model.
# Terraform creates resources in parallel, which makes it impossible to guarantee
# the order of policy creation matches the array index. Setting order to 1 ensures
# newly created policies have the highest priority (smaller order value = higher priority).
resource "alicloud_cloud_firewall_vpc_firewall_control_policy" "vpc_policies" {
  for_each = {
    for policy in local.vpc_firewall_control_policies : policy.key => policy
  }

  vpc_firewall_id       = each.value.cen_id
  description           = each.value.description
  source                = each.value.source
  destination           = each.value.destination
  proto                 = each.value.proto
  acl_action            = each.value.acl_action
  source_type           = each.value.source_type
  destination_type      = each.value.destination_type
  order                 = 1
  dest_port             = try(each.value.dest_port, null)
  dest_port_group       = try(each.value.dest_port_group, null)
  dest_port_type        = try(each.value.dest_port_type, null)
  application_name_list = each.value.application_name_list
  release               = try(each.value.release, null)
  member_uid            = try(each.value.member_uid, null)
  domain_resolve_type   = try(each.value.domain_resolve_type, null)
  repeat_type           = try(each.value.repeat_type, "Permanent")
  repeat_days           = try(each.value.repeat_days, null)
  repeat_end_time       = try(each.value.repeat_end_time, null)
  repeat_start_time     = try(each.value.repeat_start_time, null)
  start_time            = try(each.value.start_time, null)
  end_time              = try(each.value.end_time, null)
  lang                  = try(each.value.lang, "zh")

  depends_on = [
    alicloud_cloud_firewall_vpc_cen_tr_firewall.vpc_firewalls,
    alicloud_cloud_firewall_address_book.address_books
  ]

  lifecycle {
    ignore_changes = [order]
  }
}

# Create NAT Gateway Firewalls
resource "alicloud_cloud_firewall_nat_firewall" "nat_firewalls" {
  for_each = {
    for firewall in var.nat_firewalls : firewall.nat_gateway_id => firewall
  }

  nat_gateway_id = each.value.nat_gateway_id
  proxy_name     = each.value.proxy_name
  region_no      = each.value.region_no
  vpc_id         = each.value.vpc_id

  dynamic "nat_route_entry_list" {
    for_each = each.value.nat_route_entry_list
    content {
      destination_cidr = try(nat_route_entry_list.value.destination_cidr, "0.0.0.0/0")
      nexthop_id       = try(nat_route_entry_list.value.nexthop_id, each.value.nat_gateway_id)
      nexthop_type     = "NatGateway"
      route_table_id   = nat_route_entry_list.value.route_table_id
    }
  }

  firewall_switch = try(each.value.firewall_switch, null)
  lang            = try(each.value.lang, null)
  strict_mode     = try(each.value.strict_mode, null)
  vswitch_auto    = try(each.value.vswitch_auto, null)
  vswitch_id      = try(each.value.vswitch_id, null)
  vswitch_cidr    = try(each.value.vswitch_cidr, null)

  depends_on = [alicloud_cloud_firewall_instance_member.members]
}

# Create NAT Gateway Firewall Control Policies
# Note: The new_order field is fixed to 1 due to Terraform's parallel execution model.
# Terraform creates resources in parallel, which makes it impossible to guarantee
# the order of policy creation matches the array index. Setting new_order to 1 ensures
# newly created policies have the highest priority (smaller order value = higher priority).
# Direction is fixed to "out" for NAT Gateway firewall control policies.
resource "alicloud_cloud_firewall_nat_firewall_control_policy" "nat_policies" {
  for_each = {
    for policy in local.nat_firewall_control_policies : policy.key => policy
  }

  nat_gateway_id        = each.value.nat_gateway_id
  description           = each.value.description
  source                = each.value.source
  destination           = each.value.destination
  proto                 = each.value.proto
  acl_action            = each.value.acl_action
  source_type           = each.value.source_type
  destination_type      = each.value.destination_type
  direction             = "out"
  new_order             = 1
  dest_port             = try(each.value.dest_port, null)
  dest_port_group       = try(each.value.dest_port_group, null)
  dest_port_type        = try(each.value.dest_port_type, null)
  application_name_list = each.value.application_name_list
  release               = try(each.value.release, null)
  domain_resolve_type   = try(each.value.domain_resolve_type, null)
  repeat_type           = try(each.value.repeat_type, "Permanent")
  repeat_days           = try(each.value.repeat_days, null)
  repeat_end_time       = try(each.value.repeat_end_time, null)
  repeat_start_time     = try(each.value.repeat_start_time, null)
  start_time            = try(each.value.start_time, null)
  end_time              = try(each.value.end_time, null)
  ip_version            = try(each.value.ip_version, 4)

  depends_on = [
    alicloud_cloud_firewall_nat_firewall.nat_firewalls,
    alicloud_cloud_firewall_address_book.address_books
  ]

  lifecycle {
    ignore_changes = [new_order]
  }
}
