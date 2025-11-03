resource "azurerm_user_assigned_identity" "umi" {
  name                = var.managed_identity.umi_name
  location            = var.managed_identity.location
  resource_group_name = var.managed_identity.resource_group_name
  tags                = var.managed_identity.tags

  

}