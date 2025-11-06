# ============================================================================
# Main Resource Configuration
# ============================================================================
# Creates Azure resource groups using a reusable module from external repo
# Module handles resource group creation with optional locks
# ============================================================================

# Resource group module - creates all infrastructure resource groups
# Source: External Git repository with versioned modules
# Input: List of resource groups transformed from locals.resource_groups
module "resource_groups" {
  source = "git::https://github.com/ran130987wan/terraform-modules.git//terraform/modules/resource-group?ref=resource-group/v1.0.0"

  resource_groups = local.resource_groups # Passes the transformed list of 8 RGs
}
