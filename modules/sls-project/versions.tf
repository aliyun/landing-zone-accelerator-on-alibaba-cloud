terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = ">= 1.262.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
  required_version = ">= 0.13"
}
