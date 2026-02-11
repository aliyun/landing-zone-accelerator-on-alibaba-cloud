# CEN VPN Connection (IPsec-VPN dual-tunnel mode)
module "cen_vpn_connection" {
  source = "../../../components/network/cen-vpn-connection"

  providers = {
    alicloud = alicloud.cen_sh
  }

  cen_instance_id   = module.cen_instance.cen_instance_id
  transit_router_id = module.cen_transit_router_sh.transit_router_id

  # Create two customer gateways for dual-tunnel redundancy
  customer_gateways = [
    {
      ip_address  = "114.114.114.114"
      asn         = "45105"
      name        = "on-premises-gateway-1"
      description = "Primary on-premises VPN gateway"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    },
    {
      ip_address  = "114.114.114.115"
      asn         = "45105"
      name        = "on-premises-gateway-2"
      description = "Secondary on-premises VPN gateway"
      tags = {
        Environment = "test"
        Project     = "landing-zone"
      }
    }
  ]

  # IPsec-VPN connection configuration
  ipsec_connection_name = "lz-ipsec-vpn-connection"

  # Interested Traffic Mode (Protected Data Flows)
  # Only traffic matching these CIDR blocks will be routed through VPN
  local_subnet  = "10.0.0.0/8"     # Alibaba Cloud side CIDR
  remote_subnet = "192.168.0.0/16" # On-premises side CIDR

  network_type       = "public"
  effect_immediately = false

  # Enable BGP for both tunnels
  enable_tunnels_bgp    = true
  tunnels_bgp_local_asn = 45104

  # Configure two tunnels with different customer gateways
  tunnel_options_specification = [
    {
      customer_gateway_name = "on-premises-gateway-1"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 1

      # BGP configuration for tunnel 1
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.11.1"
        tunnel_cidr  = "169.254.11.0/30"
      }

      # IKE configuration for tunnel 1
      tunnel_ike_config = {
        ike_version       = "ikev2"
        ike_mode          = "main"
        ike_enc_alg       = "aes256"
        ike_auth_alg      = "sha256"
        ike_pfs           = "group2"
        ike_lifetime      = 28800
        remote_id         = "114.114.114.114"
        psk_random_length = 32
      }

      # IPsec configuration for tunnel 1
      tunnel_ipsec_config = [
        {
          ipsec_enc_alg  = "aes256"
          ipsec_auth_alg = "sha256"
          ipsec_pfs      = "group2"
          ipsec_lifetime = 3600
        }
      ]
    },
    {
      customer_gateway_name = "on-premises-gateway-2"
      enable_dpd            = true
      enable_nat_traversal  = true
      tunnel_index          = 2

      # BGP configuration for tunnel 2
      tunnel_bgp_config = {
        local_bgp_ip = "169.254.12.1"
        tunnel_cidr  = "169.254.12.0/30"
      }

      # IKE configuration for tunnel 2
      tunnel_ike_config = {
        ike_version  = "ikev2"
        ike_mode     = "main"
        ike_enc_alg  = "aes256"
        ike_auth_alg = "sha256"
        ike_pfs      = "group2"
        ike_lifetime = 28800
        remote_id    = "114.114.114.114"
        psk          = "YourSecurePreSharedKey456!"
      }

      # IPsec configuration for tunnel 2
      tunnel_ipsec_config = [
        {
          ipsec_enc_alg  = "aes256"
          ipsec_auth_alg = "sha256"
          ipsec_pfs      = "group2"
          ipsec_lifetime = 3600
        }
      ]
    }
  ]

  # Transit Router VPN attachment configuration
  transit_router_vpn_attachment_name        = "lz-tr-vpn-attachment"
  transit_router_vpn_attachment_description = "Transit Router VPN attachment for on-premises connectivity"
  auto_publish_route_enabled                = true

  # Enable route table association and propagation
  cen_tr_route_table_association_enabled = true
  cen_tr_route_table_propagation_enabled = true
  cen_tr_route_table_id                  = module.cen_transit_router_sh.system_transit_router_route_table_id

  # Resource group and tags
  ipsec_connection_resource_group_id = null
  ipsec_connection_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }

  transit_router_vpn_attachment_tags = {
    Environment = "test"
    Project     = "landing-zone"
  }
}

output "vpn_customer_gateway_ids" {
  description = "The IDs of the customer gateways"
  value       = module.cen_vpn_connection.customer_gateway_ids
}

output "vpn_customer_gateways" {
  description = "The customer gateway details"
  value       = module.cen_vpn_connection.customer_gateways
}

output "vpn_ipsec_connection_id" {
  description = "The ID of the IPsec-VPN connection"
  value       = module.cen_vpn_connection.ipsec_connection_id
}

output "vpn_ipsec_connection" {
  description = "The IPsec-VPN connection details"
  value       = module.cen_vpn_connection.ipsec_connection
}

output "vpn_transit_router_attachment_id" {
  description = "The ID of the Transit Router VPN attachment"
  value       = module.cen_vpn_connection.transit_router_vpn_attachment_id
}

output "vpn_route_table_association_id" {
  description = "The ID of the route table association"
  value       = module.cen_vpn_connection.route_table_association_id
}

output "vpn_route_table_propagation_id" {
  description = "The ID of the route table propagation"
  value       = module.cen_vpn_connection.route_table_propagation_id
}

output "tunnel_psks" {
  description = "The PSKs for each tunnel"
  value       = module.cen_vpn_connection.tunnel_psks
}
