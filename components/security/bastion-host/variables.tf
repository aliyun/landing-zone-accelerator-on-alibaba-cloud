# Required variables
variable "create_bastion_host" {
  description = "Controls if Bastion Host instance should be created"
  type        = bool
  default     = false
}

variable "bastion_host_description" {
  description = "Description of the Bastion Host instance"
  type        = string
  default     = ""
}

variable "bastion_host_license_code" {
  description = "License code for the Bastion Host instance"
  type        = string
  default     = "bhah_ent_50_asset"
}

variable "bastion_host_plan_code" {
  description = "Plan code for the Bastion Host instance"
  type        = string
  default     = "cloudbastion"
}

variable "bastion_host_storage" {
  description = "Storage capacity for the Bastion Host instance"
  type        = string
  default     = "5"
}

variable "bastion_host_bandwidth" {
  description = "Bandwidth for the Bastion Host instance"
  type        = string
  default     = "5"
}

variable "bastion_host_period" {
  description = "Period of the Bastion Host instance"
  type        = number
  default     = 1
}

# Optional variables for existing resources
variable "bastion_host_vswitch_id" {
  description = "VSwitch ID for the Bastion Host instance (required if create_vpc_resources is false)"
  type        = string
  default     = ""
}

variable "bastion_host_security_group_ids" {
  description = "Security Group IDs for the Bastion Host instance (required if create_vpc_resources is false)"
  type        = list(string)
  default     = []
}

# Variables for creating VPC resources
variable "create_vpc_resources" {
  description = "Controls if VPC resources should be created for the Bastion Host"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "vswitch_cidr" {
  description = "CIDR block for the VSwitch"
  type        = string
  default     = "192.168.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for the VSwitch"
  type        = string
  default     = ""
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "bastion-host-vpc"
}

variable "vpc_description" {
  description = "Description of the VPC"
  type        = string
  default     = "VPC for Bastion Host"
}

variable "vswitch_name" {
  description = "Name of the VSwitch"
  type        = string
  default     = "bastion-host-vswitch"
}

variable "vswitch_description" {
  description = "Description of the VSwitch"
  type        = string
  default     = "VSwitch for Bastion Host"
}

variable "security_group_name" {
  description = "Name of the security group"
  type        = string
  default     = "bastion-host-sg"
}

variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = "Security group for Bastion Host"
}

variable "bastion_host_tags" {
  description = "Tags for the Bastion Host instance"
  type        = map(string)
  default = {
    "Environment" = "landingzone"
    "Project"     = "terraform-alicloud-landing-zone-accelerator"
  }
}

# Security group rule variables
variable "ssh_rule_type" {
  description = "Type of the SSH security group rule"
  type        = string
  default     = "ingress"
}

variable "ssh_rule_ip_protocol" {
  description = "IP protocol for the SSH security group rule"
  type        = string
  default     = "tcp"
}

variable "ssh_rule_nic_type" {
  description = "Network interface type for the SSH security group rule"
  type        = string
  default     = "intranet"
}

variable "ssh_rule_policy" {
  description = "Policy for the SSH security group rule"
  type        = string
  default     = "accept"
}

variable "ssh_rule_port_range" {
  description = "Port range for the SSH security group rule"
  type        = string
  default     = "22/22"
}

variable "ssh_rule_priority" {
  description = "Priority for the SSH security group rule"
  type        = number
  default     = 1
}

variable "ssh_rule_cidr_ip" {
  description = "CIDR IP for the SSH security group rule"
  type        = string
  default     = "0.0.0.0/0"
}

variable "https_rule_type" {
  description = "Type of the HTTPS security group rule"
  type        = string
  default     = "ingress"
}

variable "https_rule_ip_protocol" {
  description = "IP protocol for the HTTPS security group rule"
  type        = string
  default     = "tcp"
}

variable "https_rule_nic_type" {
  description = "Network interface type for the HTTPS security group rule"
  type        = string
  default     = "intranet"
}

variable "https_rule_policy" {
  description = "Policy for the HTTPS security group rule"
  type        = string
  default     = "accept"
}

variable "https_rule_port_range" {
  description = "Port range for the HTTPS security group rule"
  type        = string
  default     = "443/443"
}

variable "https_rule_priority" {
  description = "Priority for the HTTPS security group rule"
  type        = number
  default     = 1
}

variable "https_rule_cidr_ip" {
  description = "CIDR IP for the HTTPS security group rule"
  type        = string
  default     = "0.0.0.0/0"
}
