# Enable SLS service
data "alicloud_log_service" "open" {
  provider = alicloud.log_audit
  enable   = "On"
}

# Create SLS project
module "sls_project" {
  source = "../../../modules/sls-project"

  providers = {
    alicloud = alicloud.sls_project
  }

  project_name            = var.project_name
  create_project          = var.create_project
  append_random_suffix    = var.append_random_suffix
  random_suffix_length    = var.random_suffix_length
  random_suffix_separator = var.random_suffix_separator
  description             = var.project_description
  tags                    = var.project_tags

  depends_on = [data.alicloud_log_service.open]
}

# Get project name from module output
locals {
  project_name = module.sls_project.project_name
}

# Query current project to resolve region
data "alicloud_log_projects" "current" {
  provider   = alicloud.sls_project
  name_regex = local.project_name

  depends_on = [module.sls_project]
}

# Extract project region
locals {
  project_region = data.alicloud_log_projects.current.projects[0].region
}

# Create logstores for collection policies that require new logstores
resource "alicloud_log_store" "this" {
  provider = alicloud.sls_project
  for_each = {
    for policy in var.collection_policies : policy.policy_name => policy
    if policy.logstore.create == true
  }

  project_name          = local.project_name
  logstore_name         = each.value.logstore.name != null ? each.value.logstore.name : "central-${each.value.product_code}-${each.value.data_code}-${each.value.policy_name}"
  shard_count           = each.value.logstore.shard_count
  auto_split            = each.value.logstore.auto_split
  max_split_shard_count = each.value.logstore.max_split_shard_count
  append_meta           = each.value.logstore.append_meta
  hot_ttl               = each.value.logstore.hot_ttl
  infrequent_access_ttl = each.value.logstore.infrequent_access_ttl
  mode                  = each.value.logstore.mode
  metering_mode         = each.value.logstore.metering_mode
  telemetry_type        = each.value.logstore.telemetry_type
  retention_period = each.value.logstore.retention_period

  depends_on = [data.alicloud_log_projects.current]
}

# Create SLS collection policies
resource "alicloud_sls_collection_policy" "this" {
  provider = alicloud.log_audit
  for_each = {
    for policy in var.collection_policies : policy.policy_name => policy
  }

  policy_name  = each.value.policy_name
  product_code = each.value.product_code
  enabled      = each.value.enabled
  data_code    = each.value.data_code

  # Configure policy resource scope
  policy_config {
    resource_mode = each.value.policy_config.resource_mode
    instance_ids  = each.value.policy_config.instance_ids
    regions       = each.value.policy_config.regions
    resource_tags = each.value.policy_config.resource_tags
  }

  # Configure data region (optional)
  dynamic "data_config" {
    for_each = each.value.data_config != null ? [each.value.data_config] : []
    content {
      data_region = data_config.value.data_region
    }
  }

  # Configure resource directory scope (optional)
  dynamic "resource_directory" {
    for_each = each.value.resource_directory != null && each.value.resource_directory.enabled ? [each.value.resource_directory] : []
    content {
      account_group_type = coalesce(resource_directory.value.account_group_type, "all")
      members            = resource_directory.value.members
    }
  }

  # Configure centralized log storage
  centralize_config {
    dest_logstore = each.value.logstore.name != null ? each.value.logstore.name : "central-${each.value.product_code}-${each.value.data_code}-${each.value.policy_name}"
    dest_project  = local.project_name
    dest_region   = local.project_region
    # Default 30 days TTL when logstore is not created
    dest_ttl      = each.value.logstore.create ? each.value.logstore.retention_period : 30
  }

  centralize_enabled = true

  depends_on = [alicloud_log_store.this]
}
