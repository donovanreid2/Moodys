terraform {
  required_version = ">= 0.13"
}

locals {
  # 1) all resource types = the big map from resources.tf + our pseudo
  all_resource_types = merge(
    local.resource_types,
    {
      # keep your pseudo VM computer name if you want it
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

  # 2) built-in length/char rules for picky Azure resources
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

  # 3) lookup abbreviations (from other *.tf you already have)
  location_abbr = lookup(var.location_map, var.location, "")
  env_abbr      = lookup(var.environment_map, var.environment, "")
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider, "")
  org_abbr      = lookup(var.organization_map, var.organization, "")
  lob_abbr      = lookup(var.lob_map, var.product_area, "")
  division_abbr = lookup(var.business_division_map, var.business_division, "")

  # 4) sanitize shortdesc
  # we can't use regexreplace in your version, so we use replace() with regex
  shortdesc_lower   = lower(var.shortdesc)
  shortdesc_clean_1 = replace(shortdesc_lower, "/[^a-z0-9-]/", "")
  shortdesc_clean_2 = replace(shortdesc_clean_1, "/-+/", "-")
  shortdesc         = substr(shortdesc_clean_2, 0, 20)

  # 5) expand pseudo-resources from generator
  pseudo_resources_generator = {
    for domain, resources in var.generator :
    domain => {
      for type, count in resources :
      # if we ever add more pseudos, we can extend this map
      try(keys({ computer_name = {} }[type])[0], type) => count
    }
  }

  # 6) user overrides win over built-ins
  effective_overrides = merge(
    local.builtin_resource_overrides,
    var.resource_name_overrides
  )

  # 7) build a config we can iterate over to make names
  #    structure: domain -> type -> {count, base_name, ...}
  generator_config = {
    for domain, resources in var.generator :
    domain => {
      for type, count in merge(resources, local.pseudo_resources_generator[domain]) :
      type => (
        # figure out resource basics
        # (we wrap it in (...) so we can compute and return one object)
        {
          # base data
          res_meta       = local.all_resource_types[type]
          res_abbr       = local.all_resource_types[type].abbr
          res_max_len    = try(local.all_resource_types[type].max_name_length, -1)
          res_idx_format = try(local.all_resource_types[type].index_format, "%d")

          # override if present
          override  = lookup(local.effective_overrides, type, null)
          max_len   = override != null ? override.max_length : res_max_len
          strip_hy  = override != null ? override.strip_hyphens : false

          # build the name parts in your order:
          # [business_division]-[resource type]-[product area]-[shortdesc]-[environment]-[region]
          name_parts = compact([
            local.division_abbr,
            res_abbr,
            local.lob_abbr,
            local.shortdesc,
            local.env_abbr,
            local.location_abbr
          ])

          # join, then sanitize
          name_raw         = join("-", name_parts)
          name_clean_1     = lower(replace(name_raw, "/[^a-z0-9-]/", ""))
          name_clean_2     = replace(name_clean_1, "/-+/", "-")
          base_name        = strip_hy ? replace(name_clean_2, "-", "") : name_clean_2
          separator        = strip_hy ? "" : "-"

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

  # 8) actually generate the names
  generated_names = {
    for domain, resources in local.generator_config :
    domain => {
      for type, cfg in resources :
      type => [
        for index in range(1, cfg.count + 1) : (
          # build name with index
          # example: mrt-kv-rap-devex-dev-eus2-1
          # or for storage (strip_hyphens = true): mrtsarapdevexdeveus21
          (
            cfg.separator == "" ?
            "${cfg.base_name}${format(cfg.index_format, index)}" :
            "${cfg.base_name}${cfg.separator}${format(cfg.index_format, index)}"
          )
          # apply max length if we have one
          # (this is what enforces key vault 24 chars)
          ...
        )
      ]
    }
  }

  # NOTE: Terraform doesn't allow "..." so we finish that expression below
}
