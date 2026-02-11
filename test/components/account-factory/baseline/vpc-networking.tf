# These values are used by VPC networking modules for CEN attachment
locals {
  # CEN instance ID from network test
  cen_instance_id = "cen-jhwbspfj5lnxxxxxxxx"

  # Shanghai Transit Router
  transit_router_shanghai_id                    = "tr-uf6e6h5vv5eigxxxxxx"
  system_transit_router_route_table_shanghai_id = "vtb-uf6edldu59p7vyxxxxx"

  # Beijing Transit Router
  transit_router_beijing_id                    = "tr-2zebnpl3f8z7i3xxxxxx"
  system_transit_router_route_table_beijing_id = "vtb-2zejmwlzglodfcxxxxxx"
}

# VPC Networking in Shanghai - Merged VPCs
module "vpc_networking_sh" {
  source = "../../../../components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc_sh
    alicloud.cen_tr = alicloud.cen_tr_sh
  }

  cen_instance_id           = local.cen_instance_id
  cen_tr_id                 = local.transit_router_shanghai_id
  cen_tr_route_table_id     = local.system_transit_router_route_table_shanghai_id
  create_cen_instance_grant = true

  vpcs = [
    {
      vpc_name        = "default-vpc-1"
      vpc_cidr        = "10.10.0.0/16"
      vpc_description = "Default VPC 1"
      vpc_tags = {
        Environment = "test"
        Project     = "landing-zone"
      }

      vswitches = [
        {
          vswitch_name = "vpc-sh-1-vswitch-1"
          cidr_block   = "10.10.1.0/24"
          zone_id      = "cn-shanghai-l"
          description  = "VPC SH 1 vswitch 1"
          purpose      = "TR"
          tags = {
            Environment = "test"
            Project     = "landing-zone"
          }
        },
        {
          vswitch_name = "vpc-sh-1-vswitch-2"
          cidr_block   = "10.10.2.0/24"
          zone_id      = "cn-shanghai-e"
          description  = "VPC SH 1 vswitch 2"
          purpose      = "TR"
          tags = {
            Environment = "test"
            Project     = "landing-zone"
          }
        },
        {
          vswitch_name = "vpc-sh-1-vswitch-3"
          cidr_block   = "10.10.3.0/24"
          zone_id      = "cn-shanghai-f"
          description  = "VPC SH 1 vswitch 3"
          purpose      = null
          tags = {
            Environment = "test"
            Project     = "landing-zone"
          }
        }
      ]

      cen_attachment = {
        enabled                       = true
        cen_tr_attachment_name        = "vpc-sh-1-tr-attachment"
        cen_tr_attachment_description = "CEN attachment for VPC 1 in Shanghai"
        vpc_route_entries = [
          {
            destination_cidrblock = "0.0.0.0/0"
            name                  = "route-to-tr"
          }
        ]
      }

      security_groups = [
        {
          security_group_name = "default-sg-sh-1"
          description         = "Default security group for VPC 1 in Shanghai"
          security_group_type = "normal"
          tags = {
            Environment = "test"
            Project     = "landing-zone"
          }
          rules = [
            {
              type        = "ingress"
              ip_protocol = "icmp"
              port_range  = "-1/-1"
              cidr_ip     = "0.0.0.0/0"
              policy      = "accept"
              priority    = 1
              nic_type    = "intranet"
              description = "Allow ICMP access"
            }
          ]
        }
      ]
    }
  ]

  vpc_dir_path = "${path.module}/vpc-configs/vpcs-sh"

  depends_on = [module.slr]
}

# VPC Networking in Shanghai - Without CEN (loaded from external files)
module "vpc_networking_sh_no_cen" {
  source = "../../../../components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc_sh
    alicloud.cen_tr = alicloud.cen_tr_sh
  }

  vpc_dir_path = "${path.module}/vpc-configs/vpcs-sh-no-cen"

  depends_on = [module.slr]
}

# VPC Networking in Beijing - Merged VPCs (loaded from external files)
module "vpc_networking_bj" {
  source = "../../../../components/account-factory/baseline/vpc-baseline"

  providers = {
    alicloud.vpc    = alicloud.vpc_bj
    alicloud.cen_tr = alicloud.cen_tr_bj
  }

  cen_instance_id           = local.cen_instance_id
  cen_tr_id                 = local.transit_router_beijing_id
  cen_tr_route_table_id     = local.system_transit_router_route_table_beijing_id
  create_cen_instance_grant = true

  vpc_dir_path = "${path.module}/vpc-configs/vpcs-bj"

  depends_on = [module.slr]
}

# Private Zone (depends on VPCs)
module "private_zone" {
  source = "../../../../modules/private-zone"

  providers = {
    alicloud = alicloud.vpc_sh
  }

  zone_name     = "default.com"
  zone_remark   = "PrivateZone_defaultenv01-2024.06.01"
  proxy_pattern = "ZONE"
  lang          = "en"
  tags = {
    Environment = "default"
    Project     = "landing-zone"
  }

  vpc_bindings = [
    {
      vpc_id    = module.vpc_networking_sh.vpcs["default-vpc-1"].vpc_id
      region_id = "cn-shanghai"
    },
    {
      vpc_id    = module.vpc_networking_sh.vpcs["default-vpc-2"].vpc_id
      region_id = "cn-shanghai"
    },
    {
      vpc_id    = module.vpc_networking_sh_no_cen.vpcs["default-vpc-3"].vpc_id
      region_id = "cn-shanghai"
    },
    {
      vpc_id    = module.vpc_networking_bj.vpcs["default-vpc-1"].vpc_id
      region_id = "cn-beijing"
    },
    {
      vpc_id    = module.vpc_networking_bj.vpcs["default-vpc-2"].vpc_id
      region_id = "cn-beijing"
    }
  ]

  record_entries = [
    {
      name   = "www"
      type   = "A"
      value  = "192.168.0.1"
      ttl    = 60
      lang   = "en"
      remark = "TestA_record"
      status = "ENABLE"
    },
    {
      name     = "mail"
      type     = "MX"
      value    = "mail.default.com"
      ttl      = 60
      lang     = "en"
      priority = 10
      remark   = "TestMX_record"
      status   = "ENABLE"
    }
  ]

  depends_on = [
    module.vpc_networking_sh,
    module.vpc_networking_sh_no_cen,
    module.vpc_networking_bj
  ]
}

# Outputs for VPC Networking and Private Zone
output "vpc_networking_sh" {
  description = "VPC networking output in Shanghai"
  value       = module.vpc_networking_sh.vpcs
}

output "vpc_networking_sh_no_cen" {
  description = "VPC networking output in Shanghai (without CEN)"
  value       = module.vpc_networking_sh_no_cen.vpcs
}

output "vpc_networking_bj" {
  description = "VPC networking output in Beijing"
  value       = module.vpc_networking_bj.vpcs
}

output "private_zone" {
  description = "Private zone output"
  value       = module.private_zone
}

