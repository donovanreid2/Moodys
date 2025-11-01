terraform {
  required_version = ">= 0.13"
}

locals {
  # --- Resource metadata map (from resources.tf + pseudo) ---
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

  # --- Built-in overrides for Azure name limits ---
  builtin_resource_overrides = {
    storage_account = {
      max_length    = 24
      strip_hyphens = true
    }
    key_vault = {
      max_length    = 24
      strip_hyphens = false
    }
    container_registry = {
      max_length    = 50
      strip_hyphens = true
    }
  }

  # --- Abbreviations from other vars ---
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider, "")
  org_abbr      = lookup(var.organization_map, var.organization, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  # --- Clean short description (no regexreplace for old TF) ---
  shortdesc_lower   = lower(var.shortdesc)
  shortdesc_clean_1 = replace(shortdesc_lower, "/[^a-z0-9-]/", "")
  shortdesc_clean_2 = replace(shortdesc_clean_1, "/-+/", "-")
  shortdesc         = substr(shortdesc_clean_2, 0, 20)

  # --- Pseudo resource expansion (VM computer_name etc.) ---
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  # --- Merge built-ins and user overrides ---
  effective_overrides = merge(local.builtin_resource_overrides, var.resource_name_overrides)

  # --- Build config for name generation ---
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => (
        {
          res_meta       = local.all_resource_types[type]
          res_abbr       = local.all_resource_types[type].abbr
          res_max_len    = try(local.all_resource_types[type].max_name_length, -1)
          res_idx_format = try(local.all_resource_types[type].index_format, "%d")

          override  = lookup(local.effective_overrides, type, null)
          max_len   = override != null ? override.max_length : res_max_len
          strip_hy  = override != null ? override.strip_hyphens : false

          # Build name pieces
          name_parts = compact([
            local.division_abbr,
            res_abbr,
            local.lob_abbr,
            local.shortdesc,
            local.env_abbr,
            local.location_abbr
          ])

          # sanitize
          name_raw     = join("-", name_parts)
          name_clean_1 = lower(replace(name_raw, "/[^a-z0-9-]/", ""))
          name_clean_2 = replace(name_clean_1, "/-+/", "-")
          base_name    = strip_hy ? replace(name_clean_2, "-", "") : name_clean_2
          separator    = strip_hy ? "" : "-"

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

  # --- Generate final names ---
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

  # --- First name per resource type ---
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

  # --- Tag output (unchanged from original) ---
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
