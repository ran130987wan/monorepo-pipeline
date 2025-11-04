variable "managed_identity" {                                      # Input variable for managed identity configuration
    description = "Combined configuration for the managed identity module"
    type = object({                                                # Complex object type definition
      umi_name                  =   string                         # Name of the user-assigned managed identity
      location                  =   string                         # Azure region where identity will be created
      resource_group_name       =   string                         # Resource group to contain the identity
      tags                      =   optional(map(string), {})      # Optional resource tags with empty map as default
    })
}