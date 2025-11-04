variable "global_config" {
  type = object({
    prefix         = string
    compact_prefix = string
    environment    = string
    location       = string
    region_code    = string
    tags           = map(string)
  })
}
variable "azure_region_map" {
  type = map(string)
  default = {
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "centralus"          = "cus"
    "southcentralus"     = "scus"
    "northcentralus"     = "ncus"
    "westcentralus"      = "wcus"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "northeurope"        = "neu"
    "westeurope"         = "weu"
    "southeastasia"      = "sea"
    "eastasia"           = "ea"
    "australiaeast"      = "aue"
    "australiasoutheast" = "ause"
    "brazilsouth"        = "brs"
    "brazilsoutheast"    = "brse"
    "canadacentral"      = "canc"
    "canadaeast"         = "cane"
    "indiawest"          = "inw"
    "indiasouth"         = "ins"
    "indianorth"         = "inn"
    "koreacentral"       = "korc"
    "koreasouth"         = "kors"
    "southafricanorth"   = "san"
    "southafricawest"    = "saw"
    "japaneast"          = "jpe"
    "japanwest"          = "jpw"
    "swedencentral"      = "swc"
  }
}

/* ---------------------------------------------------------------------------------------------------------------------------- */
/*                                                Global Configuration Variables                                                */
/* ---------------------------------------------------------------------------------------------------------------------------- */
variable "resource_groups" {
  description = "List of configuration objects for the Resource Group module."
  type = list(object({
    name     = string
    location = string
    locks    = bool
    tags     = map(string)
  }))
  default = [
    {
      name     = ""
      location = ""
      locks    = false
      tags     = {}
    }
  ]
}

variable "vnet" {
  description = "Configuration object for the Virtual Network module."
  type = object({
    name                    = string
    resource_group_name     = string
    location                = string
    address_space           = list(string)
    tags                    = map(string)
    ddos_protection_plan_id = optional(string)
  })
  default = {
    name                = ""
    resource_group_name = ""
    location            = ""
    address_space       = []
    tags                = {}
  }
}
variable "subnets" {
  description = "List of subnets to create inside the VNet."
  type = list(object({
    name                                           = string
    resource_group_name                            = string
    virtual_network_name                           = string
    address_prefixes                               = list(string)
    service_endpoints                              = optional(list(string), [])
    delegation                                     = optional(list(string), [])
    private_link_service_network_policies_disabled = optional(bool, false)
  }))
  default = [
    {
      name                                           = ""
      resource_group_name                            = ""
      virtual_network_name                           = ""
      address_prefixes                               = []
      service_endpoints                              = []
      delegation                                     = []
      private_link_service_network_policies_disabled = false
    }
  ]
}

variable "aks" {
  description = "Configuration object for the AKS cluster module."
  type = object({
    name                                = string
    resource_group_name                 = string
    location                            = string
    dns_prefix                          = string
    kubernetes_version                  = string
    private_cluster_enabled             = bool
    private_cluster_public_fqdn_enabled = bool
    private_dns_zone_id                 = string
    sku_tier                            = string
    managed_identity_obj_id             = string
    force_upgrade_enabled               = bool
    azs                                 = list(string)

    # Default node pool configuration
    default_node_pool = object({
      name                         = string
      vm_size                      = string
      os_disk_size_gb              = number
      enable_auto_scaling          = bool
      min_count                    = number
      max_count                    = number
      max_pods                     = number
      only_critical_addons_enabled = bool
      orchestrator_version         = string
      container_log_max_line       = number
      container_log_max_size_mb    = number
      node_labels                  = map(string)
      vnet_subnet_id               = string
    })

    # Network configuration
    network_profile = object({
      network_policy      = string
      network_plugin      = string
      network_plugin_mode = string
      outbound_type       = string
      load_balancer_sku   = string
      service_cidr        = string
      dns_service_ip      = string
      pod_cidr            = string
    })

    # RBAC and AAD configuration
    local_account_disabled            = bool
    role_based_access_control_enabled = bool
    azure_rbac_enabled                = bool
    tenant_id                         = string

    # Monitoring configuration
    monitor_metrics_config = object({
      annotations_allowed = list(string)
      labels_allowed      = list(string)
    })
    vdc_entra_law_id          = string
    microsoft_defender_law_id = string

    # Maintenance configuration
    maintenance_config = optional(object({
      frequency   = optional(string)
      interval    = optional(string)
      duration    = optional(string)
      day_of_week = optional(string)
      start_time  = optional(string)
      utc_offset  = optional(string)
    }))

    tags             = map(string)
    acr_login_server = string
  })
}

variable "managed_identity" {
  description = "Combined configuration for the managed identity module."
  type = object({
    umi_name            = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })
}

variable "nat_gateway" {
  description = "Configuration object for Azure NAT Gateway"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = string
    tags                = map(string)
  })
}

variable "public_ip" {
  description = "Configuration object for the Public IP resource."
  type = object({
    name                = string
    resource_group_name = string
    location            = string

    sku               = optional(string, "Standard") # Basic | Standard
    allocation_method = optional(string, "Static")   # Static | Dynamic
    ip_version        = optional(string, "IPv4")     # IPv4 | IPv6
    zones             = optional(list(string))       # e.g. ["1","2","3"]

    domain_name_label       = optional(string)
    reverse_fqdn            = optional(string)
    idle_timeout_in_minutes = optional(number) # 4-30
    public_ip_prefix_id     = optional(string)

    ddos_protection_mode    = optional(string) # Enabled | VirtualNetworkInherited
    ddos_protection_plan_id = optional(string)

    tags = optional(map(string), {})
  })
}


variable "natgw_public_ip_assoc" {
  description = "Configuration object for NAT Gateway public IP associations."
  type = object({
    nat_gateway_id = string
    public_ip_id   = string
  })
}

variable "subnet_natgw_association" {
  type = object({
    subnet_id      = string
    nat_gateway_id = string
  })
  description = "Configuration for subnet public IP association"
}

variable "acr" {
  description = "Configuration object for Azure Container Registry"
  type = object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = string
    admin_enabled       = bool
    tags                = map(string)

    public_network_access_enabled = bool
    anonymous_pull_enabled        = optional(bool)
    data_endpoint_enabled         = optional(bool)
    zone_redundancy_enabled       = optional(bool)

    network_rule_set = optional(object({
      default_action             = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    }))

    georeplication_locations = optional(list(string))

    identity_type = optional(string)
    identity_ids  = optional(list(string))

    encryption_enabled      = optional(bool)
    encryption_key_vault_id = optional(string)
    encryption_key_name     = optional(string)
    encryption_key_version  = optional(string)

    retention_policy_enabled = optional(bool)
    retention_policy_days    = optional(number)

    export_policy_enabled     = optional(bool)
    quarantine_policy_enabled = optional(bool)
    trust_policy_type         = optional(string)
    trust_policy_enabled      = optional(bool)

    admin_username_output = optional(bool)
    admin_password_output = optional(bool)
  })
}

variable "staticwebapp" {
  type = object({
    name                               = string
    resource_group_name                = string
    location                           = string
    tags                               = optional(map(string))
    configuration_file_changes_enabled = optional(bool, true)
    preview_environments_enabled       = optional(bool, true)
    public_network_access_enabled      = optional(bool, true)
    sku_tier                           = optional(string, "Free")
    sku_size                           = optional(string, "Free")

    app_settings       = optional(map(string))
    basic_auth_enabled = bool
    basic_auth = optional(object({
      environments = optional(string)
      password     = optional(string)
    }), {})

    identity = optional(object({
      type = string
    }))
  })
}

variable "aks_node_config" {
  description = "Configuration for the aks-node module."
  type = object({
    kubernetes_cluster_id = string
    node_pool_name        = string
    vm_size               = string
    enable_auto_scaling   = bool
    node_count            = number
    min_count             = number
    max_count             = number
    mode                  = string
    vnet_subnet_id        = string
    availability_zones    = list(string)
    node_labels           = map(string)
    node_taints           = list(string)
    os_disk_size_gb       = number
    os_type               = string
    max_pods              = number
    orchestrator_version  = string
    tags                  = map(string)
  })
}

variable "federated_identity_credential" {
  description = "Configuration for the federated identity credential."
  type = object({
    name                = string
    issuer              = string
    resource_group_name = string
    parent_id           = string
    subject             = string
    audience            = list(string)
  })
  default = {
    name                = ""
    issuer              = ""
    resource_group_name = ""
    parent_id           = ""
    subject             = ""
    audience            = []
  }
}
