module "naming" {
  source = "./modules/naming"

  business_division = "moodys_rating_technology"
  product_area      = "ratings_azure_patterns"
  shortdesc         = "devex"
  environment       = "development"
  location          = "eastus2"
  cloud_provider    = "azure"
  organization      = "moodys"

  generator = {
    app = {
      resource_group  = 1
      app_service     = 1
      key_vault       = 1
    }
    network = {
      virtual_network = 1
      subnet          = 2
    }
  }
}
