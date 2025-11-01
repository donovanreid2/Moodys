# variable "owner" {
#   default = "__owner__"
# }

# variable "backup" {
#   default = "__backup__"
#   type = string
# }

# variable "application" {
#   default = "__application__"
#   type = string

# }

# variable "scheduler" {
#   default = "__scheduler__"
#   type = string

# }

# variable "tech_lob" {
#   default = "__tech_lob__"
#   type = string

# }

#########These are for RG###########
variable "provisioned_by" { #done
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



#general
variable "location" {
}

variable "generator" {
  type = map(map(number))
  default = {
    "app" = {
      "rg" = 1
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
