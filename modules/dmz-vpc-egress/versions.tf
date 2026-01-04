terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.262.1"
      configuration_aliases = [alicloud.dmz, alicloud.vpc]
    }
  }
  required_version = ">= 0.13"
}
