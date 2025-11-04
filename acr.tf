# =============================================================================
# AZURE CONTAINER REGISTRY (ACR) CONFIGURATION
# =============================================================================
# Creates Azure Container Registry with geo-replication and private endpoint access
# Provides secure container image storage for AKS clusters across multiple regions

# Primary ACR instance in the primary region with geo-replication
resource "azurerm_container_registry" "acr_primary" {
  name                          = var.acr.name
  resource_group_name           = var.resource_group_name
  location                      = var.primary_region
  sku                           = var.acr.sku                           # Premium SKU required for geo-replication
  admin_enabled                 = var.acr.admin_enabled                 # Disable admin user for enhanced security
  public_network_access_enabled = var.acr.public_network_access_enabled # Restrict to private access only
  quarantine_policy_enabled     = var.acr.quarantine_policy_enabled     # Enable vulnerability scanning
  retention_policy_in_days      = var.acr.retention_policy_in_days      # Automated cleanup of old images
  trust_policy_enabled          = var.acr.trust_policy_enabled          # Content trust for image integrity
  zone_redundancy_enabled       = var.acr.zone_redundancy_enabled       # High availability within region
  export_policy_enabled         = var.acr.export_policy_enabled         # Control image export capabilities
  anonymous_pull_enabled        = var.acr.anonymous_pull_enabled        # Disable anonymous access
  data_endpoint_enabled         = var.acr.data_endpoint_enabled         # Regional data endpoints
  network_rule_bypass_option    = var.acr.network_rule_bypass_option    # Network access control

  # Geo-replication to secondary region
  georeplications {
    location                  = var.secondary_region
    regional_endpoint_enabled = true
    zone_redundancy_enabled   = var.acr.zone_redundancy_enabled
    tags                      = merge( var.acr.tags)
  }

  # Additional custom georeplications if specified
  dynamic "georeplications" {
    for_each = var.acr.georeplications != null ? var.acr.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = georeplications.value.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = var.acr.network_rule_set != null ? [var.acr.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action
      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules != null ? network_rule_set.value.ip_rules : []
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  dynamic "identity" {
    for_each = var.acr.identity != null ? [var.acr.identity] : []
    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "encryption" {
    for_each = var.acr.encryption != null ? [var.acr.encryption] : []
    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  tags = merge( var.acr.tags)

  lifecycle {
    ignore_changes = [
      tags,
      georeplications[0].tags
    ]
  }
}


# Private endpoint for ACR in primary region
resource "azurerm_private_endpoint" "acr_primary" {
  name                = coalesce(var.acr.private_endpoint_primary_name, "${var.acr.name}-pe")
  location            = var.primary_region
  resource_group_name = var.resource_group_name
  subnet_id           = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.network_config[var.primary_region].vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${var.network_config[var.primary_region].vnet_name}/subnets/${var.network_config[var.primary_region].private_endpoint_subnet_name}"

  private_service_connection {
    name                           = coalesce(var.acr.private_service_connection_primary_name, "${var.acr.name}-pe-conn")
    private_connection_resource_id = azurerm_container_registry.acr_primary.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = try(merge( var.acr.tags), {})

  lifecycle {
    ignore_changes = [
      private_dns_zone_group,
      tags
    ]
  }
}

# Private endpoint for ACR in secondary region (for geo-replication access)
resource "azurerm_private_endpoint" "acr_secondary" {
  name                = coalesce(var.acr.private_endpoint_secondary_name, "${var.acr.name}-secondary-pe")
  location            = var.secondary_region
  resource_group_name = coalesce(var.secondary_resource_group_name, var.resource_group_name)
  subnet_id           = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.network_config[var.secondary_region].vnet_resource_group}/providers/Microsoft.Network/virtualNetworks/${var.network_config[var.secondary_region].vnet_name}/subnets/${var.network_config[var.secondary_region].private_endpoint_subnet_name}"

  private_service_connection {
    name                           = coalesce(var.acr.private_service_connection_secondary_name, "${var.acr.name}-secondary-pe-conn")
    private_connection_resource_id = azurerm_container_registry.acr_primary.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  tags = try(merge( var.acr.tags), {})

  lifecycle {
    ignore_changes = [
      private_dns_zone_group,
      tags
    ]
  }
}

# Role assignment for AKS cluster identity to pull images from ACR (AcrPull role)
resource "azurerm_pim_active_role_assignment" "aks_acr_pull" {
  for_each           = { for cluster_key, cluster_config in var.aks_cluster : cluster_key => cluster_config if lookup(cluster_config, "attach_acr", false) }
  scope              = azurerm_container_registry.acr_primary.id
  role_definition_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d"
  principal_id       = azurerm_user_assigned_identity.aks_cluster_identity[each.key].principal_id

  schedule {
    expiration {
      duration_days = 180
    }
  }

  justification = "Permanent assignment for AKS cluster identity to pull container images from primary ACR with geo-replication"

  depends_on = [
    azurerm_container_registry.acr_primary,
    azurerm_user_assigned_identity.aks_cluster_identity
  ]
}

resource "azurerm_container_registry_task" "docker_build" {
  name                  = "build-dockerfile-task"
  container_registry_id = module.acr.acr_id
  agent_pool_name       = "acr-agent-pool" # Use dedicated agent pool

  platform {
    os = "Linux"
  }

  docker_step {
    dockerfile_path      = "Dockerfile"
    context_path         = "https://github.com/Azure/acr-build.git#main"
    context_access_token = "00000000000000000000000000000000000000000"
    image_names = [
      "acr-build-demo:{{.Run.ID}}",
      "acr-build-demo:latest"
    ]
  }

  tags = merge(local.common_tags, {
    Purpose = "dockerfile-build"
    Service = "acr-task"
  })

  depends_on = [module.acr]
}

# =============================================================================
# AUTO-TRIGGER INITIAL BUILD (COMMENTED OUT - TROUBLESHOOTING)
# =============================================================================
# Uncomment after verifying the build task works manually

# resource "azurerm_container_registry_task_schedule_run_now" "trigger_initial_build" {
#   container_registry_task_id = azurerm_container_registry_task.docker_build.id
#   depends_on = [azurerm_container_registry_task.docker_build]
# }
