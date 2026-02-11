variable "zone_name" {
  description = "Application Private Zone name"
  type        = string
}

variable "zone_remark" {
  description = "Application Private Zone remark"
  type        = string
  default     = null
  validation {
    condition     = var.zone_remark == null || (try(length(var.zone_remark), 0) <= 50 && can(regex("^[\u4e00-\u9fa5A-Za-z0-9._-]*$", var.zone_remark)))
    error_message = "zone_remark can be null, or if not null, must be <= 50 chars and only contain Chinese, English, numbers, '.', '_' or '-'"
  }
}

variable "proxy_pattern" {
  description = "Application Private Zone recursive DNS proxy pattern. Valid values: ZONE (disabled), RECORD (enabled). Default to 'ZONE'."
  type        = string
  default     = "ZONE"
  validation {
    condition     = contains(["ZONE", "RECORD"], var.proxy_pattern)
    error_message = "proxy_pattern must be either 'ZONE' or 'RECORD'."
  }
}

variable "lang" {
  description = "Application Private Zone language. Valid values: 'zh', 'en'. Default to 'en'."
  type        = string
  default     = "en"
  validation {
    condition     = contains(["zh", "en"], var.lang)
    error_message = "lang must be either 'zh' or 'en'."
  }
}

variable "resource_group_id" {
  description = "The resource group ID which the Private Zone belongs to. Default is empty."
  type        = string
  default     = ""
}

variable "tags" {
  description = "The tags of the Private Zone."
  type        = map(string)
  default     = {}
}

variable "vpc_bindings" {
  description = "Application Private Zone effective scope (VPC binding list), each item contains vpc_id and optional region_id (if not set, the current region will be used)."
  type = list(object({
    vpc_id    = string
    region_id = optional(string)
  }))
  default = []
}

variable "record_entries" {
  description = "Application Private Zone DNS record settings, list, each item contains name, type, value, ttl, lang, priority (only for MX type), remark, status."
  type = list(object({
    name     = string
    type     = string
    value    = string
    ttl      = optional(number, 60)
    lang     = optional(string, "en")
    priority = optional(number, 1)
    remark   = optional(string, "")
    status   = optional(string, "ENABLE")
  }))
  default = []
  validation {
    condition = alltrue([
      for rec in var.record_entries : (
        (rec.lang == null || try(contains(["zh", "en"], rec.lang), false)) &&
        contains(["A", "CNAME", "TXT", "MX", "PTR", "SRV"], rec.type) &&
        (rec.priority == null || try(rec.priority >= 1 && rec.priority <= 99, false)) &&
        (rec.status == null || try(contains(["ENABLE", "DISABLE"], rec.status), false)) &&
        (rec.remark == null || (try(length(rec.remark), 0) <= 50 && can(regex("^[\u4e00-\u9fa5A-Za-z0-9._-]*$", rec.remark))))
      )
    ])
    error_message = "Each record must meet: lang is 'zh' or 'en'; type is one of A, CNAME, TXT, MX, PTR, SRV; priority (only for MX) is 1-99; status is ENABLE or DISABLE; remark can be null, or if not null, must be <= 50 chars and only contain Chinese, English, numbers, '.', '_' or '-' ."
  }
}
