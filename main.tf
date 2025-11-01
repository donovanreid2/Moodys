terraform {
  required_version = ">=0.13"
}

locals {

  # Pseudo-resource types which names we need to derive from resource types
  pseudo_resource_types = {
    virtual_machine = {
      computer_name = {
        name            = "computer_name"
        alphanum        = true
        global          = true
        abbr            = "" # Empty abbreviation
        max_name_length = 13
        index_format    = "%02d"
      }
    }
  }

  # Resource configuration: Include resource types and "pseudo resource types"
  all_resource_types = merge(
    local.resource_types,
    local.pseudo_resource_types.virtual_machine # a.k.a. { computer_name = { name = ..., } }
  )

  location_abbr = lookup(var.location_map, var.location)
  env_abbr      = lookup(var.environment_map, var.environment)
  provider_abbr = lookup(var.cloud_provider_map, var.cloud_provider)
  org_abbr      = lookup(var.organization_map, var.organization)
  lob_abbr      = lookup(var.lob_map, var.product_area)
  division_abbr = lookup(var.business_division_map, var.business_division)
  prefix_parts  = ["${local.division_abbr}${local.lob_abbr}", "${local.provider_abbr}${local.env_abbr}${local.location_abbr}"]
  prefix        = join("-", local.prefix_parts)

  # Create equivalent "generator" map for "pseudo resource types"
  # If a resource does not have a related "pseudo resource", just use the resource itself (makes merging maps easier)
  pseudo_resources_generator = { for
    domain, resources in var.generator : domain => { for
      type, count in resources : try(keys(local.pseudo_resource_types[type])[0], type) => count
    }
  }

  # Generator configuration for resources and pseudo resources
  generator_config = { for
    domain, resources in var.generator : domain => { for
      type, count in merge(resources, local.pseudo_resources_generator[domain]) : type => {
        count     = count
        type      = type
        separator = tobool(local.all_resource_types[type].alphanum) ? "" : "-"
        name_parts = tobool(local.all_resource_types[type].global) ? compact(flatten([
          local.org_abbr,
          local.prefix_parts,
          domain,
          local.all_resource_types[type].abbr
          ])) : compact(flatten([
          local.prefix_parts,
          domain,
          local.all_resource_types[type].abbr
        ]))
        max_name_length = try(local.all_resource_types[type].max_name_length, -1)
        index_format    = try(local.all_resource_types[type].index_format, "%02d")
      }
    }
  }

  generated_names = { for
    domain, resources in local.generator_config : domain => { for # for each key (a.k.a. domain) in the "generator" map
      type, config in resources : type => [for                    # for each "resource_type" in the domain
        index in range(1, config.count + 1) :
        "${substr(join(config.separator, config.name_parts), 0, config.max_name_length)}${format(config.index_format, index)}"
    ] }
  }

  tags = {
    # Provisioned_by  = var.provisioned_by
    # Scheduler       = var.scheduler
    # Backup          = var.backup
    # Application     = var.application
    # Environment     = var.environment
    # Owner           = var.owner
    # Revenue         = var.revenue
    # App_id          = var.app_id
    # App_name        = var.app_name
    # App_tier        = var.app_tier
    # Business_dept   = var.product_area
    # Business_entity = var.business_division
    # Support_team    = var.support_team
    # Tech_lob        = var.tech_lob
    provisioned_by       = var.provisioned_by
    revenue              = var.revenue
    app_id               = var.app_id
    app_name             = var.app_name
    app_tier             = var.app_tier
    resource_group_owner = var.resource_group_owner
    support_team         = var.support_team
  }
}
