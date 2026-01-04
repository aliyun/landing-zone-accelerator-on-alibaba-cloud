# The name of the SLS project
variable "project_name" {
  description = "The name of the SLS project"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-63 chars, start/end with lowercase letter or digit, and contain only lowercase letters, digits and hyphens (-)."
  }
}

# Whether to create a new SLS project. If false, use an existing project.
variable "create_project" {
  description = "Whether to create a new SLS project. If false, use an existing project."
  type        = bool
  default     = true
}

# Whether to append a random suffix to project_name to ensure global uniqueness (only when create_project = true)
variable "append_random_suffix" {
  description = "Whether to append a random suffix to the SLS project_name (project only, not logstore) to ensure global uniqueness (only when create_project = true)"
  type        = bool
  default     = false
}

# Length of the random suffix (letters and numbers only)
variable "random_suffix_length" {
  description = "Length of the random suffix for the SLS project_name (project only)"
  type        = number
  default     = 6

  validation {
    condition     = var.random_suffix_length >= 3 && var.random_suffix_length <= 16
    error_message = "random_suffix_length must be between 3 and 16."
  }
}

# Separator between project_name and random suffix when appending
variable "random_suffix_separator" {
  description = "Separator between the SLS project_name and random suffix (project only)"
  type        = string
  default     = "-"

  validation {
    condition     = var.random_suffix_separator == "-" || var.random_suffix_separator == "_" || var.random_suffix_separator == ""
    error_message = "random_suffix_separator must be '-', '_' or empty."
  }
}

# The description of the SLS project
variable "description" {
  description = "The description of the SLS project"
  type        = string
  default     = ""
}


# A mapping of tags to assign to the project
variable "tags" {
  description = "A mapping of tags to assign to the project"
  type        = map(string)
  default     = null
}
