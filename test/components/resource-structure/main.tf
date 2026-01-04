provider "alicloud" {
  region = "cn-hangzhou"
}

# Test configuration for folders component
module "folders" {
  source = "../../../components/resource-structure/folders"

  # Use file-based folder structure
  folder_structure_file_path = "${path.module}/folders.yaml"
}

# Test configuration for accounts component
module "accounts" {
  source = "../../../components/resource-structure/accounts"

  resource_directory_id = module.folders.resource_directory_id
  default_folder_id     = module.folders.folders_by_level.level1["Core"].id

  # Account mapping configuration
  account_mapping = {
    log = {
      account_name_prefix = "log"
      display_name        = "Test Log Management Account"
      billing_type        = "Trusteeship"
    }
    security = {
      account_name_prefix = "security"
      display_name        = "Test Security Account"
      billing_type        = "Self-pay"
      folder_id           = module.folders.folders_by_level.level2["Web-Services-Prod"].id
    }
    network = {
      account_name_prefix = "network"
      display_name        = "Test Network Account"
      billing_type        = "Self-pay"
      # Uses default_folder_id since folder_id is not specified
    }
  }

  # Service delegation configuration
  delegated_services = {
    "cloudfw.aliyuncs.com"     = ["security"]
    "actiontrail.aliyuncs.com" = ["log"]
    "config.aliyuncs.com"      = ["log"]
  }

  depends_on = [module.folders]
}

# Outputs for testing
output "resource_directory_id" {
  value = module.folders.resource_directory_id
}

output "folder_structure" {
  value = module.folders.folder_structure
}

output "root_folder_id" {
  value = module.folders.root_folder_id
}

output "folders_by_level" {
  value = module.folders.folders_by_level
}

output "accounts" {
  value = module.accounts.accounts
}

output "role_to_account_mapping" {
  value = module.accounts.role_to_account_mapping
}

output "delegated_services" {
  value = module.accounts.delegated_services
}
