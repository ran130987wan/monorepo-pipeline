resource "azurerm_federated_identity_credential" "federated_identity" {
  name                = var.federated_identity_credential.name                # Name of the federated identity credential
  resource_group_name = var.federated_identity_credential.resource_group_name # Resource group containing the managed identity
  parent_id           = var.federated_identity_credential.parent_id           # ID of the parent managed identity
  audience            = var.federated_identity_credential.audience            # List of audiences that can appear in the external token
  issuer              = var.federated_identity_credential.issuer              # URL of the external identity provider (e.g., GitHub Actions)
  subject             = var.federated_identity_credential.subject             # Subject claim from the external token to match
}