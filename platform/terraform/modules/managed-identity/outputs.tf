output "managed_identity_id" {                                  # Output the service principal ID
    value = azurerm_user_assigned_identity.umi.principal_id # Principal ID used for role assignments
}

output "managed_identity_name" {                            # Output the identity name
    value = azurerm_user_assigned_identity.umi.name         # Name of the managed identity
}

output "managed_identity_obj_id" {                          # Output the full resource ID
    value = azurerm_user_assigned_identity.umi.id           # Azure resource ID for the managed identity
}