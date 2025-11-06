# Transform the resource groups map into the format expected by the module
locals {
  resource_groups = [
    for rg in locals.resource_groups_map : {
      name     = "${var.global_config.compact_prefix}-${rg.name}-rg-${var.global_config.environment}"
      location = var.global_config.location
      locks    = locals.enable_resource_group_lock
      tags     = var.global_config.tags
    }
  ]
}

# Call the resource-group module from terraform-modules repository
module "resource_groups" {
  source = "git::https://github.com/ran130987wan/terraform-modules.git//terraform/modules/resource-group?ref=resource-group/v1.0.0"
  
  resource_groups = locals.resource_groups
}