resource "azurerm_user_assigned_identity" "umi" {           # Create Azure User Assigned Managed Identity
  name                = var.managed_identity.umi_name       # Name of the managed identity
  location            = var.managed_identity.location       # Azure region for the identity
  resource_group_name = var.managed_identity.resource_group_name # Resource group containing the identity
  tags                = var.managed_identity.tags           # Tags for resource organization
}