provider "alicloud" {
  alias  = "cen_sh"
  region = "cn-shanghai"
}

provider "alicloud" {
  alias  = "cen_bj"
  region = "cn-beijing"
}

provider "alicloud" {
  alias  = "dmz"
  region = "cn-shanghai"
}

# CEN instance for network tests (used by DMZ)
module "cen_instance" {
  source = "../../../components/network/cen-instance"

  providers = {
    alicloud = alicloud.cen_sh
  }

  cen_instance_name = "lz-cen"
  description       = "Landing Zone CEN for network tests"
  tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  # CEN Bandwidth Packages for cross-region connectivity
  # bandwidth_packages = [
  #   {
  #     bandwidth                  = 2
  #     geographic_region_a_id     = "China"
  #     geographic_region_b_id     = "China"
  #     cen_bandwidth_package_name = "lz-cen-bwp-china"
  #     description                = "CEN bandwidth package for China regions"
  #     payment_type               = "PrePaid"
  #     pricing_cycle              = "Month"
  #     period                     = 1
  #   },
  #   {
  #     bandwidth                  = 2
  #     geographic_region_a_id     = "Asia-Pacific"
  #     geographic_region_b_id     = "Asia-Pacific"
  #     cen_bandwidth_package_name = "lz-cen-bwp-apac"
  #     description                = "CEN bandwidth package for Asia-Pacific regions"
  #     payment_type               = "PrePaid"
  #     pricing_cycle              = "Month"
  #     period                     = 1
  #   }
  # ]
}

output "cen_instance_id" {
  description = "The ID of the CEN instance created for network tests"
  value       = module.cen_instance.cen_instance_id
}

# output "cen_bandwidth_package_ids" {
#   description = "The IDs of the CEN bandwidth packages"
#   value       = module.cen_instance.bandwidth_package_ids
# }

# output "cen_bandwidth_packages" {
#   description = "The CEN bandwidth packages details"
#   value       = module.cen_instance.bandwidth_packages
# }
