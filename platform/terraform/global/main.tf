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

module "resource_groups" {
  source          = "../modules/resource-group"
  resource_groups = locals.resource_groups
}
/*
module "vnet" {
  source     = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/vnet?ref=vnet/v1.0.0"
  vnet       = var.vnet
  depends_on = [module.resource_groups]
}

module "subnet" {
  source     = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/subnet?ref=subnet/v1.0.0"
  subnets    = var.subnets
  depends_on = [module.vnet]
}
*/

module "managed_identity" {
  source           = "../modules/managed-identity"
  managed_identity = var.managed_identity
  depends_on       = [module.resource_groups]
}

/*
module "nat_gateway" {
  source      = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/nat-gateway?ref=nat-gw/v1.0.0"
  nat_gateway = var.nat_gateway
  depends_on  = [module.resource_groups]
}

module "public_ip" {
  source     = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/public-ip?ref=public-ip/v1.0.0"
  public_ip  = var.public_ip
  depends_on = [module.resource_groups]
}

module "nat_gw_public_ip_association" {
  source = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/natgw-publicip-assoc?ref=nat-gw-publicip-assoc/v1.0.0"

  natgw_public_ip_assoc = {
    nat_gateway_id = module.nat_gateway.nat_gateway_id
    public_ip_id   = module.public_ip.public_ip_id
  }

  depends_on = [module.public_ip, module.nat_gateway]
}

module "subnet_natgw_association" {
  source = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/subnet-natgw-assoc?ref=subnet-natgw-assoc/v1.0.0"
  config = {
    nat_gateway_id = module.nat_gateway.nat_gateway_id
    subnet_id      = module.subnet.subnet_ids["aks-snet"]
  }
  depends_on = [module.resource_groups, module.nat_gateway, module.subnet]
}

module "aks" {
  source = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/aks?ref=aks/v1.0.0"
  aks = merge(
    var.aks,
    {
      default_node_pool = merge(
        var.aks.default_node_pool,
        { vnet_subnet_id = module.subnet.subnet_ids["aks-snet"] }
      )
      managed_identity_obj_id = module.managed_identity.managed_identity_obj_id
    }
  )
  depends_on = [module.subnet, module.managed_identity, module.nat_gw_public_ip_association, module.subnet_natgw_association]
}

module "aks_node" {
  source = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/aks-node?ref=aks-node/v1.0.0"
  aks_node = merge(
    var.aks_node_config,
    {
      kubernetes_cluster_id = module.aks.aks_id,
      vnet_subnet_id        = module.subnet.subnet_ids["aks-snet"]
    }
  )
  depends_on = [module.subnet, module.aks]
}

module "acr" {
  source = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/acr?ref=acr/v1.0.0"
  acr = merge(
    var.acr,
    { identity_ids = [module.managed_identity.managed_identity_obj_id] }
  )
  depends_on = [module.resource_groups]
}

module "swa" {
  source       = "git::https://github.com/Veeam-VDC/vdc-admin-portal-utils.git//terraform/modules/static-web-app?ref=static-web-app/v1.0.1"
  staticwebapp = var.staticwebapp
  depends_on   = [module.resource_groups]
}
*/
