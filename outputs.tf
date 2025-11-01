output "prefix" {
  value = "" # no longer used the same way, but keep for compatibility
}

output "tags" {
  value = local.tags
}

output "generated_names" {
  description = "All generated names: generated_names[domain][resource_type][index]"
  value       = local.generated_names
}

# convenience outputs
output "environment" {
  value = var.environment
}

output "location" {
  value = var.location
}

output "env_abbr" {
  description = "The abbreviated environment name."
  value       = local.env_abbr
}

# common case: "app" domain, "resource_group"
output "app_resource_group_name" {
  value = try(local.generated_names["app"]["resource_group"][0], null)
}
