# Get current account information
data "alicloud_account" "current" {
}

# Get resource directory information
data "alicloud_resource_manager_resource_directories" "default" {
}

# Create member account in resource directory
resource "alicloud_resource_manager_account" "account" {
  account_name_prefix = var.account_name_prefix
  display_name        = var.display_name
  folder_id           = var.parent_folder_id != null ? var.parent_folder_id : data.alicloud_resource_manager_resource_directories.default.directories[0].root_folder_id
  payer_account_id    = var.billing_type == "Trusteeship" ? (var.billing_account_id != null ? var.billing_account_id : data.alicloud_account.current.id) : null
  tags                = var.tags
}
