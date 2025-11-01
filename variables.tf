variable "provisioned_by" {
  default = "__provisioned_by__"
  type    = string
}

variable "revenue" {
  default = "__revenue__"
  type    = string
}

variable "app_id" {
  default = "__app_id__"
  type    = string
}

variable "app_name" {
  default = "__app_name__"
  type    = string
}

variable "app_tier" {
  default = "__app_tier__"
  type    = string
}

variable "support_team" {
  default = "__support_team__"
  type    = string
}

variable "resource_group_owner" {
  default = "__tech_lob__"
  type    = string
}

# NEW: short description to put in the name
variable "shortdesc" {
  type    = string
  default = ""
  description = "Short description of what the resource/group is for. Will be sanitized to [a-z0-9-] and truncated."
  validation {
    condition     = length(var.shortdesc) <= 40
    error_message = "shortdesc must be 40 characters or less."
  }
}

# general
variable "location" {
  type = string
}

variable "generator" {
  type = map(map(number))
  default = {
    app = {
      resource_group = 1
    }
  }
  validation {
    condition = (
      var.generator != null
      && length(var.generator) > 0
      && !contains(
        [for domain, resources in var.generator : (
          domain != null
          && !contains(
            [for resource_type, resource_count in resources : (
              resource_count != null && resource_count >= 0
          )], false)
      )], false)
    )
    error_message = "Invalid input for 'generator' variable."
  }
}

# NEW: per-resource overrides to deal with Azure name length / permitted chars
# Example:
# resource_name_overrides = {
#   storage_account = { max_length = 24, strip_hyphens = true }
# }
variable "resource_name_overrides" {
  type = map(object({
    max_length   = number
    strip_hyphens = bool
  }))
  default = {}
  description = "Optional per-resource overrides to handle Azure character or length limits."
}
