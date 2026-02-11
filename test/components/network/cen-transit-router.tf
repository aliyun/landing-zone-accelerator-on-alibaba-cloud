# Transit Router for Beijing region
module "cen_transit_router_bj" {
  source = "../../../components/network/cen-transit-router"

  providers = {
    alicloud = alicloud.cen_bj
  }

  cen_instance_id            = module.cen_instance.cen_instance_id
  transit_router_name        = "lz-tr-bj"
  transit_router_description = "Landing Zone Transit Router for Beijing region"
  transit_router_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }
}

# Transit Router for Shanghai region
module "cen_transit_router_sh" {
  source = "../../../components/network/cen-transit-router"

  providers = {
    alicloud = alicloud.cen_sh
  }

  cen_instance_id            = module.cen_instance.cen_instance_id
  transit_router_name        = "lz-tr-sh"
  transit_router_description = "Landing Zone Transit Router for Shanghai region"
  transit_router_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  # CIDR blocks for Transit Router
  transit_router_cidrs = [
    {
      cidr                     = "172.16.0.0/24"
      description              = "CIDR block for VPN IPs in Shanghai Transit Router"
      publish_cidr_route       = true
      transit_router_cidr_name = "tr-sh-cidr"
    },
    {
      cidr = "172.16.1.0/24"
    }
  ]
}

output "transit_router_shanghai_id" {
  description = "The ID of the Transit Router created for Shanghai region"
  value       = module.cen_transit_router_sh.transit_router_id
}

output "system_transit_router_route_table_shanghai_id" {
  description = "The system route table ID of the Transit Router for Shanghai"
  value       = module.cen_transit_router_sh.system_transit_router_route_table_id
}

output "transit_router_beijing_id" {
  description = "The ID of the Transit Router created for Beijing region"
  value       = module.cen_transit_router_bj.transit_router_id
}

output "system_transit_router_route_table_beijing_id" {
  description = "The system route table ID of the Transit Router for Beijing"
  value       = module.cen_transit_router_bj.system_transit_router_route_table_id
}

