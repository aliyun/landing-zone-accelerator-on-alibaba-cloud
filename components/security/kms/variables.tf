# KMS variables

variable "create_kms_instance" {
  description = "Whether to create a KMS instance"
  type        = bool
  default     = true
}

variable "kms_instance_name" {
  description = "The name of the KMS instance"
  type        = string
  default     = "landingzone-central-kms"
}

variable "kms_instance_spec" {
  description = "The specification of the KMS instance"
  type        = string
  default     = "1000"
}

variable "kms_key_amount" {
  description = "The number of keys that can be protected in the KMS instance"
  type        = number
  default     = 1000
}

variable "product_version" {
  description = "The product version of the KMS instance"
  type        = string
  default     = "3"
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "kms-vpc"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/8"
}

variable "vswitch_cidr_block" {
  description = "The CIDR block for the VSwitch"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vswitch_name" {
  description = "The name of the VSwitch"
  type        = string
  default     = "kms-vswitch"
}

variable "zone_ids" {
  description = "List of zone IDs for high availability (2 zones required). The first zone_id will be used for the VSwitch."
  type        = list(string)
}

variable "vpc_tags" {
  description = "A map of tags to assign to the VPC."
  type        = map(string)
  default     = {}
}

variable "vswitch_tags" {
  description = "A map of tags to assign to the VSwitch."
  type        = map(string)
  default     = {}
}

variable "kms_instance_tags" {
  description = "A map of tags to assign to the KMS instance."
  type        = map(string)
  default     = {}
}
