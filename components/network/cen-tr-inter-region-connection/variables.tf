variable "cen_instance_id" {
  description = "The ID of the CEN instance."
  type        = string
}

variable "transit_router_id" {
  description = "The ID of the Transit Router."
  type        = string
}

variable "peer_transit_router_id" {
  description = "The ID of the peer Transit Router."
  type        = string
}

variable "peer_transit_router_region_id" {
  description = "The region ID where the peer Transit Router is deployed."
  type        = string
  default     = null
}

variable "transit_router_peer_attachment_name" {
  description = "The name of the peer attachment."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_peer_attachment_name == null || var.transit_router_peer_attachment_name == "" || (
      try(length(var.transit_router_peer_attachment_name), 0) >= 1 &&
      try(length(var.transit_router_peer_attachment_name), 0) <= 128 &&
      !can(regex("^https?://", var.transit_router_peer_attachment_name))
    )
    error_message = "transit_router_peer_attachment_name can be empty or 1 to 128 characters in length, and cannot start with http:// or https://."
  }
}

variable "transit_router_attachment_description" {
  description = "The description of the peer attachment."
  type        = string
  default     = null

  validation {
    condition = var.transit_router_attachment_description == null || var.transit_router_attachment_description == "" || (
      try(length(var.transit_router_attachment_description), 0) >= 1 &&
      try(length(var.transit_router_attachment_description), 0) <= 256 &&
      !can(regex("^https?://", var.transit_router_attachment_description))
    )
    error_message = "transit_router_attachment_description can be empty or 1 to 256 characters in length, and cannot start with http:// or https://."
  }
}

variable "bandwidth" {
  description = "The bandwidth value of the inter-region connection (Mbit/s)."
  type        = number
  default     = 2
}

variable "bandwidth_type" {
  description = "The method to allocate bandwidth: BandwidthPackage or DataTransfer."
  type        = string
  default     = "BandwidthPackage"

  validation {
    condition     = var.bandwidth_type == null || try(contains(["BandwidthPackage", "DataTransfer"], var.bandwidth_type), false)
    error_message = "bandwidth_type must be one of 'BandwidthPackage' or 'DataTransfer'."
  }
}

variable "cen_bandwidth_package_id" {
  description = "The ID of the bandwidth plan (required when bandwidth_type is BandwidthPackage)."
  type        = string
  default     = null
}

variable "default_link_type" {
  description = "The default line type: Platinum or Gold (Platinum only supported when bandwidth_type is DataTransfer)."
  type        = string
  default     = "Gold"

  validation {
    condition     = var.default_link_type == null || try(contains(["Platinum", "Gold"], var.default_link_type), false)
    error_message = "default_link_type must be one of 'Platinum' or 'Gold'."
  }
}

variable "auto_publish_route_enabled" {
  description = "Whether to enable automatic route advertisement to peer transit router."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to assign to the peer attachment."
  type        = map(string)
  default     = {}
}

variable "tr_route_table_id" {
  description = "The route table ID for Transit Router. All route entries use the inter-region connection (peer attachment) as the next hop."
  type        = string
}

variable "tr_route_table_association_enabled" {
  description = "Whether to create route table association for Transit Router."
  type        = bool
  default     = false
}

variable "tr_route_table_propagation_enabled" {
  description = "Whether to create route table propagation for Transit Router."
  type        = bool
  default     = false
}

variable "tr_route_entries" {
  description = "List of route entries for Transit Router route table. All route entries use the inter-region connection (peer attachment) as the next hop."
  type = list(object({
    destination_cidrblock = string
    name                  = optional(string)
    description           = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.tr_route_entries : can(cidrhost(entry.destination_cidrblock, 0))
    ])
    error_message = "Each route entry must have a valid destination_cidrblock (valid IPv4 CIDR block)."
  }

  validation {
    condition = alltrue([
      for entry in var.tr_route_entries : entry.name == null || (
        try(length(entry.name), 0) >= 1 &&
        try(length(entry.name), 0) <= 128 &&
        !can(regex("^https?://", entry.name))
      )
    ])
    error_message = "Each route_entry.name must be 1-128 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for entry in var.tr_route_entries : entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each route_entry.description must be 1-256 characters and cannot start with http:// or https://."
  }
}

variable "peer_tr_route_table_id" {
  description = "The route table ID for peer Transit Router. All route entries use the inter-region connection (peer attachment) as the next hop."
  type        = string
}

variable "peer_tr_route_table_association_enabled" {
  description = "Whether to create route table association for peer Transit Router."
  type        = bool
  default     = false
}

variable "peer_tr_route_table_propagation_enabled" {
  description = "Whether to create route table propagation for peer Transit Router."
  type        = bool
  default     = false
}

variable "peer_tr_route_entries" {
  description = "List of route entries for peer Transit Router route table. All route entries use the inter-region connection (peer attachment) as the next hop."
  type = list(object({
    destination_cidrblock = string
    name                  = optional(string)
    description           = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.peer_tr_route_entries : can(cidrhost(entry.destination_cidrblock, 0))
    ])
    error_message = "Each route entry must have a valid destination_cidrblock (valid IPv4 CIDR block)."
  }

  validation {
    condition = alltrue([
      for entry in var.peer_tr_route_entries : entry.name == null || (
        try(length(entry.name), 0) >= 1 &&
        try(length(entry.name), 0) <= 128 &&
        !can(regex("^https?://", entry.name))
      )
    ])
    error_message = "Each route_entry.name must be 1-128 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for entry in var.peer_tr_route_entries : entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each route_entry.description must be 1-256 characters and cannot start with http:// or https://."
  }
}
