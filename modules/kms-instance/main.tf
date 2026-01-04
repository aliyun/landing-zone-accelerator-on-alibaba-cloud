# Create KMS instance
resource "alicloud_kms_instance" "this" {
  timeouts {
    delete = "20m"
  }

  instance_name   = var.instance_name
  product_version = var.product_version
  vpc_id          = var.vpc_id

  zone_ids    = var.zone_ids
  vswitch_ids = var.vswitch_ids

  vpc_num = "1" # Single VPC per instance
  key_num = var.key_num
  spec    = var.spec
  tags    = var.tags

  lifecycle {
    ignore_changes = [vpc_num, tags]
  }
}

