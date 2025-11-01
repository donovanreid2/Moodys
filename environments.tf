variable "environment_map" {
  type = map(any)
  default = {
    production              = "prd"
    prd                     = "prd"
    global                  = "gbl"
    gbl                     = "gbl"
    non_production          = "npd"
    npd                     = "npd"
    user_acceptance_testing = "uat"
    uat                     = "uat"
    quality_assurance       = "qaa"
    qaa                     = "qaa"
    development             = "dev"
    dev                     = "dev"
    sandbox                 = "sbx"
    sbx                     = "sbx"
    not_applicable          = ""
  }
}
variable "environment" {
  type = string
  validation {
    condition = (
      var.environment != null
      && contains([
        "prd",
        "gbl",
        "npd",
        "uat",
        "qaa",
        "dev",
        "sbx",
        "",
        "production",
        "global",
        "non_production",
        "user_acceptance_testing",
        "quality_assurance",
        "development",
        "sandbox",
        "not_applicable"],
        var.environment
      )
    )
    error_message = "Invalid 'environment'. It must not be null and be one of: prd, gbl, npd, uat, qaa, dev, sbx, production, global, non_production, user_acceptance_testing, quality_assurance, development, sandbox, or not_applicable"
  }
}
