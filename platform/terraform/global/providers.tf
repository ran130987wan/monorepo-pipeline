# ============================================================================
# Provider Configuration
# ============================================================================
# Defines required providers (Azure RM & AD) and remote state backend
# State is stored in Azure Storage Account for team collaboration
# ============================================================================

terraform {
  # Required provider versions for Azure resources and Azure AD
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.3"
    }
  }
  required_version = ">= 1.12.0"

  # Remote state backend - stores terraform.tfstate in Azure Storage
  # Enables state locking and team collaboration
  backend "azurerm" {
    resource_group_name  = "vdc-cp-admin-cus-bootstrap-rg-dev"
    storage_account_name = "vdccpadmsacusdevtfbe1"
    container_name       = "tfstatecpadmin"
    key                  = "dev-global.terraform.tfstate"
  }
}

# Azure Resource Manager provider configuration
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true # Safety: prevents accidental RG deletion
    }
  }
  resource_provider_registrations = "none"                         # Don't auto-register providers
  subscription_id                 = "f107fc08-072b-4963-8f72-e3550697e67f" # Target subscription
}



