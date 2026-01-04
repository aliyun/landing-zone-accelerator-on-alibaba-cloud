variable "instance_id" {
  description = "The ID of the WAFv3 instance."
  type        = string
}

variable "template_name" {
  description = "The name of the defense template."
  type        = string
}

variable "description" {
  description = "The description of the defense template."
  type        = string
  default     = ""
}

variable "defense_scene" {
  description = "The defense scene. Valid values: 'ip_blacklist', 'waf_group', 'cc', 'custom_acl', 'whitelist', 'waf_base_compliance', 'waf_base_sema'."
  type        = string
}

variable "template_type" {
  description = "The template type. Valid values: 'system', 'user_custom', 'user_default'."
  type        = string
}

variable "template_origin" {
  description = "The template origin. Valid values: 'system', 'custom'."
  type        = string
}

variable "status" {
  description = "The status of the defense template. Valid values: 0 (disabled), 1 (enabled)."
  type        = number
}
