terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.262.1"
      configuration_aliases = [alicloud.cen, alicloud.vpc]
    }
  }
  required_version = ">= 0.13"
}
