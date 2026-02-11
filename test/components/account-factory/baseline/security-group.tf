# Security Groups in Shanghai - Direct Configuration
module "security_groups_sh_direct" {
  source = "../../../../components/account-factory/baseline/security-group"

  providers = {
    alicloud = alicloud.vpc_sh
  }

  vpc_id = module.vpc_networking_sh.vpcs["default-vpc-1"].vpc_id

  security_groups = [
    {
      security_group_name = "sg-web-server"
      description         = "Security group for web servers"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "0.0.0.0/0"
          port_range  = "80/80"
          nic_type    = "intranet"
          description = "Allow HTTP from anywhere"
        }
      ]
    }
  ]

  depends_on = [module.vpc_networking_sh]
}

# Security Groups in Beijing - Loaded from External Files
module "security_groups_bj_from_files" {
  source = "../../../../components/account-factory/baseline/security-group"

  providers = {
    alicloud = alicloud.vpc_bj
  }

  vpc_id = module.vpc_networking_bj.vpcs["default-vpc-1"].vpc_id

  security_group_dir_path = "${path.module}/security-group-configs/sg-bj"

  depends_on = [module.vpc_networking_bj]
}

# Security Groups - Combined Configuration (Direct + External Files)
module "security_groups_sh_combined" {
  source = "../../../../components/account-factory/baseline/security-group"

  providers = {
    alicloud = alicloud.vpc_sh
  }

  vpc_id = module.vpc_networking_sh_no_cen.vpcs["default-vpc-3"].vpc_id

  # Direct security groups
  security_groups = [
    {
      security_group_name = "sg-app-server"
      description         = "Security group for application servers"
      inner_access_policy = "Accept"
      security_group_type = "normal"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
      rules = [
        {
          type        = "ingress"
          ip_protocol = "tcp"
          policy      = "accept"
          priority    = 1
          cidr_ip     = "10.0.0.0/8"
          port_range  = "8080/8080"
          nic_type    = "intranet"
          description = "Allow application traffic from VPC"
        }
      ]
    }
  ]

  # Load additional security groups from directory
  security_group_dir_path = "${path.module}/security-group-configs/sg-sh-combined"

  depends_on = [module.vpc_networking_sh_no_cen]
}

# Outputs for Security Groups
output "security_groups_sh_direct" {
  description = "Security groups output in Shanghai (direct configuration)"
  value       = module.security_groups_sh_direct.security_groups
}

output "security_groups_bj_from_files" {
  description = "Security groups output in Beijing (loaded from files)"
  value       = module.security_groups_bj_from_files.security_groups
}

output "security_groups_sh_combined" {
  description = "Security groups output in Shanghai (combined configuration)"
  value       = module.security_groups_sh_combined.security_groups
}

