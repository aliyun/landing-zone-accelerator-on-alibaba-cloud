variable "cen_instance_id" {
  description = "The ID of the CEN instance to which the VPC will be attached"
  type        = string
}

variable "cen_tr_id" {
  description = "The ID of the CEN transit router where the VPC attachment will be created"
  type        = string
}

variable "cen_tr_route_table_id" {
  description = "The ID of the transit router route table for association and propagation"
  type        = string
  default     = ""
}

variable "cen_tr_attachment_name" {
  description = "The name of the transit router VPC attachment"
  type        = string
  default     = ""

  validation {
    condition = var.cen_tr_attachment_name == "" || (
      length(var.cen_tr_attachment_name) >= 2 &&
      length(var.cen_tr_attachment_name) <= 128 &&
      can(regex("^[a-zA-Z][a-zA-Z0-9_-]*$", var.cen_tr_attachment_name))
    )
    error_message = "The name must be 2 to 128 characters in length, and can contain letters, digits, underscores (_), and hyphens (-). It must start with a letter."
  }
}

variable "cen_tr_attachment_description" {
  description = "The description of the transit router VPC attachment"
  type        = string
  default     = ""

  validation {
    condition = var.cen_tr_attachment_description == "" || (
      length(var.cen_tr_attachment_description) >= 2 &&
      length(var.cen_tr_attachment_description) <= 256 &&
      can(regex("^[a-zA-Z]", var.cen_tr_attachment_description)) &&
      !can(regex("^(http://|https://)", var.cen_tr_attachment_description))
    )
    error_message = "The description must be 2 to 256 characters in length. The description must start with a letter but cannot start with http:// or https://."
  }
}

variable "vpc_id" {
  description = "The ID of the VPC to attach to the CEN transit router"
  type        = string
}

variable "vpc_attachment_vswitches" {
  description = "List of vSwitch information for the VPC attachment. At least 2 vSwitches are required."
  type = list(object({
    vswitch_id = string
    zone_id    = optional(string)
  }))

  validation {
    condition     = length(var.vpc_attachment_vswitches) >= 2
    error_message = "At least 2 vSwitches are required for VPC attachment."
  }
}

variable "cen_tr_route_table_association_enabled" {
  description = "Whether to enable route table association for the VPC attachment"
  type        = bool
  default     = false
}

variable "cen_tr_route_table_propagation_enabled" {
  description = "Whether to enable route table propagation for the VPC attachment"
  type        = bool
  default     = false
}

variable "cen_tr_attachment_auto_publish_route_enabled" {
  description = "Specifies whether to enable the Enterprise Edition transit router to automatically advertise routes to VPCs"
  type        = bool
  default     = false
}

variable "cen_tr_attachment_force_delete" {
  description = "Whether to forcibly delete the VPC connection. When true, all related dependencies are deleted by default"
  type        = bool
  default     = false
}

variable "cen_tr_attachment_payment_type" {
  description = "The billing method. Default value is PayAsYouGo"
  type        = string
  default     = "PayAsYouGo"

  validation {
    condition     = var.cen_tr_attachment_payment_type == "PayAsYouGo"
    error_message = "payment_type must be PayAsYouGo."
  }
}

variable "cen_tr_attachment_tags" {
  description = "The tags of the VPC attachment resource"
  type        = map(string)
  default     = {}
}

variable "cen_tr_attachment_options" {
  description = "TransitRouterVpcAttachmentOptions for the VPC attachment"
  type        = map(string)
  default     = { "ipv6Support" = "disable" }
}

variable "cen_tr_attachment_resource_type" {
  description = "The resource type of the transit router vpc attachment. Default value: VPC"
  type        = string
  default     = "VPC"

  validation {
    condition     = var.cen_tr_attachment_resource_type == "VPC"
    error_message = "resource_type must be VPC."
  }
}

variable "vpc_route_table_id" {
  description = "The ID of the VPC route table where route entries will be added. Required when vpc_route_entries is not empty."
  type        = string
  default     = null
}

variable "vpc_route_entries" {
  description = "List of route entries to add to the VPC route table. All entries will use the transit router attachment as the next hop (nexthop_type is fixed to Attachment)."
  type = list(object({
    destination_cidrblock = string
    name                  = optional(string)
    description           = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for entry in var.vpc_route_entries : can(cidrhost(entry.destination_cidrblock, 0))
    ])
    error_message = "Each vpc_route_entry must have a valid destination_cidrblock (valid IPv4 CIDR block)."
  }

  validation {
    condition = alltrue([
      for entry in var.vpc_route_entries : entry.name == null || (
        try(length(entry.name), 0) >= 1 &&
        try(length(entry.name), 0) <= 128 &&
        !can(regex("^https?://", entry.name))
      )
    ])
    error_message = "Each vpc_route_entry.name must be 1-128 characters and cannot start with http:// or https://."
  }

  validation {
    condition = alltrue([
      for entry in var.vpc_route_entries : entry.description == null || (
        try(length(entry.description), 0) >= 1 &&
        try(length(entry.description), 0) <= 256 &&
        !can(regex("^https?://", entry.description))
      )
    ])
    error_message = "Each vpc_route_entry.description must be 1-256 characters and cannot start with http:// or https://."
  }
}

variable "cen_service_linked_role_exists" {
  description = "Whether the CEN service-linked role already exists. If true, the module will not create the service-linked role. If false, the module will create it."
  type        = bool
  default     = false
}

variable "create_cen_instance_grant" {
  description = "Whether to create CEN instance grant for cross-account attachment. "
  type        = bool
  default     = false
}







