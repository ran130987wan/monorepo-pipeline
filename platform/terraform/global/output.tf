# Output all resource group IDs
output "resource_group_ids" {
  description = "Map of resource group names to their Azure resource IDs"
  value       = module.resource_groups.resource_group_ids
}

# Output all resource group names
output "resource_group_names" {
  description = "Map of resource group names to their display names"
  value       = module.resource_groups.resource_group_names
}

# Output specific resource groups for easy reference in other modules
output "container_rg_id" {
  description = "Resource ID of the container resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-container-rg-${var.global_config.environment}"]
}

output "web_rg_id" {
  description = "Resource ID of the web resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-web-rg-${var.global_config.environment}"]
}

output "data_rg_id" {
  description = "Resource ID of the data resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-data-rg-${var.global_config.environment}"]
}

output "network_rg_id" {
  description = "Resource ID of the network resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-network-rg-${var.global_config.environment}"]
}

output "security_rg_id" {
  description = "Resource ID of the security resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-security-rg-${var.global_config.environment}"]
}

output "monitoring_rg_id" {
  description = "Resource ID of the monitoring resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-monitoring-rg-${var.global_config.environment}"]
}

output "platform_rg_id" {
  description = "Resource ID of the platform resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-platform-rg-${var.global_config.environment}"]
}

output "integration_rg_id" {
  description = "Resource ID of the integration resource group"
  value       = module.resource_groups.resource_group_ids["${var.global_config.compact_prefix}-integration-rg-${var.global_config.environment}"]
}