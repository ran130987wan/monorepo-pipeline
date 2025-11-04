output "resource_group_ids" {                                                     # Output map of resource group IDs
    description = "IDs of the created resource groups."
    value       = { for name, rg in azurerm_resource_group.this : name => rg.id } # Map of RG names to their Azure resource IDs
}

output "resource_group_names" {                                                   # Output map of resource group names
    description = "Names of the created resource groups."
    value       = { for name, rg in azurerm_resource_group.this : name => rg.name } # Map of RG names to their display names
}