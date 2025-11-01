variable "organization_map" {
  type = map(any)
  default = {
    moodys                = "mco"
    mco                   = "mco"
    moodys_policy_staging = "mps"
    mps                   = "mps"
  }
}
variable "organization" {
  type    = string
  default = "moodys"
  validation {
    condition = (
      var.organization != null && contains([
        "moodys",
        "mco",
        "moodys_policy_staging",
        "mps"],
        var.organization
      )
    )
    error_message = "Invalid 'organization'. It must be moodys, mco, moodys_policy_staging, mps"
  }
}
