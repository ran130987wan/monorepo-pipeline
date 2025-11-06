# ============================================================================
# Variable Definitions
# ============================================================================
# Input variables for global configuration and Azure region mapping
# Values are provided via tfvars files in the envs/ directory
# ============================================================================

# Global configuration object containing naming standards and metadata
# Used across all resources for consistent naming and tagging
variable "global_config" {
  description = "Global configuration for resource naming and tagging"
  type = object({
    prefix         = string       # Full prefix (e.g., "vdc-cp-admin")
    compact_prefix = string       # Compact prefix for resources with length limits (e.g., "vdccpadm")
    environment    = string       # Environment name (dev/stage/prod)
    location       = string       # Azure region (e.g., "centralus")
    region_code    = string       # Short region code (e.g., "cus")
    tags           = map(string)  # Common tags applied to all resources
  })
}

# Lookup table for converting full Azure region names to short codes
# Used for creating compact resource names that meet length constraints
variable "azure_region_map" {
  description = "Mapping of Azure region names to short codes"
  type        = map(string)
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