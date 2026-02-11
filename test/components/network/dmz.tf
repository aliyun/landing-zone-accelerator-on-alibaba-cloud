# DMZ configuration test (includes CEN + TR usage)
module "dmz" {
  source = "../../../components/network/dmz"

  providers = {
    alicloud.dmz    = alicloud.dmz
    alicloud.cen_tr = alicloud.cen_sh
  }

  # CEN Configuration - using outputs from cen-instance & cen-transit-router components
  cen_instance_id               = module.cen_instance.cen_instance_id
  cen_transit_router_id         = module.cen_transit_router_sh.transit_router_id
  transit_router_route_table_id = module.cen_transit_router_sh.system_transit_router_route_table_id

  # VPC Configuration
  dmz_vpc_name        = "lz-dmz-vpc"
  dmz_vpc_description = "Landing Zone DMZ VPC"
  dmz_vpc_cidr        = "10.2.0.0/16"
  dmz_vpc_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  # NAT Gateway Configuration
  dmz_egress_nat_gateway_name        = "lz-dmz-nat"
  dmz_egress_nat_gateway_description = "Landing Zone DMZ NAT Gateway"
  dmz_egress_nat_gateway_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }
  dmz_egress_nat_gateway_deletion_protection  = false
  dmz_egress_nat_gateway_eip_bind_mode        = "MULTI_BINDED"
  dmz_egress_nat_gateway_icmp_reply_enabled   = true
  dmz_egress_nat_gateway_private_link_enabled = false

  # SNAT Configuration
  # This SNAT entry covers all VPC CIDR blocks that need outbound internet access through the DMZ NAT Gateway.
  # It is recommended to plan and allocate a larger CIDR block (e.g., /12) upfront to cover all VPCs that will be
  # connected to the network, rather than creating multiple SNAT entries for individual VPCs. This approach simplifies
  # operations and management by reducing the number of SNAT entries to maintain and update.
  # In this test case, 10.0.0.0/12 covers:
  # - DMZ VPC: 10.2.0.0/16
  # - All baseline VPCs: 10.10.0.0/16, 10.11.0.0/16, 10.12.0.0/16, 10.13.0.0/16
  # (10.0.0.0/12 network range: 10.0.0.0 - 10.15.255.255)
  # The snat_ips will be automatically set to all EIP IPs created by this component.
  dmz_nat_gateway_snat_entries = [
    {
      source_cidr = "10.0.0.0/12"
    }
  ]

  # Route Entry Configuration
  # This route entry routes traffic from the DMZ VPC to the Transit Router for outbound internet access.
  # It uses the same CIDR block (10.8.0.0/13) as the SNAT entry to cover all VPCs that need internet access through DMZ.
  # The route entry uses the Transit Router attachment as the next hop, directing traffic to the DMZ NAT Gateway.
  dmz_vpc_route_entries = [
    {
      destination_cidrblock = "10.8.0.0/13"
    }
  ]

  # EIP Configuration with PayAsYouGo (required for bandwidth package)
  dmz_egress_eip_instances = [
    {
      payment_type         = "PayAsYouGo"
      eip_address_name     = "lz-dmz-eip"
      bandwidth            = 5
      deletion_protection  = false
      internet_charge_type = "PayByBandwidth"
      isp                  = "BGP"
      mode                 = "NAT"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    }
  ]

  # Common Bandwidth Package Configuration
  dmz_enable_common_bandwidth_package                    = true
  dmz_common_bandwidth_package_name                      = "lz-dmz-bwp"
  dmz_common_bandwidth_package_bandwidth                 = "5"
  dmz_common_bandwidth_package_internet_charge_type      = "PayByBandwidth"
  dmz_common_bandwidth_package_ratio                     = 20
  dmz_common_bandwidth_package_deletion_protection       = false
  dmz_common_bandwidth_package_description               = "Landing Zone DMZ Common Bandwidth Package"
  dmz_common_bandwidth_package_isp                       = "BGP"
  dmz_common_bandwidth_package_security_protection_types = []
  dmz_common_bandwidth_package_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  # Vswitches Configuration
  # All vswitches are defined in a single list, using 'purpose' to distinguish their usage:
  # - 'TR' for Transit Router attachment (at least 2 required)
  # - 'NATGW' for NAT Gateway (exactly 1 required)
  # - No purpose or null for normal vswitches
  dmz_vswitch = [
    # Transit Router vswitches (Primary and Secondary)
    {
      zone_id             = "cn-shanghai-l"
      vswitch_name        = "lz-dmz-tr-vsw-1"
      vswitch_description = "Primary Transit Router vswitch"
      vswitch_cidr        = "10.2.1.0/29"
      purpose             = "TR"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    {
      zone_id             = "cn-shanghai-m"
      vswitch_name        = "lz-dmz-tr-vsw-2"
      vswitch_description = "Secondary Transit Router vswitch"
      vswitch_cidr        = "10.2.1.8/29"
      purpose             = "TR"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    {
      zone_id             = "cn-shanghai-n"
      vswitch_name        = "lz-dmz-tr-vsw-3"
      vswitch_description = "Tertiary Transit Router vswitch"
      vswitch_cidr        = "10.2.1.16/29"
      purpose             = "TR"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    # NAT Gateway vswitch
    {
      zone_id             = "cn-shanghai-l"
      vswitch_name        = "lz-dmz-nat-vsw"
      vswitch_description = "NAT Gateway vswitch"
      vswitch_cidr        = "10.2.2.0/28"
      purpose             = "NATGW"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    # General vswitches (no purpose specified)
    {
      zone_id             = "cn-shanghai-l"
      vswitch_name        = "lz-dmz-vsw-1"
      vswitch_description = "General vswitch 1"
      vswitch_cidr        = "10.2.3.0/24"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    {
      zone_id             = "cn-shanghai-m"
      vswitch_name        = "lz-dmz-vsw-2"
      vswitch_description = "General vswitch 2"
      vswitch_cidr        = "10.2.4.0/24"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    }
  ]

  # Transit Router Attachment Configuration
  dmz_tr_attachment_name         = "lz-dmz-tr-attachment"
  dmz_tr_attachment_description  = "Landing Zone DMZ Transit Router attachment"
  dmz_tr_attachment_force_delete = false
  dmz_tr_attachment_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  # Outbound Route Configuration
}

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

