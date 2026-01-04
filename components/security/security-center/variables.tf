# Security Center variables

variable "enable_security_center" {
  description = "Whether to enable Security Center"
  type        = bool
  default     = true
}

variable "security_center_instance_type" {
  description = "The type of the Security Center instance"
  type        = string
  default     = "level2"
}

variable "security_center_payment_type" {
  description = "The payment type for Security Center instance"
  type        = string
  default     = "PayAsYouGo"
}

variable "security_center_buy_number" {
  description = "The number of Security Center instances to buy"
  type        = number
  default     = 1
}

variable "modify_type" {
  description = "The modification type for Security Center instance"
  type        = string
  default     = null
}
