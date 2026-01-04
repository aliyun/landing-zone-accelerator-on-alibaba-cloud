terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.262.1"
      configuration_aliases = [alicloud.log_archive, alicloud.oss, alicloud.sls]
    }
  }
  required_version = ">= 0.13"
}
