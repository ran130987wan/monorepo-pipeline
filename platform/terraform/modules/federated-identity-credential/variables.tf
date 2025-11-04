variable "federated_identity_credential" {                                        # Input variable for federated identity configuration
  description = "Configuration object for the Federated Identity Credential module"
  type = object({                                                                 # Complex object type definition
    name                          = string                                        # Name of the federated credential
    application_object_id         = string                                        # Azure AD application object ID
    issuer                        = string                                        # External identity provider URL (e.g., GitHub)
    resource_group_name           = string                                        # Resource group containing the managed identity
    parent_id                     = string                                        # Managed identity resource ID
    subject                       = string                                        # Subject claim pattern to match (e.g., repo:org/name)
    audience                      = list(string)                                  # List of allowed audiences in the token
    claims_matching_expressions   = string                                        # Additional claim matching expressions
  })
  
  default = {                                                                     # Default values when variable not provided
    name                          = ""                                            # Empty string default for name
    application_object_id         = ""                                            # Empty string default for app ID
    issuer                        = ""                                            # Empty string default for issuer
    resource_group_name           = ""                                            # Empty string default for resource group
    parent_id                     = ""                                            # Empty string default for parent ID
    subject                       = ""                                            # Empty string default for subject
    audience                      = []                                            # Empty list default for audience
    claims_matching_expressions   = null                                          # Null default for claims expressions
  }
}