resource "azurerm_resource_group" "this" {
  for_each = { for rg in var.resource_groups : rg.name => rg }

  name     = each.value.name
  location = each.value.location
  tags     = each.value.tags
}

resource "azurerm_management_lock" "rg_lock" {
  for_each = {
    for rg in var.resource_groups : rg.name => rg
    if rg.locks
  }

  name               = "${each.value.name}-lock"
  scope              = azurerm_resource_group.this[each.key].id
  lock_level        = "CanNotDelete"
  notes             = "Resource group lock enabled via Terraform."
}