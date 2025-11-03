variable "managed_identity" {
    description = "Combined configuration for the managed identity module"
    type = object({
      umi_name                  =   string
      location                  =   string
      resource_group_name       =   string
      tags                      =   optional(map(string), {})
    })
}