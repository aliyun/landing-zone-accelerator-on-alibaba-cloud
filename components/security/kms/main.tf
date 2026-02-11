# Create VPC and VSwitch for KMS instance
module "kms_vpc" {
  count = var.create_kms_instance ? 1 : 0

  source = "../../../modules/vpc"

  vpc_name        = var.vpc_name
  vpc_cidr        = var.vpc_cidr_block
  vpc_description = null
  vpc_tags        = var.vpc_tags

  vswitches = [
    {
      cidr_block   = var.vswitch_cidr_block
      zone_id      = var.zone_ids[0]
      vswitch_name = var.vswitch_name
      description  = null
      tags         = var.vswitch_tags
    }
  ]
}

locals {
  kms_vpc_id     = var.create_kms_instance ? module.kms_vpc[0].vpc_id : ""
  kms_vswitch_id = var.create_kms_instance ? module.kms_vpc[0].vswitchs[0].id : ""
}

# Create KMS instance with high availability
module "kms_instance" {
  source = "../../../modules/kms-instance"
  count  = var.create_kms_instance ? 1 : 0

  instance_name   = var.kms_instance_name
  product_version = var.product_version
  vpc_id          = local.kms_vpc_id

  zone_ids = var.zone_ids

  vswitch_ids = [
    local.kms_vswitch_id
  ]

  key_num = var.kms_key_amount
  spec    = var.kms_instance_spec
  tags    = var.kms_instance_tags
}
