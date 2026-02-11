# Provider configuration
provider "alicloud" {
  region = "cn-hangzhou"
}

# Test KMS component
module "kms" {
  source = "../../../../components/security/kms"

  create_kms_instance = true
  kms_instance_name   = "test-kms-instance"
  kms_instance_spec   = "1000"
  product_version     = "3"
  kms_key_amount      = 1000
  vpc_name            = "test-kms-vpc"
  vpc_cidr_block      = "10.0.0.0/8"
  vswitch_cidr_block  = "10.0.1.0/24"
  vswitch_name        = "test-kms-vswitch"

  # Zone IDs configuration (first one will be used for VSwitch)
  zone_ids = ["cn-hangzhou-g", "cn-hangzhou-e"]

  # Tags configuration
  vpc_tags = {
    Environment = "test"
    Project     = "landing-zone"
    Component   = "kms"
  }

  vswitch_tags = {
    Environment = "test"
    Project     = "landing-zone"
    Component   = "kms-vswitch"
  }

  kms_instance_tags = {
    Environment = "test"
    Project     = "landing-zone"
    Component   = "kms-instance"
  }
}
