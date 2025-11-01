# the main one: EVERYTHING here
output "resources" {
  description = "First generated name for every known resource type. Use: module.naming.resources.<type>.name"
  value       = local.first_names
}

# shortcuts if you want them
output "resource_group" {
  value = local.first_names.resource_group
}

output "storage_account" {
  value = local.first_names.storage_account
}

output "key_vault" {
  value = local.first_names.key_vault
}

output "container_registry" {
  value = local.first_names.container_registry
}

output "generated_names" {
  value = local.generated_names
}

output "tags" {
  value = local.tags
}

