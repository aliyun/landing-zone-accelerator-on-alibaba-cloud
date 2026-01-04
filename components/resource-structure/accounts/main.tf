# Get current account information
data "alicloud_account" "current" {}

# Parse account mapping to handle multiple roles per account
# Supports comma-separated roles in the key (e.g., "log,security" => roles: ["log", "security"])
locals {
  parsed_account_mapping = {
    for key, account in var.account_mapping :
    key => {
      roles    = can(regex(",", key)) ? split(",", key) : [key]
      account  = account
      group_id = can(regex(",", key)) ? join("+", sort(split(",", key))) : key
    }
  }

  # Map each role to its group ID for delegation lookup
  role_to_group_id = merge([
    for key, parsed in local.parsed_account_mapping : {
      for role in parsed.roles : role => parsed.group_id
    }
  ]...)

  # Get unique account group IDs (accounts with same roles share the same group ID)
  unique_account_group_ids = distinct([
    for parsed in local.parsed_account_mapping : parsed.group_id
  ])

  # Map group ID to roles for account configuration
  group_id_to_roles = {
    for gid in local.unique_account_group_ids :
    gid => [
      for key, parsed in local.parsed_account_mapping :
      parsed.roles if parsed.group_id == gid
    ][0]
  }

  # Build account configurations from parsed mapping
  account_configs = {
    for gid in local.unique_account_group_ids :
    gid => {
      roles               = local.group_id_to_roles[gid]
      primary_role        = local.group_id_to_roles[gid][0]
      account_name_prefix = [for key, parsed in local.parsed_account_mapping : parsed.account.account_name_prefix if parsed.group_id == gid][0]
      display_name        = [for key, parsed in local.parsed_account_mapping : parsed.account.display_name if parsed.group_id == gid][0]
      billing_type        = [for key, parsed in local.parsed_account_mapping : parsed.account.billing_type if parsed.group_id == gid][0]
      billing_account_id  = [for key, parsed in local.parsed_account_mapping : parsed.account.billing_account_id if parsed.group_id == gid][0]
      folder_id = coalesce(
        [for key, parsed in local.parsed_account_mapping : parsed.account.folder_id if parsed.group_id == gid][0],
        var.default_folder_id
      )
      tags = [for key, parsed in local.parsed_account_mapping : parsed.account.tags if parsed.group_id == gid][0]
    }
  }

  # Collect all roles available for service delegation
  available_roles_for_delegation = flatten([
    for gid, config in local.account_configs : [
      for role in config.roles : role
    ]
  ])

  # Validate that all specified admin roles exist in account mapping
  specified_admin_roles = flatten(values(var.delegated_services))
  invalid_admin_roles = [
    for role in local.specified_admin_roles :
    role if !contains(local.available_roles_for_delegation, role)
  ]
}

# Create member accounts
resource "alicloud_resource_manager_account" "account" {
  for_each = local.account_configs

  display_name        = each.value.display_name
  account_name_prefix = each.value.account_name_prefix
  folder_id           = each.value.folder_id
  tags                = each.value.tags
  payer_account_id = each.value.billing_type == "Trusteeship" ? (
    each.value.billing_account_id != null ? each.value.billing_account_id : data.alicloud_account.current.id
  ) : null

  depends_on = [
    var.resource_directory_id,
  ]

  lifecycle {
    ignore_changes = [
      account_name_prefix,
      timeouts,
    ]
  }
}

# Build service-role to account ID mapping for delegation
# Format: "service:role" -> account_id
# Only includes roles that exist in account_mapping
locals {
  service_role_delegated_admins = {
    for entry in flatten([
      for service, roles in var.delegated_services : [
        for role in roles : {
          key      = "${service}:${role}"
          service  = service
          role     = role
          group_id = local.role_to_group_id[role]
        } if contains(local.available_roles_for_delegation, role) && contains(keys(alicloud_resource_manager_account.account), local.role_to_group_id[role])
      ]
    ]) :
    entry.key => alicloud_resource_manager_account.account[entry.group_id].id
  }
}

# Validate that all specified admin roles exist in account mapping
resource "null_resource" "validate_delegated_admin_roles" {
  count = length(local.invalid_admin_roles) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: The following roles specified in delegated_services do not have corresponding enabled accounts: ${join(", ", local.invalid_admin_roles)}. Please enable these accounts or remove them from delegated_services.' >&2 && exit 1"
  }
}

# Configure service delegation administrators
resource "alicloud_resource_manager_delegated_administrator" "service_specific" {
  for_each = length(local.invalid_admin_roles) == 0 ? local.service_role_delegated_admins : {}

  # Extract service name from key (format: "service:role")
  service_principal = split(":", each.key)[0]
  account_id        = each.value

  depends_on = [
    var.resource_directory_id,
    alicloud_resource_manager_account.account,
    null_resource.validate_delegated_admin_roles,
  ]
}

