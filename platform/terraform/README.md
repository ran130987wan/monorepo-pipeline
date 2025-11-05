# Terraform Infrastructure - Monorepo Pipeline

This directory contains Terraform configurations for managing Azure infrastructure across multiple environments.

## 📚 Documentation

- **[USAGE_GUIDE.md](USAGE_GUIDE.md)** - Complete step-by-step execution guide for users
- **[CODE_GUIDE.md](CODE_GUIDE.md)** - Detailed code structure and implementation guide
- **[BACKEND.md](global/BACKEND.md)** - Azure backend configuration and management

## Directory Structure

```
platform/terraform/
├── global/                  # Global shared resources
│   ├── main.tf             # Main configuration with module calls
│   ├── variables.tf        # Variable definitions
│   ├── locals.tf           # Local values and computed configurations
│   ├── providers.tf        # Provider configurations
│   └── output.tf           # Output definitions
├── envs/                   # Environment-specific configurations
│   └── dev/
│       └── global-vars/
│           └── main.tfvars # Development environment variables
└── modules/                # Reusable Terraform modules
    ├── resource-group/     # Resource group module
    ├── managed-identity/   # User-assigned managed identity module
    └── federated-identity-credential/  # Federated identity credential module
```

## Prerequisites

### Required Tools

1. **Terraform** (v1.13.4+)
   ```bash
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt-get update && sudo apt-get install -y terraform
   ```

2. **Azure CLI** (v2.79.0+)
   ```bash
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   ```

### Azure Authentication

Login to Azure before running Terraform:

```bash
# Interactive login
az login

# Device code flow (for dev containers/SSH)
az login --use-device-code

# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "<subscription-id>"
```

## Modules

### 1. Resource Group Module
Creates Azure resource groups with optional management locks.

**Resources Created:**
- `azurerm_resource_group` - Azure resource groups
- `azurerm_management_lock` - Management locks (CanNotDelete)

**Variables:**
- `resource_groups` - List of resource group configurations

### 2. Managed Identity Module
Creates user-assigned managed identities for Azure services.

**Resources Created:**
- `azurerm_user_assigned_identity` - User-assigned managed identity

**Variables:**
- `managed_identity` - Managed identity configuration

**Outputs:**
- `managed_identity_id` - Resource ID
- `managed_identity_obj_id` - Principal (Object) ID
- `managed_identity_client_id` - Client ID

### 3. Federated Identity Credential Module
Creates federated identity credentials for OIDC authentication (e.g., GitHub Actions).

**Resources Created:**
- `azurerm_federated_identity_credential` - Federated identity credential

**Variables:**
- `federated_identity_credential` - Credential configuration

## Deployment

### Global Resources

Global resources are shared across all environments and include:
- 8 Resource Groups (container, web, security, data, monitoring, network, platform, integration)
- User-Assigned Managed Identity

#### Initialize Terraform

```bash
cd /workspaces/monorepo-pipeline/platform/terraform/global
terraform init
```

#### Plan Changes

```bash
# Using dev environment variables
terraform plan -var-file=../envs/dev/global-vars/main.tfvars

# Save plan to file
terraform plan -var-file=../envs/dev/global-vars/main.tfvars -out=tfplan
```

#### Apply Changes

```bash
# Apply with auto-approve
terraform apply -var-file=../envs/dev/global-vars/main.tfvars -auto-approve

# Apply from saved plan
terraform apply tfplan
```

#### View Outputs

```bash
terraform output
```

#### Destroy Resources

```bash
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars
```

## Environment Configuration

### Development Environment

Configuration file: `envs/dev/global-vars/main.tfvars`

**Resource Naming Convention:**
- Format: `{compact_prefix}-{resource_type}-{suffix}-{environment}`
- Example: `vdccpadm-integration-rg-dev`

**Resources Created:**
- Resource Groups:
  - `vdccpadm-container-rg-dev`
  - `vdccpadm-web-rg-dev`
  - `vdccpadm-security-rg-dev`
  - `vdccpadm-data-rg-dev`
  - `vdccpadm-monitoring-rg-dev`
  - `vdccpadm-network-rg-dev`
  - `vdccpadm-platform-rg-dev`
  - `vdccpadm-integration-rg-dev`
- Managed Identity: `vdccpadm-mi-dev`

**Location:** `centralus`

**Tags:**
- `product`: vdc-cp-admin
- `environment`: dev
- `source`: terraform

## State Management

Currently using local state file:
- `global/terraform.tfstate`
- `global/terraform.tfstate.backup`

### Recommended: Migrate to Remote State

For production use, migrate to Azure Storage backend:

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "global.tfstate"
  }
}
```

## Troubleshooting

### Common Issues

1. **ResourceGroupNotFound Error**
   - Ensure resource group names match between modules
   - Check `compact_prefix` consistency in tfvars

2. **Authentication Error**
   - Run `az login` to authenticate
   - Verify subscription with `az account show`

3. **Provider Version Conflicts**
   - Run `terraform init -upgrade` to update providers

4. **State Lock Issues**
   - If using remote state, check for orphaned locks
   - Force unlock with `terraform force-unlock <lock-id>`

### Validate Configuration

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Check for issues
terraform plan
```

## Best Practices

1. **Always run `terraform plan` before `apply`**
2. **Use version control for state files** (or remote backend)
3. **Never commit `.tfvars` files with secrets** to version control
4. **Use consistent naming conventions** across environments
5. **Enable resource locks** for production environments
6. **Tag all resources** for cost tracking and organization
7. **Review and test in dev** before deploying to prod

## Next Steps

### Add Environment-Specific Resources

Create environment-specific configurations in `envs/{env}/`:

```bash
# Create stage environment
mkdir -p envs/stage/global-vars
cp envs/dev/global-vars/main.tfvars envs/stage/global-vars/main.tfvars
# Update values for stage environment

# Create prod environment
mkdir -p envs/prod/global-vars
cp envs/dev/global-vars/main.tfvars envs/prod/global-vars/main.tfvars
# Update values for prod environment
```

### Enable Additional Modules

Uncomment modules in `global/main.tf` as needed:
- VNet and Subnet
- NAT Gateway
- Public IP
- AKS Cluster
- ACR (Azure Container Registry)
- Static Web App

### Add Federated Identity for GitHub Actions

Add to `global/main.tf`:

```hcl
module "federated_identity_credential" {
  source = "../modules/federated-identity-credential"
  
  federated_identity_credential = {
    name                = "github-actions-oidc"
    resource_group_name = "vdccpadm-integration-rg-dev"
    parent_id           = module.managed_identity.managed_identity_id
    issuer              = "https://token.actions.githubusercontent.com"
    subject             = "repo:ran130987wan/monorepo-pipeline:ref:refs/heads/main"
    audience            = ["api://AzureADTokenExchange"]
  }
  
  depends_on = [module.managed_identity]
}
```

## Support

For issues or questions:
- Check the [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- Review Terraform logs: `export TF_LOG=DEBUG`
- Verify Azure permissions and role assignments

## Version History

- **v1.0.0** - Initial setup with resource groups and managed identity
