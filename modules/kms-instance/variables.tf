variable "instance_name" {
  description = "The name of the KMS instance"
  type        = string
}

variable "product_version" {
  description = "The product version of the KMS instance"
  type        = string
  default     = "3"
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "zone_ids" {
  description = "List of zone IDs for high availability (2 zones required)"
  type        = list(string)
}

variable "vswitch_ids" {
  description = "List of VSwitch IDs (1 vswitch required)"
  type        = list(string)
}

variable "key_num" {
  description = "The number of keys that can be protected in the KMS instance"
  type        = number
  default     = 1000
}

variable "spec" {
  description = "The specification of the KMS instance"
  type        = string
  default     = "1000"
}

variable "tags" {
  description = "A map of tags to assign to the KMS instance."
  type        = map(string)
  default     = {}
}

