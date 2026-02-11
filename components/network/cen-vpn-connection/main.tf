# Create customer gateways
resource "alicloud_vpn_customer_gateway" "customer_gateway" {
  for_each = { for gw in var.customer_gateways : gw.name => gw }

  ip_address            = each.value.ip_address
  asn                   = each.value.asn
  customer_gateway_name = each.value.name
  description           = each.value.description
  tags                  = each.value.tags
}

# Bridge for replace_triggered_by: Terraform requires the referenced resource to have a "change"
# in the plan; on first apply customer_gateway is only "created" so replace_triggered_by errors.
# terraform_data gets a change on create and when customer_gateway ids change (e.g. after replace).
resource "terraform_data" "customer_gateway_trigger" {
  input = { for k, g in alicloud_vpn_customer_gateway.customer_gateway : k => g.id }
}

# Generate random PSK for tunnels that don't have psk specified
# Random string supports digits, uppercase/lowercase letters, and special characters: ~`!@#$%^&*()_-+={}[]\|;:',.<>/?
# Cannot contain spaces
resource "random_string" "tunnel_psk" {
  for_each = {
    for tunnel in var.tunnel_options_specification :
    tunnel.customer_gateway_name => tunnel
    if tunnel.tunnel_ike_config != null && try(tunnel.tunnel_ike_config.psk, null) == null
  }

  length  = try(each.value.tunnel_ike_config.psk_random_length, 16)
  upper   = true
  lower   = true
  numeric = true
  special = true
}

# Local values for PSK handling
locals {
  # Map of customer_gateway_name to PSK (either provided or generated)
  # If tunnel_ike_config is null, PSK will be null (not needed)
  # If tunnel_ike_config is not null and psk is provided, use provided PSK
  # If tunnel_ike_config is not null but psk is not provided, use generated PSK
  tunnel_psks = {
    for tunnel in var.tunnel_options_specification :
    tunnel.customer_gateway_name => (
      tunnel.tunnel_ike_config != null ? (
        try(tunnel.tunnel_ike_config.psk, null) != null ?
        tunnel.tunnel_ike_config.psk :
        random_string.tunnel_psk[tunnel.customer_gateway_name].result
      ) : null
    )
  }
}

# Create IPsec-VPN connection - Dual-tunnel mode only when binding to Transit Router
resource "alicloud_vpn_gateway_vpn_attachment" "ipsec_connection" {
  vpn_attachment_name = var.ipsec_connection_name
  local_subnet        = var.local_subnet
  remote_subnet       = var.remote_subnet
  network_type        = var.network_type
  effect_immediately  = var.effect_immediately
  resource_group_id   = var.ipsec_connection_resource_group_id
  tags                = var.ipsec_connection_tags
  enable_tunnels_bgp  = var.enable_tunnels_bgp

  dynamic "tunnel_options_specification" {
    for_each = var.tunnel_options_specification
    content {
      customer_gateway_id  = alicloud_vpn_customer_gateway.customer_gateway[tunnel_options_specification.value.customer_gateway_name].id
      enable_dpd           = tunnel_options_specification.value.enable_dpd
      enable_nat_traversal = tunnel_options_specification.value.enable_nat_traversal
      tunnel_index         = tunnel_options_specification.value.tunnel_index

      dynamic "tunnel_bgp_config" {
        for_each = tunnel_options_specification.value.tunnel_bgp_config != null ? [tunnel_options_specification.value.tunnel_bgp_config] : []
        content {
          local_asn    = var.tunnels_bgp_local_asn
          local_bgp_ip = tunnel_bgp_config.value.local_bgp_ip
          tunnel_cidr  = tunnel_bgp_config.value.tunnel_cidr
        }
      }

      dynamic "tunnel_ike_config" {
        for_each = tunnel_options_specification.value.tunnel_ike_config != null ? [tunnel_options_specification.value.tunnel_ike_config] : []
        content {
          ike_auth_alg = tunnel_ike_config.value.ike_auth_alg
          ike_enc_alg  = tunnel_ike_config.value.ike_enc_alg
          ike_lifetime = tunnel_ike_config.value.ike_lifetime
          ike_mode     = tunnel_ike_config.value.ike_mode
          ike_pfs      = tunnel_ike_config.value.ike_pfs
          ike_version  = tunnel_ike_config.value.ike_version
          local_id     = tunnel_ike_config.value.local_id
          psk          = local.tunnel_psks[tunnel_options_specification.value.customer_gateway_name]
          remote_id    = tunnel_ike_config.value.remote_id
        }
      }

      dynamic "tunnel_ipsec_config" {
        for_each = tunnel_options_specification.value.tunnel_ipsec_config != null ? tunnel_options_specification.value.tunnel_ipsec_config : []
        content {
          ipsec_auth_alg = tunnel_ipsec_config.value.ipsec_auth_alg
          ipsec_enc_alg  = tunnel_ipsec_config.value.ipsec_enc_alg
          ipsec_lifetime = tunnel_ipsec_config.value.ipsec_lifetime
          ipsec_pfs      = tunnel_ipsec_config.value.ipsec_pfs
        }
      }
    }
  }

  lifecycle {
    # When any customer_gateway is replaced, trigger input changes and this attachment is replaced.
    replace_triggered_by = [terraform_data.customer_gateway_trigger]
  }
}

# Attach IPsec-VPN connection to CEN Transit Router
resource "alicloud_cen_transit_router_vpn_attachment" "transit_router_vpn_attachment" {
  cen_id                                = var.cen_instance_id
  transit_router_id                     = var.transit_router_id
  vpn_id                                = alicloud_vpn_gateway_vpn_attachment.ipsec_connection.id
  vpn_owner_id                          = null # Same account
  auto_publish_route_enabled            = var.auto_publish_route_enabled
  transit_router_attachment_name        = var.transit_router_vpn_attachment_name
  transit_router_attachment_description = var.transit_router_vpn_attachment_description
  tags                                  = var.transit_router_vpn_attachment_tags

  timeouts {
    create = "15m"
    update = "15m"
    delete = "30m"
  }
}

# Associate Transit Router VPN attachment with route table
resource "alicloud_cen_transit_router_route_table_association" "route_table_association" {
  count                         = var.cen_tr_route_table_association_enabled == true ? 1 : 0
  transit_router_route_table_id = var.cen_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpn_attachment.transit_router_vpn_attachment.id
}

# Enable route table propagation (route learning) for Transit Router VPN attachment
resource "alicloud_cen_transit_router_route_table_propagation" "route_table_propagation" {
  count                         = var.cen_tr_route_table_propagation_enabled == true ? 1 : 0
  transit_router_route_table_id = var.cen_tr_route_table_id
  transit_router_attachment_id  = alicloud_cen_transit_router_vpn_attachment.transit_router_vpn_attachment.id
}
