variable "cloud_provider_map" {
  type = map(any)
  default = {
    azure                 = "azr"
    azr                   = "azr"
    amazon                = "aws"
    amazon_web_services   = "aws"
    aws                   = "aws"
    google_cloud          = "gcp"
    google_cloud_platform = "gcp"
    google                = "gcp"
    gcp                   = "gcp"
  }
}

variable "cloud_provider" {
  type    = string
  default = "azure"
  validation {
    condition = (
      var.cloud_provider != null && contains([
        "amazon_web_services",
        "azure",
        "google_cloud_platform",
        "azr",
        "amazon",
        "google_cloud",
        "google",
        "gcp"],
        var.cloud_provider
      )
    )
    error_message = "Invalid 'provider'. It must be azure, azr, amazon_web_services, aws, google_cloud_platform, or gcp."
  }
}
