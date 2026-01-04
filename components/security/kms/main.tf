# Create VPC for KMS instance
resource "alicloud_vpc" "kms_vpc" {
  count = var.create_kms_instance ? 1 : 0

  vpc_name   = var.vpc_name
  cidr_block = var.vpc_cidr_block
  tags       = var.vpc_tags
}

# Create VSwitch for KMS instance
resource "alicloud_vswitch" "kms_vswitch" {
  count = var.create_kms_instance ? 1 : 0

  vpc_id       = alicloud_vpc.kms_vpc[0].id
  cidr_block   = var.vswitch_cidr_block
  zone_id      = var.zone_ids[0]
  vswitch_name = var.vswitch_name
  tags         = var.vswitch_tags
}

# Create KMS instance with high availability
module "kms_instance" {
  source = "../../../modules/kms-instance"
  count  = var.create_kms_instance ? 1 : 0

  instance_name   = var.kms_instance_name
  product_version = var.product_version
  vpc_id          = alicloud_vpc.kms_vpc[0].id

  zone_ids = var.zone_ids

  vswitch_ids = [
    alicloud_vswitch.kms_vswitch[0].id
  ]

  key_num = var.kms_key_amount
  spec    = var.kms_instance_spec
  tags    = var.kms_instance_tags
}
