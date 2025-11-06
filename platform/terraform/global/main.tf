# Call the resource-group module from terraform-modules repository
module "resource_groups" {
  source = "git::https://github.com/ran130987wan/terraform-modules.git//terraform/modules/resource-group?ref=resource-group/v1.0.0"

  resource_groups = local.resource_groups
}
