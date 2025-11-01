terraform {
  required_version = ">= 0.13"
}

locals {
  # 1) merge resource types
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

  # 2) built-in resource character limits
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

  # 3) lookups and abbreviations
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider, "")
  org_abbr      = lookup(var.organization_map, var.organization, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  # 4) sanitize shortdesc
  shortdesc_raw   = lower(var.shortdesc)
  shortdesc_step1 = regexreplace(local.shortdesc_raw, "[^a-z0-9-]", "")
  shortdesc_step2 = regexreplace(local.shortdesc_step1, "-+", "-")
  shortdesc       = substr(local.shortdesc_step2, 0, 20)

  # 5) pseudo-resources
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  # 6) merge overrides
  effective_overrides = merge(local.builtin_resource_overrides, var.resource_name_overrides)

  # 7) build generator config
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => (
        {
          count = count
          type  = type

          res_meta       = local.all_resource_types[type]
          res_abbr       = local.all_resource_types[type].abbr
          res_max_len    = try(local.all_resource_types[type].max_name_length, -1)
          res_idx_format = try(local.all_resource_types[type].index_format, "%d")

          override  = lookup(local.effective_overrides, type, null)
          max_len   = override != null ? override.max_length : res_max_len
          strip_hy  = override != null ? override.strip_hyphens : false

          name_parts = compact([
            local.division_abbr,
            res_abbr,
            local.lob_abbr,
            local.shortdesc,
            local.env_abbr,
            local.location_abbr
          ])

          name_raw        = join("-", name_parts)
          name_sanitized1 = lower(regexreplace(name_raw, "[^a-z0-9-]", ""))
          name_sanitized2 = regexreplace(name_sanitized1, "-+", "-")
          base_name       = strip_hy ? replace(name_sanitized2, "-", "") : name_sanitized2
          separator       = strip_hy ? "" : "-"

          result = {
            count           = count
            type            = type
            base_name       = base_name
            separator       = separator
            max_name_length = max_len
            index_format    = res_idx_format
          }
        }.result
      )
    }
  }

  # 8) generate names
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
          ) :
          (
            cfg.separator == "" ?
            "${cfg.base_name}${format(cfg.index_format, index)}" :
            "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
          )
        )
      ]
    }
  }

  # 9) flatten first names
  resource_type_keys = keys(local.all_resource_types)

  first_names = {
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

  # 10) tags
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

