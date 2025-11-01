output "resources" {
  description = "First generated name per resource type. Use: module.naming.resources.<type>.name"
  value       = local.resources_first
}

# Shortcuts for common resources
output "resource_group" {
  value = local.resources_first.resource_group
}

output "storage_account" {
  value = local.resources_first.storage_account
}

output "key_vault" {
  value = local.resources_first.key_vault
}

output "container_registry" {
  value = local.resources_first.container_registry
}

output "generated_names" {
  value = local.generated_names
}

output "tags" {
  value = local.tags
}
