 Error: Invalid reference
│
│   on locals.tf line 128, in locals:
│  128:         name = is_alphanumeric ? (
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 129, in locals:
│  129:           "${local.naming_components.business}${resource_abbr}${local.naming_components.business_unit}${local.naming_components.short_description}${local.naming_components.environment}${region_code}${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 129, in locals:
│  129:           "${local.naming_components.business}${resource_abbr}${local.naming_components.business_unit}${local.naming_components.short_description}${local.naming_components.environment}${region_code}${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 131, in locals:
│  131:           "${local.naming_components.business}-${resource_abbr}-${local.naming_components.business_unit}-${local.naming_components.short_description}-${local.naming_components.environment}-${region_code}-${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 131, in locals:
│  131:           "${local.naming_components.business}-${resource_abbr}-${local.naming_components.business_unit}-${local.naming_components.short_description}-${local.naming_components.environment}-${region_code}-${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 134, in locals:
│  134:         final_name = lower(name)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Call to unknown function
│
│   on modules\naming\main.tf line 47, in locals:
│   47:   shortdesc_step1 = regexreplace(local.shortdesc_raw, "[^a-z0-9-]", "")
│     ├────────────────
│     │ local.shortdesc_raw is a string
│
│ There is no function named "regexreplace".
╵
PS C:\Users\reidd3\Documents\moodysterraform\level3\acr> terraform plan
╷
│ Error: Invalid reference
│
│   on locals.tf line 128, in locals:
│  128:         name = is_alphanumeric ? (
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 129, in locals:
│  129:           "${local.naming_components.business}${resource_abbr}${local.naming_components.business_unit}${local.naming_components.short_description}${local.naming_components.environment}${region_code}${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 129, in locals:
│  129:           "${local.naming_components.business}${resource_abbr}${local.naming_components.business_unit}${local.naming_components.short_description}${local.naming_components.environment}${region_code}${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 131, in locals:
│  131:           "${local.naming_components.business}-${resource_abbr}-${local.naming_components.business_unit}-${local.naming_components.short_description}-${local.naming_components.environment}-${region_code}-${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 131, in locals:
│  131:           "${local.naming_components.business}-${resource_abbr}-${local.naming_components.business_unit}-${local.naming_components.short_description}-${local.naming_components.environment}-${region_code}-${local.naming_components.sequence}"
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on locals.tf line 134, in locals:
│  134:         final_name = lower(name)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 47, in locals:
│   47:   shortdesc_clean_1 = replace(shortdesc_lower, "/[^a-z0-9-]/", "")
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 48, in locals:
│   48:   shortdesc_clean_2 = replace(shortdesc_clean_1, "/-+/", "-")
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 49, in locals:
│   49:   shortdesc         = substr(shortdesc_clean_2, 0, 20)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
