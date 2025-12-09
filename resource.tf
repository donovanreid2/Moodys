resource "azapi_resource" "managed_namespace" {
  for_each = var.namespaces

  type      = "Microsoft.ContainerService/managedClusters/managedNamespaces@2025-09-01"
  name      = each.key
  parent_id = var.aks_cluster_id
  location  = "eastus2"

  body = {
    properties = {
      # Optional but explicit
      adoptionPolicy = "Always"

      labels = merge(
        var.namespace_labels,
        try(var.additional_labels[each.key], {}),
        {
          "app.kubernetes.io/name"    = each.key
          "app.kubernetes.io/part-of" = "enterprise-platform"
          "managed-by"                = "terraform"
        }
      )

      annotations = merge(
        {
          "description"                        = each.value
          "kubernetes.io/managed-by"          = "terraform"
          "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
        },
        # Safely look up optional keys from additional_labels
        {
          "business-unit"       = try(var.additional_labels[each.key]["business_unit"], each.key)
          "cost-center"         = try(var.additional_labels[each.key]["cost_center"], "unknown")
          "data-classification" = try(var.additional_labels[each.key]["data_classification"], "internal")
        }
      )

      # Quotas must be strings; CPU in m (milliCPU)
      defaultResourceQuota = {
        cpuLimit      = "${floor(tonumber(var.resource_quotas[each.key].cpu_limit) * 1000)}m"
        cpuRequest    = "${max(1, floor(tonumber(var.resource_quotas[each.key].cpu_request) * 1000))}m"
        memoryLimit   = var.resource_quotas[each.key].memory_limit
        memoryRequest = var.resource_quotas[each.key].memory_request
      }

      # Valid enums are: AllowAll | AllowSameNamespace | DenyAll
      defaultNetworkPolicy = {
        ingress = var.network_policies[each.key].default_deny_ingress ? "DenyAll" : "AllowSameNamespace"
        egress  = var.network_policies[each.key].default_deny_egress  ? "DenyAll" : "AllowAll"
      }
    }
  }

  schema_validation_enabled = false
  ignore_casing             = false
  ignore_missing_property   = false
}
