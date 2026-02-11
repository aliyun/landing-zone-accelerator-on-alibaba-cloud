terraform {
  required_providers {
    alicloud = {
      source  = "hashicorp/alicloud"
      version = ">= 1.267.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.2"
}

