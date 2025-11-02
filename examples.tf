module "naming" {
  source = "./modules/naming"

  location          = "eastus2"
  environment       = "dev"
  organization      = "moodys"
  business_division = "mrt"
  product_area      = "ratings_azure_patterns"
  shortdesc         = "devex"
  cloud_provider    = "azure"

  # ask the generator to make both RG and ACR
  generator = {
    app = {
      resource_group     = 1
      container_registry = 1
    }
  }
}

