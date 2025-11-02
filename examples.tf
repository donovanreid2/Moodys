 Error: Invalid reference
│
│   on modules\naming\main.tf line 68, in locals:
│   68:   shortdesc_chars     = split("", shortdesc_lower)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 69, in locals:
│   69:   shortdesc_filtered  = [for c in shortdesc_chars : c if contains(local.allowed_chars, c)]
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 70, in locals:
│   70:   shortdesc_joined    = join("", shortdesc_filtered)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
╷
│ Error: Invalid reference
│
│   on modules\naming\main.tf line 72, in locals:
│   72:   shortdesc           = substr(shortdesc_joined, 0, 20)
│
│ A reference to a resource type must be followed by at least one attribute access, specifying the resource name.  
╵
