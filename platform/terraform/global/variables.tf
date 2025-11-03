variable "global_config" {
    type = object({
        prefix                          =   string
        compact_prefix                  =   string
        environment                     =   string
        location                        =   string
        region_code                     =   string
        tags                            =   map(string)
   })
}

variable "azure_region_map" {
    type = map(string)
    default = {
        "centralus"        =   "cus"
        "eastus"           =   "eus"
        "eastus2"          =   "eus2"
        "westus"           =   "wus"
        "westus2"          =   "wus2"
        "northcentralus"   =   "ncus"
        "southcentralus"   =   "scus"
        "northeurope"      =   "neu"
        "westeurope"       =   "weu"
        "uksouth"          =   "uks"
        "ukwest"           =   "ukw"
        "southeastasia"    =   "seas"
        "eastasia"         =   "eas"
        "australiaeast"    =   "aue"
        "australiasoutheast"=  "ause"
    }
}

/*--------------------------------------------------------------------------------------------------*/
/*                          Global Configuration Variables                                          */
/*--------------------------------------------------------------------------------------------------*/
variable "resource_groups" {
  description = "Lis of coonfiguration objects for the Resource Group module."
  type = list(object({
    name        = string
    location    = string
    locks       = bool
    tags        = optional(map(string), {})
  }))
  default = [
    {
        name = ""
        location = ""
        locks = false
        tags = {}
    }
  ]
}

variable "managed_identity" {
    description = "Combined configuration for the managed identity module"
    type = object({
      umi_name                  =   string
      location                  =   string
      resource_group_name       =   string
      tags                      =   optional(map(string), {})
    })
}