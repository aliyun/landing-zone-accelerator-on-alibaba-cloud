terraform {
  required_version = ">= 1.2"

  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = "~> 1.267.0"
    }
  }
}

