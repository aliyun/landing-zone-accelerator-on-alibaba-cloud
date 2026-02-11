terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.267.0"
      configuration_aliases = [alicloud.log_archive, alicloud.oss, alicloud.sls]
    }
  }
  required_version = ">= 1.2"
}
