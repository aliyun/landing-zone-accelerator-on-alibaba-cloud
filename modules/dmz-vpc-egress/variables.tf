variable "vpc_id" {
  description = "The ID of the VPC that requires Internet egress through DMZ."
  type        = string
}

variable "route_table_id" {
  description = "The ID of the route table in the VPC. If not specified, the system route table will be used."
  type        = string
  default     = null
}

variable "vpc_tr_attachment_id" {
  description = "The ID of the VPC transit router attachment for routing Internet traffic."
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block routed from VPC to DMZ."
  type        = string

  validation {
    condition     = can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.cidr_block))
    error_message = "cidr_block must be a valid IPv4 CIDR block, e.g., 192.168.1.0/24."
  }
}

variable "dmz_vpc_id" {
  description = "The ID of the DMZ VPC that provides Internet egress services."
  type        = string
}

variable "dmz_route_table_id" {
  description = "The ID of the route table in the DMZ VPC. If not specified, the system route table will be used."
  type        = string
  default     = null
}

variable "dmz_vpc_tr_attachment_id" {
  description = "The ID of the DMZ VPC transit router attachment for routing traffic."
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway in the DMZ VPC for SNAT configuration."
  type        = string
}

variable "snat_table_id" {
  description = "The ID of the SNAT table in the NAT Gateway. If not specified, the first SNAT table will be used."
  type        = string
  default     = null
}

variable "eip_addresses" {
  description = "List of EIP addresses for SNAT configuration."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.eip_addresses : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))
    ])
    error_message = "Each eip_addresses element must be a valid IPv4 address, e.g., 203.0.113.1."
  }
}
