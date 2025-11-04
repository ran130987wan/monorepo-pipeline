global_config = {
  prefix         = "vdc-entra-admin"
  compact_prefix = "vdcentraadm"
  environment    = "dev"
  location       = "centralus"
  region_code    = "cus"
  tags = {
    product     = "vdc-Entra-Admin"
    Environment = "dev"
    Source      = "terraform-gh-runner"
  }
}

aks_node_config = {
  kubernetes_cluster_id = "/subscriptions/c8d528f7-bee5-4164-bcd1-f84e9d444dcc/resourceGroups/vdc-entra-cus-gha-rg-dev/providers/Microsoft.ContainerService/managedClusters/vdc-entra-cus-gha-aks-dev"
  node_pool_name        = "entradmpool"
  vm_size               = "Standard_B2ms"
  enable_auto_scaling   = true
  node_count            = 1
  min_count             = 1
  max_count             = 2
  mode                  = "User"
  vnet_subnet_id        = "/subscriptions/c8d528f7-bee5-4164-bcd1-f84e9d444dcc/resourceGroups/vdc-entra-cus-gha-rg-dev/providers/Microsoft.Network/virtualNetworks/vdc-entra-cus-gha-vnet-dev/subnets/gha_runner_subnet"
  availability_zones    = ["3"]
  node_labels = {
    workload = "entraadmin-runner"
    env      = "dev"
  }
  node_taints          = ["workload=entraadmin:NoSchedule"]
  os_disk_size_gb      = 128
  os_type              = "Linux"
  max_pods             = 250
  orchestrator_version = "1.32.7"
  tags = {
    product     = "vdc-Entra-Admin"
    Environment = "dev"
    Source      = "terraform-gh-runner"
  }
}


federated_identity_credential = {
  name                = "github-dev-entraadmin"
  issuer              = "https://token.actions.githubusercontent.com",
  resource_group_name = "MC_vdc-entra-cus-gha-rg-dev_vdc-entra-cus-gha-aks-dev_centralus",
  parent_id           = "/subscriptions/c8d528f7-bee5-4164-bcd1-f84e9d444dcc/resourceGroups/MC_vdc-entra-cus-gha-rg-dev_vdc-entra-cus-gha-aks-dev_centralus/providers/Microsoft.ManagedIdentity/userAssignedIdentities/vdc-entra-cus-gha-aks-dev-agentpool",
  subject             = "repo:Veeam-VDC/vdc-entra-admin-portal:environment:dev",
  audiences           = ["api://AzureADTokenExchange"]
}