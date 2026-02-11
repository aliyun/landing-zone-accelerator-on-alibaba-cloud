output "customer_gateway_ids" {
  description = "Map of customer gateway IDs, keyed by customer gateway name."
  value = {
    for k, gw in alicloud_vpn_customer_gateway.customer_gateway : k => gw.id
  }
}

output "customer_gateways" {
  description = "Map of customer gateway details, keyed by customer gateway name."
  value = {
    for k, gw in alicloud_vpn_customer_gateway.customer_gateway : k => {
      id          = gw.id
      ip_address  = gw.ip_address
      asn         = gw.asn
      name        = gw.customer_gateway_name
      description = gw.description
    }
  }
}

output "ipsec_connection_id" {
  description = "The ID of the IPsec-VPN connection in dual-tunnel mode."
  value       = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.id
}

output "ipsec_connection" {
  description = "The IPsec-VPN connection details in dual-tunnel mode."
  value = {
    id                 = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.id
    name               = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.vpn_attachment_name
    local_subnet       = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.local_subnet
    remote_subnet      = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.remote_subnet
    network_type       = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.network_type
    enable_tunnels_bgp = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.enable_tunnels_bgp
    status             = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.status
    create_time        = try(alicloud_vpn_gateway_vpn_attachment.ipsec_connection.create_time, null)
  }
}

output "transit_router_vpn_attachment_id" {
  description = "The ID of the Transit Router VPN attachment."
  value       = alicloud_cen_transit_router_vpn_attachment.transit_router_vpn_attachment.id
}

output "route_table_association_id" {
  description = "The ID of the route table association (if enabled)."
  value       = var.cen_tr_route_table_association_enabled ? alicloud_cen_transit_router_route_table_association.route_table_association[0].id : null
}

output "route_table_propagation_id" {
  description = "The ID of the route table propagation (if enabled)."
  value       = var.cen_tr_route_table_propagation_enabled ? alicloud_cen_transit_router_route_table_propagation.route_table_propagation[0].id : null
}

output "tunnel_psks" {
  description = "Map of PSK values for each tunnel, keyed by customer_gateway_name. Includes both user-provided and auto-generated PSKs."
  value       = local.tunnel_psks
}
