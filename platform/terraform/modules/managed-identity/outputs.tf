output "managed_identity_id" {
    value = azurerm_user_assigned_identity.umi.principal_id
}

output "managed_identity_name" {
    value = azurerm_user_assigned_identity.umi.name
}

output "managed_identity_obj_id" {
    value = azurerm_user_assigned_identity.umi.id
}