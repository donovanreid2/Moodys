
variable "business_division_map" {
  type = map(any)
  default = {
    moodys_analytics         = "ma"
    moodys_investor_services = "mis"
    moodys_shared_services   = "mss"
    cloud_shared_services    = "css"
    moodys_rating_technology = "mrt"
    css                      = "css"
    ma                       = "ma"
    mis                      = "mis"
    mss                      = "mss"
    mrt                      = "mrt"
  }
}

variable "business_division" {
  type = string
  validation {
    condition = (
      var.business_division != null && contains([
        "moodys_analytics",
        "moodys_investor_services",
        "moodys_shared_services",
        "cloud_shared_services",
        "moodys_rating_technology",
        "css",
        "ma",
        "mis",
        "mss",
        "mrt",
        ""],
        var.business_division
      )
    )
    error_message = "Invalid 'business_division'. It must be moodys_analytics, moodys_investor_services, moodys_shared_services, cloud_shared_services."
  }
}
