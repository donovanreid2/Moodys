output "resources" {
  description = "First generated name per resource type. Use: module.naming.resources.<type>.name"
  value       = local.resources_first
}

output "resource_group" {
  value = try(local.resources_first.resource_group.name, null)
}

output "storage_account" {
  value = try(local.resources_first.storage_account.name, null)
}

output "key_vault" {
  value = try(local.resources_first.key_vault.name, null)
}

output "container_registry" {
  value = try(local.resources_first.container_registry.name, null)
}

output "generated_names" {
  value = local.generated_names
}

output "tags" {
  value = local.tags
}

