terraform {
  required_version = ">=0.13"
}

locals {
  # bring in all resource types
  all_resource_types = merge(
    local.resource_types,
    {
      # keep the pseudo resource you had
      computer_name = {
        name            = "computer_name"
        alphanum        = true
        global          = true
        abbr            = ""     # no extra
        max_name_length = 13
        index_format    = "%02d"
      }
    }
  )

  # abbreviations (already validated in their own files)
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider, "")
  org_abbr      = lookup(var.organization_map, var.organization, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  # sanitize shortdesc -> lower, strip non [a-z0-9-], squeeze dashes, trim to 20
  shortdesc_raw = lower(var.shortdesc)
  shortdesc_step1 = regexreplace(local.shortdesc_raw, "[^a-z0-9-]", "")
  shortdesc_step2 = regexreplace(local.shortdesc_step1, "-+", "-")
  shortdesc       = substr(local.shortdesc_step2, 0, 20)

  # pseudo-resources: if you define VM we also generate computer_name, etc.
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      # if a pseudo exists, use its key, else use original
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  # final generator config
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => {
        count  = count
        type   = type

        # resource metadata
        res_meta         = local.all_resource_types[type]
        res_abbr         = local.all_resource_types[type].abbr
        res_max_len_orig = try(local.all_resource_types[type].max_name_length, -1)
        res_index_format = try(local.all_resource_types[type].index_format, "%d")
        res_global       = try(local.all_resource_types[type].global, false)

        # per-resource overrides from variable
        override = lookup(var.resource_name_overrides, type, null)
        max_len  = override != null ? override.max_length : res_max_len_orig
        strip_hy = override != null ? override.strip_hyphens : false

        # name parts per your scheme:
        # [business_division]-[resource type]-[product area]-[shortdesc]-[environment]-[region]
        name_parts = compact([
          local.division_abbr,
          res_abbr,
          local.lob_abbr,
          local.shortdesc,
          local.env_abbr,
          local.location_abbr
        ])

        # build raw name
        name_raw = join("-", name_parts)

        # sanitize for Azure (lowercase, strip bad chars, squeeze dashes)
        name_sanitized_1 = lower(regexreplace(name_raw, "[^a-z0-9-]", ""))
        name_sanitized_2 = regexreplace(name_sanitized_1, "-+", "-")

        # optionally strip hyphens for strict resources like storage
        name_final_base = strip_hy ? replace(name_sanitized_2, "-", "") : name_sanitized_2

        separator = strip_hy ? "" : "-"

        # emit all info needed for final name
        {
          count          = count
          type           = type
          base_name      = name_final_base
          separator      = separator
          max_name_length = max_len
          index_format   = res_index_format
        }
      }
    }
  }

  # FINAL NAMES
  generated_names = {
    for domain, resources in local.generator_config :
    domain => {
      for type, cfg in resources :
      type => [
        for index in range(1, cfg.count + 1) : (
          # build index piece
          # if max len set, we need to consider the index too
          # name + sep + idx
          # first, name with index
          # e.g. mrt-rg-rap-devex-dev-eus2-1
          # or, if stripped: mrtrgrapdevexdeveus21
          (
            # full-with-index
            local_name_with_idx = (
              cfg.separator == "" ?
              "${cfg.base_name}${format(cfg.index_format, index)}" :
              "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
            )

            # now apply max len if we have it
            cfg.max_name_length > 0 ?
            substr(local_name_with_idx, 0, cfg.max_name_length) :
            local_name_with_idx
          )
        )
      ]
    }
  }

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

