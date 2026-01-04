# Get current account information
data "alicloud_account" "this" {}

# Get current region information
data "alicloud_regions" "this" {
  current = true
}

# Generate random suffix for project name when requested
resource "random_string" "suffix" {
  count   = var.create_project && var.append_random_suffix ? 1 : 0
  length  = var.random_suffix_length
  upper   = false
  special = false
  numeric = true
}

# Calculate effective project name (with or without random suffix)
locals {
  effective_project_name = var.create_project && var.append_random_suffix ? "${var.project_name}${var.random_suffix_separator}${random_string.suffix[0].result}" : var.project_name
}

# Create SLS project
resource "alicloud_log_project" "project" {
  count        = var.create_project ? 1 : 0
  project_name = local.effective_project_name
  description  = var.description
  tags         = var.tags
}



