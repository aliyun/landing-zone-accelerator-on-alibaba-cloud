variable "cen_instance_id" {
  description = "The ID of the CEN instance."
  type        = string
}

variable "transit_router_id" {
  description = "The ID of the Transit Router to attach the VPN to."
  type        = string
}

variable "customer_gateways" {
  description = "List of customer gateways to create. The following IP addresses are not supported: 100.64.0.0~100.127.255.255, 127.0.0.0~127.255.255.255, 169.254.0.0~169.254.255.255, 224.0.0.0~239.255.255.255, 255.0.0.0~255.255.255.255. Names must be unique across all customer gateways. The combination of ip_address + asn must be unique across all customer gateways."
  type = list(object({
    ip_address  = string
    asn         = optional(string)
    name        = string
    description = optional(string)
    tags        = optional(map(string))
  }))

  validation {
    condition     = length(var.customer_gateways) == length(toset([for v in var.customer_gateways : v.name]))
    error_message = "customer_gateways[].name must be unique across all customer gateways."
  }

  validation {
    condition = length(var.customer_gateways) == length(toset([
      for v in var.customer_gateways : "${v.ip_address}:${v.asn != null ? v.asn : "null"}"
    ]))
    error_message = "customer_gateways[].ip_address + asn combination must be unique across all customer gateways."
  }

  validation {
    condition = alltrue([
      for v in var.customer_gateways : (
        !can(regex("^100\\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\\..*", v.ip_address)) &&
        !can(regex("^127\\..*", v.ip_address)) &&
        !can(regex("^169\\.254\\..*", v.ip_address)) &&
        !can(regex("^22[4-9]\\..*|^23[0-9]\\..*", v.ip_address)) &&
        !can(regex("^255\\..*", v.ip_address))
      )
    ])
    error_message = "IP addresses cannot be in the ranges: 100.64.0.0~100.127.255.255, 127.0.0.0~127.255.255.255, 169.254.0.0~169.254.255.255, 224.0.0.0~239.255.255.255, 255.0.0.0~255.255.255.255."
  }
  validation {
    condition = alltrue([
      for v in var.customer_gateways : (
        v.asn == null || (
          try(tonumber(v.asn) >= 1, false) &&
          try(tonumber(v.asn) <= 4294967295, false) &&
          try(tonumber(v.asn) != 45104, false)
        )
      )
    ])
    error_message = "customer_gateways[].asn must be between 1 and 4294967295, and cannot be 45104."
  }
  validation {
    condition = alltrue([
      for v in var.customer_gateways : (
        try(length(v.name), 0) >= 1 &&
        try(length(v.name), 0) <= 100 &&
        !can(regex("^https?://", v.name))
      )
    ])
    error_message = "customer_gateways[].name must be 1 to 100 characters in length, and cannot start with http:// or https://."
  }
  validation {
    condition = alltrue([
      for v in var.customer_gateways : (
        try(length(v.description), 0) == 0 || (
          try(length(v.description), 0) >= 1 &&
          try(length(v.description), 0) <= 100 &&
          !can(regex("^https?://", v.description))
        )
      )
    ])
    error_message = "customer_gateways[].description can be empty or 1 to 100 characters in length, and cannot start with http:// or https://."
  }
}

variable "ipsec_connection_name" {
  description = "The name of the IPsec-VPN connection."
  type        = string
  default     = null

  validation {
    condition = var.ipsec_connection_name == null || var.ipsec_connection_name == "" || (
      try(length(var.ipsec_connection_name), 0) >= 1 &&
      try(length(var.ipsec_connection_name), 0) <= 128 &&
      !can(regex("^https?://", var.ipsec_connection_name))
    )
    error_message = "ipsec_connection_name can be empty or 1 to 128 characters in length, and cannot start with http:// or https://."
  }
}

variable "local_subnet" {
  description = "The CIDR block(s) on the Alibaba Cloud side. Separate multiple CIDR blocks with commas. Example: 192.168.1.0/24,192.168.2.0/24. If both local_subnet and remote_subnet are set to 0.0.0.0/0, the routing mode is Destination Routing Mode. If both are set to specific CIDR blocks, the routing mode is Interested Traffic Mode (Protected Data Flows)."
  type        = string

  validation {
    condition = alltrue([
      for cidr in split(",", var.local_subnet) : can(cidrhost(trimspace(cidr), 0))
    ])
    error_message = "local_subnet must be valid IPv4 CIDR block(s) separated by commas."
  }
}

variable "remote_subnet" {
  description = "The CIDR block(s) on the on-premises side. Separate multiple CIDR blocks with commas. Example: 192.168.3.0/24,192.168.4.0/24. If both local_subnet and remote_subnet are set to 0.0.0.0/0, the routing mode is Destination Routing Mode. If both are set to specific CIDR blocks, the routing mode is Interested Traffic Mode (Protected Data Flows)."
  type        = string

  validation {
    condition = alltrue([
      for cidr in split(",", var.remote_subnet) : can(cidrhost(trimspace(cidr), 0))
    ])
    error_message = "remote_subnet must be valid IPv4 CIDR block(s) separated by commas."
  }
}

variable "network_type" {
  description = "The network type of the VPN connection. Valid values: public, private."
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.network_type)
    error_message = "network_type must be either 'public' or 'private'."
  }
}

variable "effect_immediately" {
  description = "Whether to apply the configuration immediately. If false, the configuration will be applied after the next restart."
  type        = bool
  default     = false
}

variable "enable_tunnels_bgp" {
  description = "Whether to enable the BGP function for the tunnels in dual-tunnel mode. If enabled, tunnel_bgp_config must be configured for each tunnel in tunnel_options_specification. Available since v1.246.0."
  type        = bool
  default     = false
}

variable "tunnels_bgp_local_asn" {
  description = "The local ASN for BGP routing on both tunnels. This is a shared configuration for all tunnels. Only used when enable_tunnels_bgp is true."
  type        = number
  default     = 45104

  validation {
    condition     = var.tunnels_bgp_local_asn >= 1 && var.tunnels_bgp_local_asn <= 4294967295
    error_message = "tunnels_bgp_local_asn must be between 1 and 4294967295."
  }
}

variable "tunnel_options_specification" {
  description = "Configure the tunnel. When binding to Transit Router, VPN connection only supports dual-tunnel mode. You must add both tunnels (tunnel_index 1 and 2) for link redundancy. Each tunnel must use a different customer gateway for redundancy. If enable_tunnels_bgp is true, tunnel_bgp_config must be configured for each tunnel. Available since v1.246.0. The customer_gateway_name must reference a name from the customer_gateways map. If psk is not provided in tunnel_ike_config, a random PSK will be generated."
  type = set(object({
    customer_gateway_name = string # Must be a name from customer_gateways map
    enable_dpd            = optional(bool, true)
    enable_nat_traversal  = optional(bool, true)
    tunnel_index          = number
    tunnel_bgp_config = optional(object({
      local_bgp_ip = string # Local BGP IP address for this tunnel
      tunnel_cidr  = string # Tunnel CIDR block for this tunnel (mask length 30 within 169.254.0.0/16)
    }))
    tunnel_ike_config = optional(object({
      ike_auth_alg      = optional(string, "sha1")
      ike_enc_alg       = optional(string, "aes")
      ike_lifetime      = optional(number, 86400)
      ike_mode          = optional(string, "main")
      ike_pfs           = optional(string, "group2")
      ike_version       = optional(string, "ikev2")
      local_id          = optional(string)
      psk               = optional(string)     # If not provided, a random PSK will be generated. PSK supports digits, uppercase/lowercase letters, and special characters: ~`!@#$%^&*()_-+={}[]\|;:',.<>/?
      psk_random_length = optional(number, 16) # Length of randomly generated PSK (1-100), only used when psk is not provided
      remote_id         = optional(string)
    }))
    tunnel_ipsec_config = optional(list(object({
      ipsec_auth_alg = optional(string, "sha1")
      ipsec_enc_alg  = optional(string, "aes")
      ipsec_lifetime = optional(number, 86400)
      ipsec_pfs      = optional(string, "group2")
    })))
  }))

  validation {
    condition     = length(var.tunnel_options_specification) == 2
    error_message = "tunnel_options_specification must contain exactly 2 tunnels (tunnel_index 1 and 2) for dual-tunnel mode."
  }
  validation {
    condition = (
      length([for t in var.tunnel_options_specification : t if t.tunnel_index == 1]) == 1 &&
      length([for t in var.tunnel_options_specification : t if t.tunnel_index == 2]) == 1
    )
    error_message = "tunnel_options_specification must contain tunnels with tunnel_index 1 and 2."
  }
  validation {
    condition = (
      length(var.tunnel_options_specification) == length(toset([for t in var.tunnel_options_specification : t.customer_gateway_name]))
    )
    error_message = "Each tunnel in tunnel_options_specification must use a different customer gateway (customer_gateway_name must be unique across all tunnels)."
  }
  validation {
    condition = alltrue([
      for tunnel in var.tunnel_options_specification :
      tunnel.tunnel_ike_config == null || try(tunnel.tunnel_ike_config.psk_random_length, 16) == null || (
        try(tunnel.tunnel_ike_config.psk_random_length, 16) >= 1 &&
        try(tunnel.tunnel_ike_config.psk_random_length, 16) <= 100
      )
    ])
    error_message = "psk_random_length must be between 1 and 100."
  }
}

variable "transit_router_vpn_attachment_name" {
  description = "The name of the Transit Router VPN attachment."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_vpn_attachment_name == null || var.transit_router_vpn_attachment_name == "" || (
      try(length(var.transit_router_vpn_attachment_name), 0) >= 1 &&
      try(length(var.transit_router_vpn_attachment_name), 0) <= 128 &&
      !can(regex("^https?://", var.transit_router_vpn_attachment_name))
    )
    error_message = "transit_router_vpn_attachment_name can be empty or 1 to 128 characters in length, and cannot start with http:// or https://."
  }
}

variable "transit_router_vpn_attachment_description" {
  description = "The description of the Transit Router VPN attachment."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_vpn_attachment_description == null || var.transit_router_vpn_attachment_description == "" || (
      try(length(var.transit_router_vpn_attachment_description), 0) >= 1 &&
      try(length(var.transit_router_vpn_attachment_description), 0) <= 256 &&
      !can(regex("^https?://", var.transit_router_vpn_attachment_description))
    )
    error_message = "transit_router_vpn_attachment_description can be empty or 1 to 256 characters in length, and cannot start with http:// or https://."
  }
}

variable "auto_publish_route_enabled" {
  description = "Whether to automatically publish routes to the Transit Router route table."
  type        = bool
  default     = true
}

variable "cen_tr_route_table_association_enabled" {
  description = "Whether to enable route table association for the Transit Router VPN attachment."
  type        = bool
  default     = false
}

variable "cen_tr_route_table_propagation_enabled" {
  description = "Whether to enable route table propagation (route learning) for the Transit Router VPN attachment."
  type        = bool
  default     = false
}

variable "cen_tr_route_table_id" {
  description = "The ID of the Transit Router route table for association and propagation. Required when cen_tr_route_table_association_enabled or cen_tr_route_table_propagation_enabled is true."
  type        = string
  default     = null
}

variable "ipsec_connection_resource_group_id" {
  description = "The ID of the resource group for the IPsec-VPN connection. Available since v1.246.0."
  type        = string
  default     = null
}

variable "ipsec_connection_tags" {
  description = "A map of tags to assign to the IPsec-VPN connection. Available since v1.246.0."
  type        = map(string)
  default     = null
}

variable "transit_router_vpn_attachment_tags" {
  description = "A map of tags to assign to the Transit Router VPN attachment."
  type        = map(string)
  default     = null
}
