# Cloud Firewall variables

variable "create_cloud_firewall_instance" {
  description = "Whether to create a cloud firewall instance"
  type        = bool
  default     = true
}

variable "cloud_firewall_instance_type" {
  description = "The type of the cloud firewall instance"
  type        = string
  default     = "premium"
}

variable "cloud_firewall_bandwidth" {
  description = "The bandwidth of the cloud firewall instance"
  type        = number
  default     = 100
}

variable "member_account_ids" {
  description = "List of member account IDs to be managed by the cloud firewall"
  type        = list(string)
  default     = []
}

variable "member_account_ids_dir" {
  description = "Directory path containing member account configuration files (JSON/YAML). Files in this directory are loaded and merged with member_account_ids parameter, directory config takes precedence."
  type        = string
  default     = null
}

variable "internet_acl_rules" {
  description = "List of internet ACL rules for the firewall"
  type = list(object({
    description      = string
    source_cidr      = string
    destination_cidr = string
    ip_protocol      = string
    source_port      = string
    destination_port = string
    policy           = string
    direction        = string
    priority         = number
  }))
  default = []
}

variable "internet_acl_rules_dir" {
  description = "Directory path containing internet ACL rule configuration files (JSON/YAML). Files in this directory are loaded and merged with internet_acl_rules parameter, directory config takes precedence."
  type        = string
  default     = null
}

variable "cloud_firewall_payment_type" {
  description = "The payment type of the cloud firewall instance"
  type        = string
  default     = "PayAsYouGo"
}

variable "control_policy_application_name" {
  description = "The application name for control policies"
  type        = string
  default     = "ANY"
}

variable "control_policy_source_type" {
  description = "The source type for control policies"
  type        = string
  default     = "net"
}

variable "control_policy_destination_type" {
  description = "The destination type for control policies"
  type        = string
  default     = "net"
}
variable "enable_internet_protection" {
  description = "Whether to enable internet boundary protection for SLB resources"
  type        = bool
  default     = false
}

variable "internet_protection_source" {
  description = "Source CIDR for internet boundary protection"
  type        = string
  default     = "0.0.0.0/0"
}

variable "internet_protection_destination" {
  description = "Destination CIDR for internet boundary protection"
  type        = string
  default     = "0.0.0.0/0"
}

variable "internet_protection_application" {
  description = "Application name for internet boundary protection"
  type        = string
  default     = "ANY"
}

variable "internet_protection_port" {
  description = "Port for internet boundary protection"
  type        = string
  default     = "80"
}
