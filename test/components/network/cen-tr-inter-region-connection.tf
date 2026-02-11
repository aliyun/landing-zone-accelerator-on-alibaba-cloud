# CEN Transit Router Inter-Region Connection (Shanghai to Beijing)
module "cen_tr_inter_region_connection_sh_to_bj" {
  source = "../../../components/network/cen-tr-inter-region-connection"

  providers = {
    alicloud.cen_tr      = alicloud.cen_sh
    alicloud.cen_peer_tr = alicloud.cen_bj
  }

  cen_instance_id                       = module.cen_instance.cen_instance_id
  transit_router_id                     = module.cen_transit_router_sh.transit_router_id
  peer_transit_router_id                = module.cen_transit_router_bj.transit_router_id
  peer_transit_router_region_id         = module.cen_transit_router_bj.transit_router_region_id
  transit_router_peer_attachment_name   = "lz-tr-sh-to-bj"
  transit_router_attachment_description = "Cross-region connection from Shanghai to Beijing"
  bandwidth                             = 1
  bandwidth_type                        = "DataTransfer"
  auto_publish_route_enabled            = true
  # cen_bandwidth_package_id              = module.cen_instance.bandwidth_packages_map["China:China"].bandwidth_package_id
  tags = {
    Environment = "test"
    Project     = "landing-zone"
  }
  tr_route_table_id                       = module.cen_transit_router_sh.system_transit_router_route_table_id
  tr_route_table_association_enabled      = true
  tr_route_table_propagation_enabled      = true
  peer_tr_route_table_id                  = module.cen_transit_router_bj.system_transit_router_route_table_id
  peer_tr_route_table_association_enabled = true
  peer_tr_route_table_propagation_enabled = true

  # Route entries for Shanghai Transit Router (system route table)
  # tr_route_entries = [
  #   {
  #     route_table_id = module.cen_transit_router_sh.system_transit_router_route_table_id
  #     route_entries = [
  #       {
  #         destination_cidrblock = "10.12.0.0/15"
  #         name                  = "route-to-bj-vpcs"
  #         description           = "Route to Beijing VPCs (10.12.0.0/16 and 10.13.0.0/16)"
  #       }
  #     ]
  #   }
  # ]

  # Route entries for Beijing Transit Router (system route table)
  # Default route to Shanghai Transit Router
  # peer_tr_route_entries = [
  #   {
  #     route_table_id = module.cen_transit_router_bj.system_transit_router_route_table_id
  #     route_entries = [
  #       {
  #         destination_cidrblock = "0.0.0.0/0"
  #         name                  = "route-to-sh-tr"
  #         description           = "Default route to Shanghai Transit Router"
  #       }
  #     ]
  #   }
  # ]
}

