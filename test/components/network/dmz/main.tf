# Provider configuration for DMZ region
provider "alicloud" {
  alias  = "dmz"
  region = "cn-hangzhou"
}

# Provider configuration for CEN region
provider "alicloud" {
  alias  = "cen"
  region = "cn-hangzhou"
}

# Generate random string for unique resource naming in tests
resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

# Test DMZ component configuration
module "dmz" {
  source = "../../../../components/network/dmz"

  providers = {
    alicloud.dmz = alicloud.dmz
    alicloud.cen = alicloud.cen
  }

  # CEN Configuration - Using real outputs from CEN test
  cen_instance_id               = "cen-xxxxxxxxxxxxxxxxxxx"
  cen_transit_router_id         = "tr-xxxxxxxxxxxxxxxxxxxxx"
  transit_router_route_table_id = "vtb-xxxxxxxxxxxxxxxxxxxx"

  # VPC Configuration
  dmz_vpc_name        = "test-dmz-vpc-${random_string.random.result}"
  dmz_vpc_description = "Comprehensive Test DMZ VPC for landing zone"
  dmz_vpc_cidr        = "10.2.0.0/16"
  dmz_vpc_tags = {
    Environment = "test"
    Project     = "landing-zone"
    Component   = "dmz"
  }

  # NAT Gateway Configuration
  dmz_egress_nat_gateway_name = "test-dmz-nat-${random_string.random.result}"
  dmz_egress_nat_gateway_tags = {
    Environment = "test"
    Project     = "landing-zone"
    Component   = "dmz-nat"
  }

  # EIP Configuration with PayAsYouGo (required for bandwidth package)
  dmz_egress_eip_instances = [
    {
      payment_type     = "PayAsYouGo"
      eip_address_name = "test-dmz-eip-${random_string.random.result}"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
        Type        = "comprehensive"
      }
    }
  ]

  # Common Bandwidth Package Configuration
  dmz_enable_common_bandwidth_package               = true
  dmz_common_bandwidth_package_name                 = "test-dmz-bwp-${random_string.random.result}"
  dmz_common_bandwidth_package_bandwidth            = "5"
  dmz_common_bandwidth_package_internet_charge_type = "PayByBandwidth"

  # Transit Router Vswitches (Primary and Secondary)
  dmz_vswitch_for_tr = [
    {
      zone_id             = "cn-hangzhou-j"
      vswitch_name        = "test-dmz-tr-vsw-1-${random_string.random.result}"
      vswitch_description = "Primary Transit Router vswitch"
      vswitch_cidr        = "10.2.1.0/29"
      tags = {
        Environment = "test"
        Type        = "tr-primary"
      }
    },
    {
      zone_id             = "cn-hangzhou-k"
      vswitch_name        = "test-dmz-tr-vsw-2-${random_string.random.result}"
      vswitch_description = "Secondary Transit Router vswitch"
      vswitch_cidr        = "10.2.1.8/29"
      tags = {
        Environment = "test"
        Type        = "tr-secondary"
      }
    }
  ]

  # NAT Gateway Vswitch
  dmz_vswitch_for_nat_gateway = {
    zone_id             = "cn-hangzhou-j"
    vswitch_name        = "test-dmz-nat-vsw-${random_string.random.result}"
    vswitch_description = "NAT Gateway vswitch"
    vswitch_cidr        = "10.2.2.0/24"
    tags = {
      Environment = "test"
      Type        = "nat-gateway"
    }
  }

  # General Vswitches
  dmz_vswitch = [
    {
      zone_id             = "cn-hangzhou-j"
      vswitch_name        = "test-dmz-vsw-1-${random_string.random.result}"
      vswitch_description = "General vswitch 1"
      vswitch_cidr        = "10.2.3.0/24"
      tags = {
        Environment = "test"
        Type        = "general-1"
      }
    },
    {
      zone_id             = "cn-hangzhou-k"
      vswitch_name        = "test-dmz-vsw-2-${random_string.random.result}"
      vswitch_description = "General vswitch 2"
      vswitch_cidr        = "10.2.4.0/24"
      tags = {
        Environment = "test"
        Type        = "general-2"
      }
    }
  ]

  # Transit Router Attachment Configuration
  dmz_tr_attachment_name        = "test-dmz-tr-attachment-${random_string.random.result}"
  dmz_tr_attachment_description = "Comprehensive Test DMZ Transit Router attachment"

  # Outbound Route Configuration
  dmz_outbound_route_entry_name        = "test-dmz-outbound-route-${random_string.random.result}"
  dmz_outbound_route_entry_description = "Comprehensive Test DMZ outbound route entry"
}

# Outputs for test verification
output "dmz_vpc_id" {
  description = "The ID of the DMZ VPC"
  value       = module.dmz.dmz_vpc_id
}

output "dmz_route_table_id" {
  description = "The route table ID of the DMZ VPC"
  value       = module.dmz.dmz_route_table_id
}

output "dmz_nat_gateway_id" {
  description = "The ID of the DMZ NAT Gateway"
  value       = module.dmz.nat_gateway_id
}

output "dmz_transit_router_attachment_id" {
  description = "The ID of the DMZ Transit Router attachment"
  value       = module.dmz.transit_router_vpc_attachment_id
}

output "dmz_transit_router_outbound_route_entry_id" {
  description = "The ID of the DMZ outbound route entry"
  value       = module.dmz.transit_router_outbound_route_entry_id
}

output "dmz_eip_instances" {
  description = "The EIP instances created for DMZ"
  value       = module.dmz.eip_instances
}

output "dmz_common_bandwidth_package_id" {
  description = "The ID of the DMZ common bandwidth package"
  value       = module.dmz.common_bandwidth_package_id
}

output "dmz_vswitch_for_tr" {
  description = "The Transit Router vswitches for DMZ"
  value       = module.dmz.dmz_vswitch_for_tr
}

output "dmz_vswitch_for_nat_gateway" {
  description = "The NAT Gateway vswitch for DMZ"
  value       = module.dmz.dmz_vswitch_for_nat_gateway
}

output "dmz_vswitch" {
  description = "The general vswitches for DMZ"
  value       = module.dmz.dmz_vswitch
}
