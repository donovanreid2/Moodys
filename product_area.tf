variable "lob_map" {
  type = map(any)
  default = {
    insurance                         = "ins"
    banking                           = "bnk"
    technology_services_group         = "tsg"
    not_applicable                    = ""
    mis_tech                          = "Mist"
    cyber                             = "cyb"
    customer_operations_and_risk      = "cor"
    risk_management_solutions         = "rms"
    environment_Social_and_Governance = "esg"
    bureau_van_dijk                   = "bvd"
    know_your_customer                = "kyc"
    data_solutions_group              = "dsg"
    consumer_product_group            = "cpg"
    management                        = "mgt"
    connectivity                      = "conn"
    credit_rating                     = "crt"
    digital_insights                  = "dgi"
    predictive_analytics              = "pda"
    commercial_real_estate            = "cre"
    buyside                           = "buy"
    finance                           = "fin"
    chief_administrative_officer      = "cao"
    moodys_rating_technology          = "mrt"
    compliance_risk_resilience        = "crr"
    mrt_analytics                     = "ana"
    mrt_management                    = "mgt"
    mrt_ai_machinelearning            = "aml"
    mrt_data_regulatory_reporting     = "dma"
    mrt_research_channels             = "res"
    mrt_structure_fundamentals        = "sfg"
    mrt_model_utilities               = "mau"
    mrt_commercial_operations         = "com"
    mrt_tools_management              = "tam"
    mrt_ratings                       = "rad"
    mrt_shared_business_accounts      = "sba"
  }
}

variable "product_area" {
  type = string
  validation {
    condition = (
      var.product_area != null && contains([
        "insurance",
        "banking",
        "technology_services_group",
        "not_applicable",
        "mis_tech",
        "cyber",
        "customer_operations_and_risk",
        "risk_management_solutions",
        "environment_social_and_governance",
        "bureau_van_dijk",
        "know_your_customer",
        "data_solutions_group",
        "consumer_product_group",
        "management",
        "connectivity",
        "credit_rating",
        "digital_insights",
        "predictive_analytics",
        "commercial_real_estate",
        "buyside",
        "finance",
        "chief_administrative_officer",
        "moodys_rating_technology",
        "compliance_risk_resilience",
        "mrt_analytics",
        "mrt_management",
        "mrt_ai_machinelearning",
        "mrt_data_regulatory_reporting",
        "mrt_research_channels",
        "mrt_structure_fundamentals",
        "mrt_model_utilities",
        "mrt_commercial_operations",
        "mrt_tools_management",
        "mrt_ratings",
        "mrt_shared_business_accounts",
        ""],
        var.product_area
      )
    )
    error_message = "Invalid 'product_area'. Must be one of the following values: insurance, banking, customer_operations_and_risk, technology_services_group, not_applicable, mis_tech, cyber, risk, environment_social_and_governance, bureau_van_dijk, know_your_customer, data_solutions_group, or consumer_product_group"
  }
}
