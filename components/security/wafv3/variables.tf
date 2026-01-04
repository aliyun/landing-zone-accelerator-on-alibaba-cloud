variable "templates" {
  description = "List of defense templates to be created."
  type = list(object({
    template_name   = string
    description     = optional(string, "")
    defense_scene   = string
    template_type   = optional(string, "user_custom")
    template_origin = optional(string, "custom")
    status          = optional(number, 1)
    resources       = optional(set(string))
  }))
  default = []
}

variable "rules" {
  description = "List of rules to be configured."
  type = list(object({
    rule_name      = string
    defense_scene  = string
    template_id    = string
    rule_action    = string
    remote_addr    = list(string)
    status         = optional(number, 1)
    defense_origin = optional(string, "custom")
  }))
  default = []
}

variable "templates_dir" {
  description = "Directory path containing template configuration files (JSON/YAML). Files in this directory are loaded and merged with templates parameter, directory config takes precedence."
  type        = string
  default     = null
}

variable "rules_dir" {
  description = "Directory path containing rule configuration files (JSON/YAML). Files in this directory are loaded and merged with rules parameter, directory config takes precedence."
  type        = string
  default     = null
}
