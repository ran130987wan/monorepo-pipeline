locals {
  # Define resource group types for different workloads
  resource_groups_map = {
    container = {
      name = "container"
      type = "container"
    },
    web = {
      name = "web"
      type = "web"
    },
    security = {
      name = "security"
      type = "security"
    },
    data = {
      name = "data"
      type = "data"
    },
    monitoring = {
      name = "monitoring"
      type = "monitoring"
    },
    network = {
      name = "network"
      type = "network"
    },
    platform = {
      name = "platform"
      type = "platform"
    },
    integration = {
      name = "integration"
      type = "integration"
    }
  }
  
  # Get region code from mapping
  region_code = var.azure_region_map[var.global_config.location]
  
  # Enable locks for production and staging environments
  enable_resource_group_lock = var.global_config.environment == "prod" || var.global_config.environment == "stage" ? true : false
}