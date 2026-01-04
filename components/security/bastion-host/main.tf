# Get current account information
data "alicloud_account" "current" {}

# Create service linked role for Bastion Host
module "slr-with-service-name" {
  source = "terraform-alicloud-modules/service-linked-role/alicloud"
  service_linked_role_with_service_names = [
    "bastion_host"
  ]
}

# Create VPC for Bastion Host
resource "alicloud_vpc" "bastion_vpc" {
  count = var.create_bastion_host && var.create_vpc_resources ? 1 : 0

  cidr_block = var.vpc_cidr
  vpc_name   = var.vpc_name
  description = var.vpc_description

  tags = merge(
    var.bastion_host_tags,
    {
      "Name" = var.vpc_name
    }
  )
}

# Create VSwitch for Bastion Host
resource "alicloud_vswitch" "bastion_vswitch" {
  count = var.create_bastion_host && var.create_vpc_resources ? 1 : 0

  vpc_id     = alicloud_vpc.bastion_vpc[0].id
  cidr_block = var.vswitch_cidr
  zone_id    = var.availability_zone
  vswitch_name = var.vswitch_name
  description = var.vswitch_description

  tags = merge(
    var.bastion_host_tags,
    {
      "Name" = var.vswitch_name
    }
  )

  depends_on = [alicloud_vpc.bastion_vpc]
}

# Create Security Group for Bastion Host
resource "alicloud_security_group" "bastion_sg" {
  count = var.create_bastion_host && var.create_vpc_resources ? 1 : 0

  security_group_name = var.security_group_name
  description         = var.security_group_description
  vpc_id              = alicloud_vpc.bastion_vpc[0].id

  tags = merge(
    var.bastion_host_tags,
    {
      "Name" = var.security_group_name
    }
  )

  depends_on = [alicloud_vpc.bastion_vpc]
}

# Allow SSH access to Bastion Host
resource "alicloud_security_group_rule" "allow_ssh" {
  count = var.create_bastion_host && var.create_vpc_resources ? 1 : 0

  type              = var.ssh_rule_type
  ip_protocol       = var.ssh_rule_ip_protocol
  nic_type          = var.ssh_rule_nic_type
  policy            = var.ssh_rule_policy
  port_range        = var.ssh_rule_port_range
  priority          = var.ssh_rule_priority
  security_group_id = alicloud_security_group.bastion_sg[0].id
  cidr_ip           = var.ssh_rule_cidr_ip
}

# Allow HTTPS access to Bastion Host
resource "alicloud_security_group_rule" "allow_https" {
  count = var.create_bastion_host && var.create_vpc_resources ? 1 : 0

  type              = var.https_rule_type
  ip_protocol       = var.https_rule_ip_protocol
  nic_type          = var.https_rule_nic_type
  policy            = var.https_rule_policy
  port_range        = var.https_rule_port_range
  priority          = var.https_rule_priority
  security_group_id = alicloud_security_group.bastion_sg[0].id
  cidr_ip           = var.https_rule_cidr_ip
}

# Wait for service initialization before creating Bastion Host instance
resource "null_resource" "wait_for_service_init" {
  count = var.create_bastion_host ? 1 : 0

  depends_on = [
    module.slr-with-service-name,
    alicloud_vpc.bastion_vpc,
    alicloud_vswitch.bastion_vswitch,
    alicloud_security_group.bastion_sg,
    alicloud_security_group_rule.allow_ssh,
    alicloud_security_group_rule.allow_https
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

# Create Bastion Host instance
resource "alicloud_bastionhost_instance" "default" {
  count = var.create_bastion_host ? 1 : 0

  # Required parameters for bastion host instance
  description        = var.bastion_host_description
  license_code       = var.bastion_host_license_code
  plan_code          = var.bastion_host_plan_code
  storage            = var.bastion_host_storage
  bandwidth          = var.bastion_host_bandwidth
  period             = var.bastion_host_period
  security_group_ids = var.create_vpc_resources ? [alicloud_security_group.bastion_sg[0].id] : var.bastion_host_security_group_ids
  vswitch_id         = var.create_vpc_resources ? alicloud_vswitch.bastion_vswitch[0].id : var.bastion_host_vswitch_id
  
  tags               = var.bastion_host_tags

  depends_on = [
    module.slr-with-service-name,
    alicloud_vpc.bastion_vpc,
    alicloud_vswitch.bastion_vswitch,
    alicloud_security_group.bastion_sg,
    null_resource.wait_for_service_init
  ]
}