terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.267.0"
      configuration_aliases = [alicloud.log_audit, alicloud.sls_project]
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
  required_version = ">= 1.2"
}
