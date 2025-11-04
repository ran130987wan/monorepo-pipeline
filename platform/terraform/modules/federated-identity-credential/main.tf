resource "azurerm_federated_identity_credential" "federated_identity" {
  name                = var.federated_identity_credential.name
  resource_group_name = var.federated_identity_credential.resource_group_name
  parent_id           = var.federated_identity_credential.parent_id
  audience            = var.federated_identity_credential.audience
  issuer              = var.federated_identity_credential.issuer
  subject             = var.federated_identity_credential.subject
}