variable "resource_groups" {
  description = "Lis of coonfiguration objects for the Resource Group module."
  type = list(object({
    name        = string
    location    = string
    locks       = bool
    tags        = optional(map(string), {})
  }))
  default = []
}