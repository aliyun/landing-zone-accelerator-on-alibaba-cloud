variable "preset_tags" {
  type = list(object({
    key    = string
    values = list(string)
  }))
  default = []

  validation {
    condition     = alltrue([for tag in var.preset_tags : length(tag.key) >= 1 && length(tag.key) <= 128 && !startswith(tag.key, "aliyun") && !startswith(tag.key, "acs:") && !contains([tag.key], "http://") && !contains([tag.key], "https://")])
    error_message = "Each key in preset_tags must be between 1 and 128 characters, not start with 'aliyun' or 'acs:', and not contain 'http://' or 'https://'."
  }

  validation {
    condition     = alltrue([for tag in var.preset_tags : alltrue([for value in tag.values : length(value) <= 128 && !contains([value], "http://") && !contains([value], "https://")])])
    error_message = "Each value in preset_tags must be no more than 128 characters and not contain 'http://' or 'https://'."
  }

  validation {
    condition     = alltrue([for tag in var.preset_tags : length(tag.values) >= 1 && length(tag.values) <= 10])
    error_message = "The length of the values array in each preset_tags item must be between 1 and 10."
  }
}
