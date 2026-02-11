# Cloud Firewall variables
variable "create_cloud_firewall_instance" {
  description = "Whether to create a cloud firewall instance"
  type        = bool
  default     = true
}

variable "cloud_firewall_payment_type" {
  description = "The payment type of the cloud firewall instance. Valid values: Subscription, PayAsYouGo"
  type        = string
  default     = "PayAsYouGo"

  validation {
    condition     = contains(["PayAsYouGo", "Subscription"], var.cloud_firewall_payment_type)
    error_message = "cloud_firewall_payment_type must be either 'PayAsYouGo' or 'Subscription'."
  }
}

variable "cloud_firewall_instance_type" {
  description = "The type of the cloud firewall instance. Valid values: premium_version, enterprise_version, ultimate_version, payg_version"
  type        = string
  default     = null

  validation {
    condition     = var.cloud_firewall_instance_type == null || try(contains(["premium_version", "enterprise_version", "ultimate_version", "payg_version"], var.cloud_firewall_instance_type), false)
    error_message = "cloud_firewall_instance_type must be one of: premium_version, enterprise_version, ultimate_version, payg_version."
  }
}

variable "cloud_firewall_bandwidth" {
  description = "The bandwidth of the cloud firewall instance"
  type        = number
  default     = null
}

variable "cloud_firewall_period" {
  description = "The prepaid period. Valid values: 1, 3, 6, 12, 24, 36. Required if payment_type is set to Subscription"
  type        = number
  default     = null

  validation {
    condition     = var.cloud_firewall_period == null || try(contains([1, 3, 6, 12, 24, 36], var.cloud_firewall_period), false)
    error_message = "cloud_firewall_period must be one of: 1, 3, 6, 12, 24, 36."
  }
}

variable "cloud_firewall_renewal_duration" {
  description = "Auto-Renewal Duration. Valid values: 1, 2, 3, 6, 12. Required when renewal_status is AutoRenewal and payment_type is Subscription"
  type        = number
  default     = null

  validation {
    condition     = var.cloud_firewall_renewal_duration == null || try(contains([1, 2, 3, 6, 12], var.cloud_firewall_renewal_duration), false)
    error_message = "cloud_firewall_renewal_duration must be one of: 1, 2, 3, 6, 12."
  }
}

variable "cloud_firewall_renewal_duration_unit" {
  description = "Auto-Renewal Cycle Unit. Valid values: Month, Year"
  type        = string
  default     = null

  validation {
    condition     = var.cloud_firewall_renewal_duration_unit == null || try(contains(["Month", "Year"], var.cloud_firewall_renewal_duration_unit), false)
    error_message = "cloud_firewall_renewal_duration_unit must be either 'Month' or 'Year'."
  }
}

variable "cloud_firewall_renewal_status" {
  description = "Whether to renew an instance automatically or not. Valid values: AutoRenewal, ManualRenewal. Default: ManualRenewal. Only takes effect when payment_type is Subscription"
  type        = string
  default     = "ManualRenewal"

  validation {
    condition     = contains(["AutoRenewal", "ManualRenewal"], var.cloud_firewall_renewal_status)
    error_message = "cloud_firewall_renewal_status must be either 'AutoRenewal' or 'ManualRenewal'."
  }
}

variable "cloud_firewall_modify_type" {
  description = "The type of modification. Valid values: Upgrade, Downgrade. Required when executing an update operation"
  type        = string
  default     = null

  validation {
    condition     = var.cloud_firewall_modify_type == null || try(contains(["Upgrade", "Downgrade"], var.cloud_firewall_modify_type), false)
    error_message = "cloud_firewall_modify_type must be either 'Upgrade' or 'Downgrade'."
  }
}

variable "cloud_firewall_cfw_log" {
  description = "Whether to use log audit. Valid values: true, false. When payment_type is PayAsYouGo, cfw_log can only be set to true"
  type        = bool
  default     = null
}

variable "cloud_firewall_cfw_log_storage" {
  description = "The log storage capacity. When payment_type is PayAsYouGo or cfw_log is false, this will be ignored"
  type        = number
  default     = null
}

variable "cloud_firewall_ip_number" {
  description = "The number of public IPs that can be protected. Valid values: 20 to 4000. For premium_version: [60, 1000], default 20. For enterprise_version: [60, 1000], default 50. For ultimate_version: [400, 4000], default 400"
  type        = number
  default     = null

  validation {
    condition     = var.cloud_firewall_ip_number == null || try(var.cloud_firewall_ip_number >= 20 && var.cloud_firewall_ip_number <= 4000, false)
    error_message = "cloud_firewall_ip_number must be between 20 and 4000."
  }
}

variable "member_account_ids" {
  description = "List of member account IDs to be managed by the cloud firewall"
  type        = list(string)
  default     = []
}

variable "member_account_id_file_path" {
  description = "File path to member account configuration file (JSON/YAML). The file is loaded and merged with member_account_ids parameter, file config takes precedence."
  type        = string
  default     = null
}

variable "internet_control_policies" {
  description = "List of internet control policies for the firewall"
  type = list(object({
    description           = string
    source                = string
    destination           = string
    proto                 = string
    dest_port             = optional(string)
    acl_action            = string
    direction             = string
    source_type           = string
    destination_type      = string
    dest_port_group       = optional(string)
    dest_port_type        = optional(string)
    ip_version            = optional(number, 4)
    domain_resolve_type   = optional(string)
    start_time            = optional(number)
    end_time              = optional(number)
    repeat_type           = optional(string, "Permanent")
    repeat_start_time     = optional(string)
    repeat_end_time       = optional(string)
    repeat_days           = optional(list(number))
    application_name_list = list(string)
    release               = optional(bool)
    lang                  = optional(string, "zh")
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : contains(["ANY", "TCP", "UDP", "ICMP"], policy.proto)
    ])
    error_message = "Each policy proto must be one of: ANY, TCP, UDP, ICMP."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : contains(["accept", "drop", "log"], policy.acl_action)
    ])
    error_message = "Each policy acl_action must be one of: accept, drop, log."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : contains(["in", "out"], policy.direction)
    ])
    error_message = "Each policy direction must be either 'in' or 'out'."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : contains(["net", "group", "location"], policy.source_type)
    ])
    error_message = "Each policy source_type must be one of: net, group, location."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : contains(["net", "group", "domain", "location"], policy.destination_type)
    ])
    error_message = "Each policy destination_type must be one of: net, group, domain, location."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : policy.dest_port_type == null || try(contains(["port", "group"], policy.dest_port_type), false)
    ])
    error_message = "Each policy dest_port_type must be either 'port' or 'group'."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : policy.ip_version == null || try(contains([4, 6], policy.ip_version), false)
    ])
    error_message = "Each policy ip_version must be either 4 (IPv4) or 6 (IPv6)."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : policy.domain_resolve_type == null || try(contains(["FQDN", "DNS", "FQDN_AND_DNS"], policy.domain_resolve_type), false)
    ])
    error_message = "Each policy domain_resolve_type must be one of: FQDN, DNS, FQDN_AND_DNS."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : policy.repeat_type == null || try(contains(["Permanent", "None", "Daily", "Weekly", "Monthly"], policy.repeat_type), false)
    ])
    error_message = "Each policy repeat_type must be one of: Permanent, None, Daily, Weekly, Monthly."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : policy.lang == null || try(contains(["zh", "en"], policy.lang), false)
    ])
    error_message = "Each policy lang must be either 'zh' or 'en'."
  }

  validation {
    condition = alltrue([
      for policy in var.internet_control_policies : length(policy.application_name_list) > 0
    ])
    error_message = "Each policy application_name_list must contain at least one application name."
  }
}

variable "internet_control_policy_in_file_path" {
  description = "File path to inbound (in) internet control policy configuration file (JSON/YAML). The file must contain an array of policy objects. File config takes precedence over internet_control_policies parameter."
  type        = string
  default     = null
}

variable "internet_control_policy_out_file_path" {
  description = "File path to outbound (out) internet control policy configuration file (JSON/YAML). The file must contain an array of policy objects. File config takes precedence over internet_control_policies parameter."
  type        = string
  default     = null
}


variable "internet_switch" {
  description = "Access control policy strict mode of on-state. Valid values: on (strict mode enabled), off (strict mode is turned off)"
  type        = string
  default     = null

  validation {
    condition     = var.internet_switch == null || try(contains(["on", "off"], var.internet_switch), false)
    error_message = "internet_switch must be either 'on' or 'off'."
  }
}

variable "address_books" {
  description = "List of address books for the cloud firewall"
  type = list(object({
    group_name       = string
    group_type       = string
    description      = string
    auto_add_tag_ecs = optional(number)
    tag_relation     = optional(string)
    lang             = optional(string)
    address_list     = optional(list(string), [])
    ecs_tags = optional(list(object({
      tag_key   = optional(string)
      tag_value = optional(string)
    })), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for book in var.address_books : contains(["port", "ackLabel", "ipv6", "ip", "domain", "ackNamespace", "tag"], book.group_type)
    ])
    error_message = "Each address book group_type must be one of: port, ackLabel, ipv6, ip, domain, ackNamespace, tag."
  }

  validation {
    condition = alltrue([
      for book in var.address_books : book.auto_add_tag_ecs == null || try(contains([0, 1], book.auto_add_tag_ecs), false)
    ])
    error_message = "Each address book auto_add_tag_ecs must be either 0 or 1."
  }

  validation {
    condition = alltrue([
      for book in var.address_books : book.tag_relation == null || try(contains(["and", "or"], book.tag_relation), false)
    ])
    error_message = "Each address book tag_relation must be either 'and' or 'or'."
  }

  validation {
    condition = alltrue([
      for book in var.address_books : book.lang == null || try(contains(["zh", "en"], book.lang), false)
    ])
    error_message = "Each address book lang must be either 'zh' or 'en'."
  }
}

variable "vpc_cen_tr_firewalls" {
  description = "List of VPC CEN TR Firewall configurations. One firewall per transit router."
  type = list(object({
    transit_router_id         = string
    cen_id                    = string
    firewall_name             = string
    region_no                 = string
    route_mode                = string
    firewall_vpc_cidr         = string
    firewall_subnet_cidr      = string
    tr_attachment_master_cidr = string
    tr_attachment_slave_cidr  = string
    firewall_description      = optional(string)
    tr_attachment_master_zone = optional(string)
    tr_attachment_slave_zone  = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for firewall in var.vpc_cen_tr_firewalls : contains(["managed", "manual"], firewall.route_mode)
    ])
    error_message = "Each firewall route_mode must be either 'managed' (automatic mode) or 'manual' (manual mode)."
  }

  validation {
    condition = length([
      for firewall in var.vpc_cen_tr_firewalls : firewall.transit_router_id
      ]) == length(distinct([
        for firewall in var.vpc_cen_tr_firewalls : firewall.transit_router_id
    ]))
    error_message = "Each firewall must have a unique transit_router_id. One firewall per transit router."
  }

  validation {
    condition = alltrue([
      for firewall in var.vpc_cen_tr_firewalls : can(cidrhost(firewall.firewall_vpc_cidr, 0))
    ])
    error_message = "Each firewall firewall_vpc_cidr must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for firewall in var.vpc_cen_tr_firewalls : can(cidrhost(firewall.firewall_subnet_cidr, 0))
    ])
    error_message = "Each firewall firewall_subnet_cidr must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for firewall in var.vpc_cen_tr_firewalls : can(cidrhost(firewall.tr_attachment_master_cidr, 0))
    ])
    error_message = "Each firewall tr_attachment_master_cidr must be a valid CIDR block."
  }

  validation {
    condition = alltrue([
      for firewall in var.vpc_cen_tr_firewalls : can(cidrhost(firewall.tr_attachment_slave_cidr, 0))
    ])
    error_message = "Each firewall tr_attachment_slave_cidr must be a valid CIDR block."
  }
}

variable "vpc_firewall_control_policies" {
  description = "List of VPC firewall control policy configurations grouped by cen_id. Each configuration includes cen_id, control_policies (inline), and optional control_policy_file_path (file config). File config takes precedence over inline config."
  type = list(object({
    cen_id = string
    control_policies = optional(list(object({
      description           = string
      source                = string
      destination           = string
      proto                 = string
      acl_action            = string
      source_type           = string
      destination_type      = string
      dest_port             = optional(string)
      dest_port_group       = optional(string)
      dest_port_type        = optional(string)
      application_name_list = list(string)
      release               = optional(bool)
      member_uid            = optional(string)
      domain_resolve_type   = optional(string)
      repeat_type           = optional(string, "Permanent")
      repeat_days           = optional(list(number))
      repeat_end_time       = optional(string)
      repeat_start_time     = optional(string)
      start_time            = optional(number)
      end_time              = optional(number)
      lang                  = optional(string, "zh")
    })), [])
    control_policy_file_path = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["ANY", "TCP", "UDP", "ICMP"], policy.proto)
      ])
    ])
    error_message = "Each policy proto must be one of: ANY, TCP, UDP, ICMP."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["accept", "drop", "log"], policy.acl_action)
      ])
    ])
    error_message = "Each policy acl_action must be one of: accept, drop, log."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["net", "group"], policy.source_type)
      ])
    ])
    error_message = "Each policy source_type must be either 'net' or 'group'."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["net", "group", "domain"], policy.destination_type)
      ])
    ])
    error_message = "Each policy destination_type must be one of: net, group, domain."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.dest_port_type == null || try(contains(["port", "group"], policy.dest_port_type), false)
      ])
    ])
    error_message = "Each policy dest_port_type must be either 'port' or 'group'."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.lang == null || try(contains(["zh", "en"], policy.lang), false)
      ])
    ])
    error_message = "Each policy lang must be either 'zh' or 'en'."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : length(policy.application_name_list) > 0
      ])
    ])
    error_message = "Each policy application_name_list must contain at least one application name."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.domain_resolve_type == null || try(contains(["FQDN", "DNS", "FQDN_AND_DNS"], policy.domain_resolve_type), false)
      ])
    ])
    error_message = "Each policy domain_resolve_type must be one of: FQDN, DNS, FQDN_AND_DNS."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.repeat_type == null || try(contains(["Permanent", "None", "Daily", "Weekly", "Monthly"], policy.repeat_type), false)
      ])
    ])
    error_message = "Each policy repeat_type must be one of: Permanent, None, Daily, Weekly, Monthly."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) :
        policy.repeat_days == null || try((
          (policy.repeat_type == "Weekly" && alltrue([
            for day in policy.repeat_days : day >= 0 && day <= 6
          ])) ||
          (policy.repeat_type == "Monthly" && alltrue([
            for day in policy.repeat_days : day >= 1 && day <= 31
          ]))
          ),
          false
        )
      ])
    ])
    error_message = "Each policy repeat_days: if repeat_type is Weekly, values must be 0-6; if Monthly, values must be 1-31."
  }

  validation {
    condition = alltrue([
      for config in var.vpc_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) :
        policy.end_time == null || policy.start_time == null || try(policy.end_time >= policy.start_time + 1800, false)
      ])
    ])
    error_message = "Each policy end_time must be at least 30 minutes (1800 seconds) later than start_time."
  }
}

variable "nat_firewalls" {
  description = "List of NAT Gateway Firewall configurations"
  type = list(object({
    nat_gateway_id = string
    proxy_name     = string
    region_no      = string
    vpc_id         = string
    nat_route_entry_list = list(object({
      destination_cidr = optional(string)
      nexthop_id       = optional(string)
      route_table_id   = string
    }))
    firewall_switch = optional(string)
    lang            = optional(string)
    strict_mode     = optional(number)
    vswitch_auto    = optional(bool)
    vswitch_id      = optional(string)
    vswitch_cidr    = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls : firewall.firewall_switch == null || try(contains(["open", "close"], firewall.firewall_switch), false)
    ])
    error_message = "Each firewall firewall_switch must be either 'open' or 'close'."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls : firewall.lang == null || try(contains(["zh", "en"], firewall.lang), false)
    ])
    error_message = "Each firewall lang must be either 'zh' or 'en'."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls : firewall.strict_mode == null || try(contains([0, 1], firewall.strict_mode), false)
    ])
    error_message = "Each firewall strict_mode must be either 0 (Disable) or 1 (Enable)."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls : length(firewall.nat_route_entry_list) > 0
    ])
    error_message = "Each firewall nat_route_entry_list must contain at least one route entry."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls : alltrue([
        for entry in firewall.nat_route_entry_list : entry.destination_cidr == null || try(can(cidrhost(entry.destination_cidr, 0)), false)
      ])
    ])
    error_message = "Each nat_route_entry destination_cidr must be a valid CIDR block if provided."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls :
      firewall.vswitch_auto == null || firewall.vswitch_auto == true || try(
        firewall.vswitch_auto == false && firewall.vswitch_id != null && firewall.vswitch_id != "",
        false
      )
    ])
    error_message = "Each firewall: if vswitch_auto is false (manual mode), vswitch_id is required."
  }

  validation {
    condition = alltrue([
      for firewall in var.nat_firewalls :
      firewall.vswitch_auto == null || firewall.vswitch_auto == false || try(
        firewall.vswitch_auto == true && firewall.vswitch_cidr != null && firewall.vswitch_cidr != "",
        false
      )
    ])
    error_message = "Each firewall: if vswitch_auto is true (automatic mode), vswitch_cidr is required."
  }
}

variable "nat_firewall_control_policies" {
  description = "List of NAT Gateway firewall control policy configurations grouped by nat_gateway_id. Each configuration includes nat_gateway_id, control_policies (inline), and optional control_policy_file_path (file config). File config takes precedence over inline config. Direction is fixed to 'out' and new_order is fixed to 1."
  type = list(object({
    nat_gateway_id = string
    control_policies = optional(list(object({
      description           = string
      source                = string
      destination           = string
      proto                 = string
      acl_action            = string
      source_type           = string
      destination_type      = string
      dest_port             = optional(string)
      dest_port_group       = optional(string)
      dest_port_type        = optional(string)
      application_name_list = list(string)
      release               = optional(bool)
      domain_resolve_type   = optional(number)
      repeat_type           = optional(string, "Permanent")
      repeat_days           = optional(list(string))
      repeat_end_time       = optional(string)
      repeat_start_time     = optional(string)
      start_time            = optional(number)
      end_time              = optional(number)
      ip_version            = optional(number, 4)
    })), [])
    control_policy_file_path = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["ANY", "TCP", "UDP", "ICMP"], policy.proto)
      ])
    ])
    error_message = "Each policy proto must be one of: ANY, TCP, UDP, ICMP."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["accept", "drop", "log"], policy.acl_action)
      ])
    ])
    error_message = "Each policy acl_action must be one of: accept, drop, log."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["net", "group"], policy.source_type)
      ])
    ])
    error_message = "Each policy source_type must be either 'net' or 'group'."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : contains(["net", "group", "domain", "location"], policy.destination_type)
      ])
    ])
    error_message = "Each policy destination_type must be one of: net, group, domain, location."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.dest_port_type == null || try(contains(["port", "group"], policy.dest_port_type), false)
      ])
    ])
    error_message = "Each policy dest_port_type must be either 'port' or 'group'."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : length(policy.application_name_list) > 0
      ])
    ])
    error_message = "Each policy application_name_list must contain at least one application name."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.domain_resolve_type == null || try(contains([0, 1, 2], policy.domain_resolve_type), false)
      ])
    ])
    error_message = "Each policy domain_resolve_type must be one of: 0 (FQDN), 1 (DNS), 2 (FQDN_AND_DNS)."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.repeat_type == null || try(contains(["Permanent", "None", "Daily", "Weekly", "Monthly"], policy.repeat_type), false)
      ])
    ])
    error_message = "Each policy repeat_type must be one of: Permanent, None, Daily, Weekly, Monthly."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) :
        policy.repeat_days == null || try((
          (policy.repeat_type == "Weekly" && length(policy.repeat_days) > 0 && alltrue([
            for day in policy.repeat_days : try(can(tonumber(day)), false) && tonumber(day) >= 0 && tonumber(day) <= 6
          ])) ||
          (policy.repeat_type == "Monthly" && length(policy.repeat_days) > 0 && alltrue([
            for day in policy.repeat_days : try(can(tonumber(day)), false) && tonumber(day) >= 1 && tonumber(day) <= 31
          ]))
          ),
          false
        )
      ])
    ])
    error_message = "Each policy repeat_days: if repeat_type is Weekly, values must be 0-6 (as strings); if Monthly, values must be 1-31 (as strings)."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) :
        policy.end_time == null || policy.start_time == null || try(policy.end_time >= policy.start_time + 1800, false)
      ])
    ])
    error_message = "Each policy end_time must be at least 30 minutes (1800 seconds) later than start_time."
  }

  validation {
    condition = alltrue([
      for config in var.nat_firewall_control_policies : alltrue([
        for policy in try(config.control_policies, []) : policy.ip_version == null || try(contains([4, 6], policy.ip_version), false)
      ])
    ])
    error_message = "Each policy ip_version must be either 4 (IPv4) or 6 (IPv6)."
  }
}
