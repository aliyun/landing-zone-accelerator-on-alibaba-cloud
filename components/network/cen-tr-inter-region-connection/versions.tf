terraform {
  required_providers {
    alicloud = {
      source                = "hashicorp/alicloud"
      version               = ">= 1.267.0"
      configuration_aliases = [alicloud.cen_tr, alicloud.cen_peer_tr]
    }
  }
  required_version = ">= 1.2"
}
