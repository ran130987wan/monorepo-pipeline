# ============================================================================
# Local Variables
# ============================================================================
# Computed values and transformations used throughout the configuration
# Maps workload types to resource groups and applies naming standards
# ============================================================================

locals {
  # Master map of resource group types for workload separation
  # Each key represents a logical grouping of Azure resources
  resource_groups_map = {
    container = {
      name = "container"      # Container services (AKS, ACI)
      type = "container"
    },
    web = {
      name = "web"            # Web apps and frontend services
      type = "web"
    },
    security = {
      name = "security"       # Security tools (Key Vault, Sentinel)
      type = "security"
    },
    data = {
      name = "data"           # Data services (SQL, Cosmos, Storage)
      type = "data"
    },
    monitoring = {
      name = "monitoring"     # Observability (Log Analytics, App Insights)
      type = "monitoring"
    },
    network = {
      name = "network"        # Networking (VNet, NSG, Firewall)
      type = "network"
    },
    platform = {
      name = "platform"       # Platform services (API Management, Service Bus)
      type = "platform"
    },
    integration = {
      name = "integration"    # Integration services (Logic Apps, Functions)
      type = "integration"
    }
  }

  # Lookup region short code from full region name
  region_code = var.azure_region_map[var.global_config.location]

  # Conditional lock - enabled only for prod/stage to prevent accidental deletion
  enable_resource_group_lock = var.global_config.environment == "prod" || var.global_config.environment == "stage" ? true : false

  # Transform map to list with standardized naming pattern
  # Pattern: {compact_prefix}-{workload}-rg-{environment}
  # Example: vdccpadm-container-rg-dev
  resource_groups = [
    for rg in local.resource_groups_map : {
      name     = "${var.global_config.compact_prefix}-${rg.name}-rg-${var.global_config.environment}"
      location = var.global_config.location
      locks    = local.enable_resource_group_lock
      tags     = var.global_config.tags
    }
  ]
}
