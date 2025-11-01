variable "location_map" {
  type = map(any)

  # Azure region name on the left, abbreviation on the right
  default = {
    # Core US
    eastus         = "eus"
    eastus2        = "eus2"
    centralus      = "cus"
    northcentralus = "ncus"
    southcentralus = "scus"
    westus         = "wus"
    westus2        = "wus2"
    westus3        = "wus3"
    westcentralus  = "wcus"

    # Gov / DoD (keep if you need them)
    usgovvirginia  = "usgv"
    usgovarizona   = "usga"
    usgovtexas     = "usgt"

    # Canada
    canadacentral  = "cac"
    canadaeast     = "cae"

    # Europe
    westeurope     = "weu"
    northeurope    = "neu"
    uksouth        = "uks"
    ukwest         = "ukw"
    francecentral  = "frc"
    switzerlandnorth = "chn"

    # APAC / others (kept short)
    eastasia           = "eas"
    southeastasia      = "seas"
    australiaeast      = "aue"
    australiasoutheast = "ause"
    japaneast          = "jpe"
    japanwest          = "jpw"

    notapplicable = ""
    worldwide     = "ww"
  }
}

