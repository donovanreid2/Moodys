output "prefix" {
  value = local.prefix
}

output "tags" {
  value = local.tags
}

output "generated_names" {
  value = local.generated_names
}
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
