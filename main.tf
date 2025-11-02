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
  shortdesc_step1 = replace(local.shortdesc_raw, " ", "-")
  shortdesc_step2 = replace(local.shortdesc_step1, "_", "-")
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
        base_name = (
          lookup(local.effective_overrides, type, null) != null ? 
          lookup(local.effective_overrides, type, null).strip_hyphens : 
          false
        ) ? replace(
          replace(replace(replace(replace(replace(
            lower(join("-", compact([
              local.division_abbr,
              local.all_resource_types[type].abbr,
              local.lob_abbr,
              local.shortdesc,
              local.env_abbr,
              local.location_abbr
            ]))), " ", "-"), "_", "-"), ".", "-"), "/", "-"), "--", "-"), "-", ""
        ) : replace(replace(replace(replace(replace(
          lower(join("-", compact([
            local.division_abbr,
            local.all_resource_types[type].abbr,
            local.lob_abbr,
            local.shortdesc,
            local.env_abbr,
            local.location_abbr
          ]))), " ", "-"), "_", "-"), ".", "-"), "/", "-"), "--", "-")
        separator = (
          lookup(local.effective_overrides, type, null) != null ? 
          lookup(local.effective_overrides, type, null).strip_hyphens : 
          false
        ) ? "" : "-"
        max_name_length = (
          lookup(local.effective_overrides, type, null) != null ? 
          lookup(local.effective_overrides, type, null).max_length : 
          try(local.all_resource_types[type].max_name_length, -1)
        )
        index_format = try(local.all_resource_types[type].index_format, "%d")
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
          cfg.max_name_length > 0 ?
          substr(
            cfg.separator == "" ?
            "${cfg.base_name}${format(cfg.index_format, index)}" :
            "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}",
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

  # resources_first for outputs compatibility
  resources_first = {
    resource_group = {
      name = local.first_resource_group_name
    }
    storage_account = {
      name = local.first_storage_account_name
    }
    key_vault = {
      name = local.first_key_vault_name
    }
    container_registry = {
      name = local.first_container_registry_name
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
