output "federated_identity_subjects" {                                          # Output variable exposing the subject claim
    value = azurerm_federated_identity_credential.federated_identity.subject # Returns the subject identifier used for authentication
}