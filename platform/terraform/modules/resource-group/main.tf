resource "azurerm_resource_group" "this" {                      # Create Azure resource groups
  for_each = { for rg in var.resource_groups : rg.name => rg } # Loop through list and create map with name as key

  name     = each.value.name                                    # Resource group name
  location = each.value.location                                # Azure region for the resource group
  tags     = each.value.tags                                    # Tags for resource organization
}

resource "azurerm_management_lock" "rg_lock" {                 # Create management locks on resource groups
  for_each = {                                                  # Loop through resource groups
    for rg in var.resource_groups : rg.name => rg               # Create map with name as key
    if rg.locks                                                 # Only include if locks flag is true
  }

  name               = "${each.value.name}-lock"                # Lock name with suffix
  scope              = azurerm_resource_group.this[each.key].id # Resource group ID to lock
  lock_level         = "CanNotDelete"                           # Prevent deletion but allow modifications
  notes              = "Resource group lock enabled via Terraform." # Description of the lock
}