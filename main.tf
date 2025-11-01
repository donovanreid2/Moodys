terraform {
  required_version = ">=0.13"
}

locals {
  # 1) built-in overrides for Azure resources with annoying rules
  # these are the defaults; the user can still override with var.resource_name_overrides
  builtin_resource_overrides = {
    # storage: 3–24 chars, lowercase, no dashes
    storage_account = {
      max_length    = 24
      strip_hyphens = true
    }

    # key vault: 3–24, alphanum and dash, must start with letter
    # we’ll keep dashes but cap at 24
    key_vault = {
      max_length    = 24
      strip_hyphens = false
    }

    # ACR: 5–50, alphanum only, lowercase
    container_registry = {
      max_length    = 50
      strip_hyphens = true
    }

    # you can add more here later (public_ip, vnet, etc.)
  }

  # bring in all resource types (your big map from resources.tf + pseudo)
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

  # abbreviations
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider, "")
  org_abbr      = lookup(var.organization_map, var.organization, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  # sanitize shortdesc
  shortdesc_raw   = lower(var.shortdesc)
  shortdesc_step1 = regexreplace(local.shortdesc_raw, "[^a-z0-9-]", "")
  shortdesc_step2 = regexreplace(local.shortdesc_step1, "-+", "-")
  shortdesc       = substr(local.shortdesc_step2, 0, 20)

  # pseudo-resources
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  # MERGE builtin overrides with user overrides (user wins)
  effective_overrides = merge(
    local.builtin_resource_overrides,
    var.resource_name_overrides
  )

  # generator config
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => {
        count  = count
        type   = type

        res_meta         = local.all_resource_types[type]
        res_abbr         = local.all_resource_types[type].abbr
        res_max_len_orig = try(local.all_resource_types[type].max_name_length, -1)
        res_index_format = try(local.all_resource_types[type].index_format, "%d")

        # pull override if we have it
        override  = lookup(local.effective_overrides, type, null)
        max_len   = override != null ? override.max_length : res_max_len_orig
        strip_hy  = override != null ? override.strip_hyphens : false

        # name parts per your spec:
        # [business_division]-[resource_type]-[product_area]-[shortdesc]-[environment]-[region]
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

        base_name = strip_hy ? replace(name_sanitized2, "-", "") : name_sanitized2
        separator = strip_hy ? "" : "-"

        {
          count           = count
          type            = type
          base_name       = base_name
          separator       = separator
          max_name_length = max_len
          index_format    = res_index_format
        }
      }
    }
  }

  # final generated names
  generated_names = {
    for domain, resources in local.generator_config :
    domain => {
      for type, cfg in resources :
      type => [
        for index in range(1, cfg.count + 1) : (
          local_name_with_idx = (
            cfg.separator == "" ?
            "${cfg.base_name}${format(cfg.index_format, index)}" :
            "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
          )

          cfg.max_name_length > 0 ?
          substr(local_name_with_idx, 0, cfg.max_name_length) :
          local_name_with_idx
        )
      ]
    }
  }

  # ----- helper: pick the *first* instance of a resource type across all domains -----
  resource_group_candidates = flatten([
    for domain, resources in local.generated_names :
    try([resources.resource_group[0]], [])
  ])
  storage_account_candidates = flatten([
    for domain, resources in local.generated_names :
    try([resources.storage_account[0]], [])
  ])
  key_vault_candidates = flatten([
    for domain, resources in local.generated_names :
    try([resources.key_vault[0]], [])
  ])
  container_registry_candidates = flatten([
    for domain, resources in local.generated_names :
    try([resources.container_registry[0]], [])
  ])

  first_resource_group_name     = try(local.resource_group_candidates[0], null)
  first_storage_account_name    = try(local.storage_account_candidates[0], null)
  first_key_vault_name          = try(local.key_vault_candidates[0], null)
  first_container_registry_name = try(local.container_registry_candidates[0], null)

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


