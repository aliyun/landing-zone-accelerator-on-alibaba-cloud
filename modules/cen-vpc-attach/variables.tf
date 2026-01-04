variable "cen_instance_id" {
  description = "The ID of the CEN instance to which the VPC will be attached"
  type        = string
}

variable "cen_transit_router_id" {
  description = "The ID of the CEN transit router where the VPC attachment will be created"
  type        = string
}

variable "transit_router_route_table_id" {
  description = "The ID of the transit router route table for association and propagation"
  type        = string
  default     = ""
}

variable "transit_router_attachment_name" {
  description = "The name of the transit router VPC attachment"
  type        = string
  default     = ""
}

variable "transit_router_attachment_description" {
  description = "The description of the transit router VPC attachment"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The ID of the VPC to attach to the CEN transit router"
  type        = string
}

variable "primary_vswitch" {
  description = "Primary vSwitch information for the VPC attachment"
  type = object({
    vswitch_id = string
    zone_id    = string
  })
}

variable "secondary_vswitch" {
  description = "Secondary vSwitch information for the VPC attachment"
  type = object({
    vswitch_id = string
    zone_id    = string
  })
}

variable "route_table_association_enabled" {
  description = "Whether to enable route table association for the VPC attachment"
  type        = bool
  default     = false
}

variable "route_table_propagation_enabled" {
  description = "Whether to enable route table propagation for the VPC attachment"
  type        = bool
  default     = false
}







