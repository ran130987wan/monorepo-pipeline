variable "resource_groups" {
  description = "List of configuration objects for the Resource Group module."
  type = list(object({
    name        = string
    location    = string
    locks       = bool
    tags        = optional(map(string), {})
  }))
  default = []
}