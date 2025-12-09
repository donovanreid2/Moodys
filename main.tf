# =============================================================================
# AKS MANAGED NAMESPACE MODULE
# =============================================================================
# Creates Azure managed namespaces with resource limits, network policies, 
# labeling, and RBAC using the Azure API provider for native Azure integration

# =============================================================================
# DATA SOURCES
# =============================================================================

# Get current Azure client configuration
data "azurerm_client_config" "current" {}

# =============================================================================
# ROLE DEFINITIONS FOR RBAC
# =============================================================================

# Azure Kubernetes Service Namespace Contributor - Can manage all resources within namespace except RBAC
data "azurerm_role_definition" "aks_ns_contributor" {
  name = "Azure Kubernetes Service Namespace Contributor"
}

# Azure Kubernetes Service Namespace User - Can view and use resources but not create/delete them
data "azurerm_role_definition" "aks_ns_user" {
  name = "Azure Kubernetes Service Namespace User"
}

# Azure Kubernetes Service RBAC Reader - Can view all resources including RBAC but cannot modify
data "azurerm_role_definition" "aks_rbac_reader" {
  name = "Azure Kubernetes Service RBAC Reader"
}

# Azure Kubernetes Service RBAC Writer - Can create/update/delete most resources but not RBAC
data "azurerm_role_definition" "aks_rbac_writer" {
  name = "Azure Kubernetes Service RBAC Writer"
}

# Azure Kubernetes Service RBAC Admin - Full admin access including RBAC management within namespace  
data "azurerm_role_definition" "aks_rbac_admin" {
  name = "Azure Kubernetes Service RBAC Admin"
}

# =============================================================================
# AZURE MANAGED NAMESPACE CREATION
# =============================================================================

// ...existing code...
resource "azapi_resource" "managed_namespace" {
  for_each = var.namespaces

  type      = "Microsoft.ContainerService/managedClusters/managedNamespaces@2025-10-01"
  name      = each.key
  parent_id = var.aks_cluster_id
  location  = "eastus2"

  body = {
    properties = {
      labels = merge(var.namespace_labels, var.additional_labels[each.key], {
        "app.kubernetes.io/name"    = each.key
        "app.kubernetes.io/part-of" = "enterprise-platform"
        "managed-by"                = "terraform"
      })

      annotations = {
        "description"                        = each.value
        "kubernetes.io/managed-by"          = "terraform"
        "azure.workload.identity/tenant-id" = data.azurerm_client_config.current.tenant_id
        "business-unit"                     = lookup(var.additional_labels[each.key], "business_unit", each.key)
        "cost-center"                       = lookup(var.additional_labels[each.key], "cost_center", "unknown")
        "data-classification"               = lookup(var.additional_labels[each.key], "data_classification", "internal")
      }

      // CPU must be milliCPU with 'm' suffix; minimum request is 1m
      defaultResourceQuota = {
        cpuLimit      = "${floor(tonumber(var.resource_quotas[each.key].cpu_limit) * 1000)}m"
        cpuRequest    = "${max(1, floor(tonumber(var.resource_quotas[each.key].cpu_request) * 1000))}m"
        memoryLimit   = var.resource_quotas[each.key].memory_limit
        memoryRequest = var.resource_quotas[each.key].memory_request
      }

      // Required: ingress/egress must be "allowAll" or "denyAll"
      defaultNetworkPolicy = {
        ingress = var.network_policies[each.key].default_deny_ingress ? "denyAll" : "allowAll"
        egress  = var.network_policies[each.key].default_deny_egress  ? "denyAll" : "allowAll"
      }
    }
  }

  schema_validation_enabled = false
  ignore_casing             = false
  ignore_missing_property   = false
}
// ...existing code...

# Resource quotas are now configured as defaultResourceQuota within the managed namespace resource above

# Network policies are now configured as defaultNetworkPolicy within the managed namespace resource above

# =============================================================================
# AZURE RBAC ROLE ASSIGNMENTS
# =============================================================================

# Cluster User Role - Allows viewing namespaces and basic cluster resources in Azure portal
# Create one assignment per unique user across all namespaces
resource "azurerm_role_assignment" "cluster_user" {
  for_each = toset(flatten([
    for ns_name, ns_rbac in var.namespace_rbac : [
      concat(
        ns_rbac.contributors,
        ns_rbac.users,
        ns_rbac.rbac_readers,
        ns_rbac.rbac_writers,
        ns_rbac.rbac_admins
      )
    ]
  ]))

  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = each.value
}

# Contributors - Can manage all resources within specific managed namespace
resource "azurerm_role_assignment" "namespace_contributors" {
  for_each = {
    for assignment in flatten([
      for ns_name, ns_rbac in var.namespace_rbac : [
        for contributor in ns_rbac.contributors : {
          namespace_name = ns_name
          principal_id   = contributor
          role_type     = "contributor"
          assignment_id = "${ns_name}-${contributor}-contributor"
        }
      ]
    ]) : assignment.assignment_id => assignment
  }

  scope                = "${var.aks_cluster_id}/managedNamespaces/${each.value.namespace_name}"
  role_definition_id   = data.azurerm_role_definition.aks_ns_contributor.id
  principal_id         = each.value.principal_id

  depends_on = [azapi_resource.managed_namespace]
}

# Users - Can view and use resources within specific managed namespace
resource "azurerm_role_assignment" "namespace_users" {
  for_each = {
    for assignment in flatten([
      for ns_name, ns_rbac in var.namespace_rbac : [
        for user in ns_rbac.users : {
          namespace_name = ns_name
          principal_id   = user
          role_type     = "user"
          assignment_id = "${ns_name}-${user}-user"
        }
      ]
    ]) : assignment.assignment_id => assignment
  }

  scope                = "${var.aks_cluster_id}/managedNamespaces/${each.value.namespace_name}"
  role_definition_id   = data.azurerm_role_definition.aks_ns_user.id
  principal_id         = each.value.principal_id

  depends_on = [azapi_resource.managed_namespace]
}

# RBAC Readers - Can view all resources including RBAC within specific managed namespace
resource "azurerm_role_assignment" "namespace_rbac_readers" {
  for_each = {
    for assignment in flatten([
      for ns_name, ns_rbac in var.namespace_rbac : [
        for reader in ns_rbac.rbac_readers : {
          namespace_name = ns_name
          principal_id   = reader
          role_type     = "rbac_reader"
          assignment_id = "${ns_name}-${reader}-rbac-reader"
        }
      ]
    ]) : assignment.assignment_id => assignment
  }

  scope                = "${var.aks_cluster_id}/managedNamespaces/${each.value.namespace_name}"
  role_definition_id   = data.azurerm_role_definition.aks_rbac_reader.id
  principal_id         = each.value.principal_id

  depends_on = [azapi_resource.managed_namespace]
}

# RBAC Writers - Can create/update/delete most resources within specific managed namespace
resource "azurerm_role_assignment" "namespace_rbac_writers" {
  for_each = {
    for assignment in flatten([
      for ns_name, ns_rbac in var.namespace_rbac : [
        for writer in ns_rbac.rbac_writers : {
          namespace_name = ns_name
          principal_id   = writer
          role_type     = "rbac_writer"
          assignment_id = "${ns_name}-${writer}-rbac-writer"
        }
      ]
    ]) : assignment.assignment_id => assignment
  }

  scope                = "${var.aks_cluster_id}/managedNamespaces/${each.value.namespace_name}"
  role_definition_id   = data.azurerm_role_definition.aks_rbac_writer.id
  principal_id         = each.value.principal_id

  depends_on = [azapi_resource.managed_namespace]
}

# RBAC Admins - Full admin access including RBAC management within specific managed namespace
resource "azurerm_role_assignment" "namespace_rbac_admins" {
  for_each = {
    for assignment in flatten([
      for ns_name, ns_rbac in var.namespace_rbac : [
        for admin in ns_rbac.rbac_admins : {
          namespace_name = ns_name
          principal_id   = admin
          role_type     = "rbac_admin"
          assignment_id = "${ns_name}-${admin}-rbac-admin"
        }
      ]
    ]) : assignment.assignment_id => assignment
  }

  scope                = "${var.aks_cluster_id}/managedNamespaces/${each.value.namespace_name}"
  role_definition_id   = data.azurerm_role_definition.aks_rbac_admin.id
  principal_id         = each.value.principal_id

  depends_on = [azapi_resource.managed_namespace]
}

# =============================================================================
# NOTE: Azure managed namespaces provide native integration with Azure RBAC
# These assignments enable full namespace management through the Azure portal
# and provide enterprise-grade governance and compliance capabilities
# =============================================================================

error:

│ Error: Failed to create/update resource
│
│   with module.aks_managed_namespaces.azapi_resource.managed_namespace["it"],
│   on modules\aks_managed_namespace\main.tf line 48, in resource "azapi_resource" "managed_namespace": 
│   48: resource "azapi_resource" "managed_namespace" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/it"
│ / Api Version "2025-10-01"): PUT
│ https://management.azure.com/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/it
│ --------------------------------------------------------------------------------
│ RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidParameter
│ --------------------------------------------------------------------------------
│ {
│   "code": "InvalidParameter",
│   "details": null,
│   "message": "The value of parameter properties.networkPolicy is invalid. Error details: The ingress network policy of the managed namespace must be valid. Please see https://aka.ms/aks-naming-rules for more details.",
│   "subcode": "",
│   "target": "properties.networkPolicy"
│ }
│ --------------------------------------------------------------------------------
│
╵
╷
│ Error: Failed to create/update resource
│
│   with module.aks_managed_namespaces.azapi_resource.managed_namespace["hr"],
│   on modules\aks_managed_namespace\main.tf line 48, in resource "azapi_resource" "managed_namespace": 
│   48: resource "azapi_resource" "managed_namespace" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/hr"
│ / Api Version "2025-10-01"): PUT
│ https://management.azure.com/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/hr
│ --------------------------------------------------------------------------------
│ RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidParameter
│ --------------------------------------------------------------------------------
│ {
│   "code": "InvalidParameter",
│   "details": null,
│   "message": "The value of parameter properties.networkPolicy is invalid. Error details: The ingress network policy of the managed namespace must be valid. Please see https://aka.ms/aks-naming-rules for more details.",
│   "subcode": "",
│   "target": "properties.networkPolicy"
│ }
│ --------------------------------------------------------------------------------
│
╵
╷
│ Error: Failed to create/update resource
│
│   with module.aks_managed_namespaces.azapi_resource.managed_namespace["devops"],
│   on modules\aks_managed_namespace\main.tf line 48, in resource "azapi_resource" "managed_namespace": 
│   48: resource "azapi_resource" "managed_namespace" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/devops"
│ / Api Version "2025-10-01"): PUT
│ https://management.azure.com/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/devops
│ --------------------------------------------------------------------------------
│ RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidParameter
│ --------------------------------------------------------------------------------
│ {
│   "code": "InvalidParameter",
│   "details": null,
│   "message": "The value of parameter properties.networkPolicy is invalid. Error details: The ingress network policy of the managed namespace must be valid. Please see https://aka.ms/aks-naming-rules for more details.",
│   "subcode": "",
│   "target": "properties.networkPolicy"
│ }
│ --------------------------------------------------------------------------------
│
╵
╷
│ Error: Failed to create/update resource
│
│   with module.aks_managed_namespaces.azapi_resource.managed_namespace["legal"],
│   on modules\aks_managed_namespace\main.tf line 48, in resource "azapi_resource" "managed_namespace": 
│   48: resource "azapi_resource" "managed_namespace" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/legal"
│ / Api Version "2025-10-01"): PUT
│ https://management.azure.com/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/legal
│ --------------------------------------------------------------------------------
│ RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidParameter
│ --------------------------------------------------------------------------------
│ {
│   "code": "InvalidParameter",
│   "details": null,
│   "message": "The value of parameter properties.networkPolicy is invalid. Error details: The ingress network policy of the managed namespace must be valid. Please see https://aka.ms/aks-naming-rules for more details.",
│   "subcode": "",
│   "target": "properties.networkPolicy"
│ }
│ --------------------------------------------------------------------------------
│
╵
╷
│ Error: Failed to create/update resource
│
│   with module.aks_managed_namespaces.azapi_resource.managed_namespace["finance"],
│   on modules\aks_managed_namespace\main.tf line 48, in resource "azapi_resource" "managed_namespace": 
│   48: resource "azapi_resource" "managed_namespace" {
│
│ creating/updating Resource: (ResourceId
│ "/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/finance"
│ / Api Version "2025-10-01"): PUT
│ https://management.azure.com/subscriptions/e2d23da8-0e96-45de-83ae-ab86da579f95/resourceGroups/rg-containers-dev-eus2-01/providers/Microsoft.ContainerService/managedClusters/aks-platform-eastus2/managedNamespaces/finance
│ --------------------------------------------------------------------------------
│ RESPONSE 400: 400 Bad Request
│ ERROR CODE: InvalidParameter
│ --------------------------------------------------------------------------------
│ {
│   "code": "InvalidParameter",
│   "details": null,
│   "message": "The value of parameter properties.networkPolicy is invalid. Error details: The ingress network policy of the managed namespace must be valid. Please see https://aka.ms/aks-naming-rules for more details.",
│   "subcode": "",
│   "target": "properties.networkPolicy"
│ }
│ --------------------------------------------------------------------------------
│
