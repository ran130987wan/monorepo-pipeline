terraform {                            # Terraform configuration block
  required_version = ">=1.12.0"        # Minimum Terraform version required

  required_providers {                 # Declare required provider plugins
    azurerm = {                        # Azure Resource Manager provider
      source = "hashicorp/azurerm"     # Provider source location in registry
      version = "~> 4.0"               # Allow 4.x versions (4.0 to 4.999)
    }
  }
}