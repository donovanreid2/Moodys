terraform {
  required_version = ">= 0.13"
}

locals {
  #########################################################
  # 1. All resource types (your big map + 1 pseudo)
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
  # 2. Built-in Azure name rules
  #########################################################
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

  #########################################################
  # 3. Abbreviations from variables
  #########################################################
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  #########################################################
  # 4. Short description (NO regex, NO split)
  #    lower -> replace spaces/underscores/dots/slashes -> cap to 20
  #########################################################
  shortdesc_raw   = lower(var.shortdesc)
  shortdesc_step1 = replace(shortdesc_raw, " ", "-")
  shortdesc_step2 = replace(shortdesc_step1, "_", "-")
  shortdesc_step3 = replace(shortdesc_step2, ".", "-")
  shortdesc_step4 = replace(shortdesc_step3, "/", "-")
  # simple collapse of double "--" once
  shortdesc_step5 = replace(shortdesc_step4, "--", "-")
  shortdesc       = substr(shortdesc_step5, 0, 20)

  #########################################################
  # 5. Pseudo-resources from generator (computer_name)
  #########################################################
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  #########################################################
  # 6. Effective overrides (built-in + user)
  #########################################################
  effective_overrides = merge(
    local.builtin_resource_overrides,
    var.resource_name_overrides
  )

  #########################################################
  # 7. Build generator config
  #    domain -> type -> cfg
  #########################################################
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

          # build name parts in your order
          name_parts = compact([
            local.division_abbr,
            res_abbr,
            local.lob_abbr,
            local.shortdesc,
            local.env_abbr,
            local.location_abbr
          ])

          # join + sanitize with simple replaces (no regex)
          name_raw     = lower(join("-", name_parts))
          name_step1   = replace(name_raw, " ", "-")
          name_step2   = replace(name_step1, "_", "-")
          name_step3   = replace(name_step2, ".", "-")
          name_step4   = replace(name_step3, "/", "-")
          name_clean   = replace(name_step4, "--", "-")

          base_name = strip_hy ? replace(name_clean, "-", "") : name_clean
          separator = strip_hy ? "" : "-"

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
  # 8. Generate actual names
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
  # 9. Build "first name per resource type"
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
  # 10. Tags
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
