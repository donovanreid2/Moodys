
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
