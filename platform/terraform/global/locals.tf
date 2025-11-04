locals {
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
  region_code                = var.azure_region_map[var.global_config.location]
  enable_resource_group_lock = var.global_config.environment == "prod" || var.global_config.environment == "stage" ? true : false

  resource_groups = [
    for rg in local.resource_groups_map : {
      name     = "${var.global_config.compact_prefix}-${rg.name}-rg-${var.global_config.environment}"
      location = var.global_config.location
      locks    = local.enable_resource_group_lock
      tags     = var.global_config.tags
    }
  ]
}
