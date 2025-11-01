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
