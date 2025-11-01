terraform {
  required_version = ">= 0.13"
}

locals {
  #########################################################
  # 1. Allowed characters (since we can't use regexreplace)
  #########################################################
  allowed_chars = [
    "a","b","c","d","e","f","g","h","i","j","k","l","m",
    "n","o","p","q","r","s","t","u","v","w","x","y","z",
    "0","1","2","3","4","5","6","7","8","9","-"
  ]

  #########################################################
  # 2. All resource types (your big map is in resources.tf)
  #    + one pseudo (computer_name)
  #########################################################
  all_resource_types = merge(
    local.resource_types,
    {
      computer_name = {
        name            = "computer_name"
        alphanum        = true
        global          = true
        abbr            = ""
        max_name_length = 13
        index_format    = "%02d"
      }
    }
  )

  #########################################################
  # 3. Built-in Azure name rules
  #########################################################
  builtin_resource_overrides = {
    # 3–24, lowercase, no dashes
    storage_account = {
      max_length    = 24
      strip_hyphens = true
    }

    # 3–24, can have dashes
    key_vault = {
      max_length    = 24
      strip_hyphens = false
    }

    # 5–50, lowercase, no dashes
    container_registry = {
      max_length    = 50
      strip_hyphens = true
    }
  }

  #########################################################
  # 4. Lookups / abbreviations
  #########################################################
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  #########################################################
  # 5. Sanitize shortdesc WITHOUT regex
  #########################################################
  shortdesc_lower     = lower(var.shortdesc)
  shortdesc_chars     = split("", shortdesc_lower)
  shortdesc_filtered  = [for c in shortdesc_chars : c if contains(local.allowed_chars, c)]
  shortdesc_joined    = join("", shortdesc_filtered)
  # cap it
  shortdesc           = substr(shortdesc_joined, 0, 20)

  #########################################################
  # 6. Expand pseudo resources from generator
  #########################################################
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      # right now we only have computer_name as pseudo
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  #########################################################
  # 7. Effective per-resource overrides (built-in + user)
  #########################################################
  effective_overrides = merge(
    local.builtin_resource_overrides,
    var.resource_name_overrides
  )

  #########################################################
  # 8. Build generator config
  #    domain -> type -> cfg
  #########################################################
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => (
        {
          # base resource metadata
          res_meta       = local.all_resource_types[type]
          res_abbr       = local.all_resource_types[type].abbr
          res_max_len    = try(local.all_resource_types[type].max_name_length, -1)
          res_idx_format = try(local.all_resource_types[type].index_format, "%d")

          # apply override if present
          override  = lookup(local.effective_overrides, type, null)
          max_len   = override != null ? override.max_length : res_max_len
          strip_hy  = override != null ? override.strip_hyphens : false

          # build base name in your order:
          # [business_division]-[resource type]-[product area]-[shortdesc]-[environment]-[region]
          name_parts = compact([
            local.division_abbr,   # mrt
            res_abbr,              # rg / kv / app / vnet ...
            local.lob_abbr,        # rap
            local.shortdesc,       # devex
            local.env_abbr,        # dev
            local.location_abbr    # eus2
          ])

          # join to string
          name_raw     = join("-", name_parts)
          name_raw_low = lower(name_raw)

          # sanitize WITHOUT regex: keep only allowed_chars
          name_chars     = split("", name_raw_low)
          name_filtered  = [for c in name_chars : c if contains(local.allowed_chars, c)]
          name_joined    = join("", name_filtered)

          # storage/account-style names (strip dashes)
          base_name = strip_hy ? replace(name_joined, "-", "") : name_joined
          separator = strip_hy ? "" : "-"

          # final cfg for this resource type
          out = {
            count           = count
            type            = type
            base_name       = base_name
            separator       = separator
            max_name_length = max_len
            index_format    = res_idx_format
          }
        }.out
      )
    }
  }

  #########################################################
  # 9. Generate final names
  #########################################################
  generated_names = {
    for domain, resources in local.generator_config :
    domain => {
      for type, cfg in resources :
      type => [
        for index in range(1, cfg.count + 1) : (
          cfg.max_name_length > 0 ?
          substr(
            (
              cfg.separator == "" ?
              "${cfg.base_name}${format(cfg.index_format, index)}" :
              "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
            ),
            0,
            cfg.max_name_length
          )
          :
          (
            cfg.separator == "" ?
            "${cfg.base_name}${format(cfg.index_format, index)}" :
            "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
          )
        )
      ]
    }
  }

  #########################################################
  # 10. Build: first name per resource type
  #     -> so you can do: module.naming.resources.app_service.name
  #########################################################
  resource_type_keys = keys(local.all_resource_types)

  resources_first = {
    for rt in local.resource_type_keys :
    rt => {
      name = try(
        element(
          flatten([
            for _, resources in local.generated_names :
            try([resources[rt][0]], [])
          ]),
          0
        ),
        null
      )
    }
  }

  #########################################################
  # 11. Tags (your original set)
  #########################################################
  tags = {
    provisioned_by       = var.provisioned_by
    revenue              = var.revenue
    app_id               = var.app_id
    app_name             = var.app_name
    app_tier             = var.app_tier
    resource_group_owner = var.resource_group_owner
    support_team         = var.support_team
  }
}

