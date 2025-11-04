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
  required_version = "= 1.12.2" # Ensure your Terraform version is compatible
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  resource_provider_registrations = "none"
  subscription_id                 = "e3bc3d5d-8026-43f9-b540-98eed3a27817"
}

provider "azurerm" {
  features {}
  alias                           = "platform"
  resource_provider_registrations = "none"
  subscription_id                 = "c8d528f7-bee5-4164-bcd1-f84e9d444dcc"
}

# provider "azurerm" {
#   features {}
#   alias                           = "platform"
#   resource_provider_registrations = "none"
#   subscription_id                 = "#{PLATFORM-SUBSCRIPTION-ID}#"
# }

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "#{TF_BACKEND_AZ_STORAGE_ACCOUNT_RG_NAME}#" # The resource group name 
#     storage_account_name = "#{TF_BACKEND_AZ_STORAGE_ACCOUNT_NAME}#"    # The name of your Storage Account
#     container_name       = "#{TF_BACKEND_AZ_STORAGE_CONTAINER_NAME}#"  # The container where the state file will be stored
#     key                  = "#{TF_BACKEND_AZ_STORAGE_BLOB_KEY}#"        # The name of the state file
#   }
# }

terraform {
  backend "azurerm" {
    resource_group_name  = "vdc-entra-admin-cus-bootstrap-rg-dev" # The resource group name
    storage_account_name = "vdcentraadmsacusdevtfbe"              # The name of your Storage Account
    container_name       = "tfstateentraadmin"                    # The container where the state file will be stored
    key                  = "dev-global.terraform.tfstate"         # The name of the state file
  }
}

# data "azurerm_subscription" "env" {
#   provider = azurerm.dev
# }

# provider "azurerm" {
#   features {}
#   alias                           = "dev"
#   resource_provider_registrations = "none"
#   subscription_id                 = "e3bc3d5d-8026-43f9-b540-98eed3a27817"
# }
