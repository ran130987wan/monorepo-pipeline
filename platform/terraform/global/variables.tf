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

variable "managed_identity" {
  description = "Combined configuration for the managed identity module."
  type = object({
    umi_name            = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })
}