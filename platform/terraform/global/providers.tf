terraform {
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
  required_version = ">= 1.12.0" # Ensure your Terraform version is compatible

  # Configure remote state backend in Azure Storage
  backend "azurerm" {
    resource_group_name  = "vdc-cp-admin-cus-bootstrap-rg-dev"
    storage_account_name = "vdccpadmsacusdevtfbe1"
    container_name       = "tfstatecpadmin"
    key                  = "dev-global.terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = "f107fc08-072b-4963-8f72-e3550697e67f"
}



