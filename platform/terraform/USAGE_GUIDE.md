# Terraform Global Infrastructure - User Guide

This guide walks you through executing the Terraform configuration for global infrastructure deployment on Azure.

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Initial Setup](#initial-setup)
- [Azure Authentication](#azure-authentication)
- [Backend Configuration](#backend-configuration)
- [Deployment Steps](#deployment-steps)
- [Managing Resources](#managing-resources)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Prerequisites

### Required Software

1. **Terraform CLI** (v1.13.4 or higher)
2. **Azure CLI** (v2.79.0 or higher)
3. **Git** (for version control)
4. **Bash shell** (Linux/macOS/WSL)

### Azure Requirements

- Active Azure subscription
- Appropriate permissions to create resources
- Azure CLI access

---

## Initial Setup

### Step 1: Install Required Tools

#### Install Terraform

```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt-get update
sudo apt-get install -y terraform

# Verify installation
terraform version
```

#### Install Azure CLI

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az version
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/ran130987wan/monorepo-pipeline.git
cd monorepo-pipeline/platform/terraform/global
```

---

## Azure Authentication

### Step 1: Login to Azure

**Option A: Interactive Login**
```bash
az login
```
This opens a browser window for authentication.

**Option B: Device Code Flow** (for dev containers/SSH)
```bash
az login --use-device-code
```
Follow the instructions to complete authentication.

### Step 2: Select Subscription

```bash
# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription "<subscription-id>"

# Verify current subscription
az account show
```

---

## Backend Configuration

### Step 1: Create Azure Backend

The backend stores Terraform state remotely in Azure Blob Storage.

```bash
cd /workspaces/monorepo-pipeline/platform/terraform/global

# Run the setup script
chmod +x setup-backend.sh
./setup-backend.sh
```

**What this creates:**
- Resource Group: `terraform-state-rg`
- Storage Account: `tfstate<random-numbers>`
- Blob Container: `tfstate`
- Configuration file: `backend-config.tfbackend`

### Step 2: Review Backend Configuration

```bash
# View the generated backend config
cat backend-config.tfbackend
```

Expected output:
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate2159128673"
container_name       = "tfstate"
key                  = "global.tfstate"
```

### Step 3: Initialize Terraform with Backend

```bash
# Initialize Terraform
terraform init -backend-config=backend-config.tfbackend
```

**For existing state migration:**
```bash
terraform init -backend-config=backend-config.tfbackend -migrate-state
```

---

## Deployment Steps

### Step 1: Review Configuration Variables

Edit the environment variables file:
```bash
cd /workspaces/monorepo-pipeline/platform/terraform
vim envs/dev/global-vars/main.tfvars
```

**Key variables:**
- `global_config` - Global settings (prefix, location, tags)
- `managed_identity` - Managed identity configuration

**Example:**
```hcl
global_config = {
  prefix         = "vdc-cp-admin"
  compact_prefix = "vdccpadm"
  environment    = "dev"
  location       = "centralus"
  region_code    = "cus"
  tags = {
    product     = "vdc-cp-admin"
    environment = "dev"
    source      = "terraform"
  }
}

managed_identity = {
  umi_name            = "vdccpadm-mi-dev"
  resource_group_name = "vdccpadm-integration-rg-dev"
  location            = "centralus"
  tags = {
    product     = "vdc-cp-admin"
    environment = "dev"
    source      = "terraform"
  }
}
```

### Step 2: Validate Configuration

```bash
cd /workspaces/monorepo-pipeline/platform/terraform/global

# Format code
terraform fmt -recursive

# Validate syntax
terraform validate
```

### Step 3: Plan Changes

```bash
# Generate execution plan
terraform plan -var-file=../envs/dev/global-vars/main.tfvars

# Save plan to file (optional)
terraform plan -var-file=../envs/dev/global-vars/main.tfvars -out=tfplan
```

**Review the plan carefully:**
- Check resource names
- Verify locations
- Confirm tags
- Review resource counts

### Step 4: Apply Changes

**Option A: Interactive Apply**
```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars
```
Type `yes` when prompted to confirm.

**Option B: Auto-Approve** (use with caution)
```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars -auto-approve
```

**Option C: Apply from Saved Plan**
```bash
terraform apply tfplan
```

### Step 5: Verify Deployment

```bash
# List all resources in state
terraform state list

# View outputs
terraform output

# Check specific resource
terraform state show module.managed_identity.azurerm_user_assigned_identity.umi
```

**Verify in Azure Portal:**
1. Navigate to Azure Portal
2. Check Resource Groups
3. Verify Managed Identity

**Verify via Azure CLI:**
```bash
# List resource groups
az group list --query "[?contains(name, 'vdccpadm')].{Name:name, Location:location}" --output table

# View managed identity
az identity show --name vdccpadm-mi-dev --resource-group vdccpadm-integration-rg-dev
```

---

## Managing Resources

### View Current State

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show <resource-address>

# Pull state locally
terraform state pull > state-backup.json
```

### Update Resources

```bash
# Modify tfvars file
vim ../envs/dev/global-vars/main.tfvars

# Plan changes
terraform plan -var-file=../envs/dev/global-vars/main.tfvars

# Apply changes
terraform apply -var-file=../envs/dev/global-vars/main.tfvars
```

### Refresh State

```bash
# Refresh state from Azure
terraform refresh -var-file=../envs/dev/global-vars/main.tfvars
```

### Destroy Resources

⚠️ **Warning: This will delete all resources!**

```bash
# Plan destruction
terraform plan -destroy -var-file=../envs/dev/global-vars/main.tfvars

# Destroy all resources
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars
```

Type `yes` when prompted to confirm.

**Auto-approve (use with extreme caution):**
```bash
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars -auto-approve
```

---

## Troubleshooting

### Common Issues

#### 1. Authentication Failed

**Error:** `unable to build authorizer for Resource Manager API`

**Solution:**
```bash
az login
az account set --subscription "<subscription-id>"
```

#### 2. Resource Name Conflict

**Error:** `ResourceGroupNotFound` or naming mismatch

**Solution:**
- Ensure `compact_prefix` is consistent across all resource names
- Check `envs/dev/global-vars/main.tfvars` for naming consistency

#### 3. State Lock

**Error:** `Error acquiring the state lock`

**Cause:** Another process is running or previous operation failed

**Solution:**
```bash
# Wait for other operations to complete, or force unlock
terraform force-unlock <lock-id>
```

#### 4. Backend Configuration Changed

**Error:** `Backend configuration changed`

**Solution:**
```bash
terraform init -reconfigure -backend-config=backend-config.tfbackend
```

#### 5. Provider Version Conflicts

**Error:** `Provider version conflicts`

**Solution:**
```bash
terraform init -upgrade
```

### Debug Mode

Enable detailed logging:
```bash
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform-debug.log

terraform plan -var-file=../envs/dev/global-vars/main.tfvars
```

### Verify Azure Resources

```bash
# Check if resource group exists
az group show --name vdccpadm-integration-rg-dev

# List all resource groups with prefix
az group list --query "[?contains(name, 'vdccpadm')]" --output table

# Check storage account for backend
az storage account show --name tfstate2159128673 --resource-group terraform-state-rg
```

---

## Best Practices

### 1. Version Control

✅ **DO:**
- Commit `.tf` files
- Commit `.gitignore`
- Commit README and documentation

❌ **DON'T:**
- Commit `.tfstate` files
- Commit `.tfvars` files with secrets
- Commit `backend-config.tfbackend`
- Commit `.terraform` directory

### 2. State Management

✅ Always use remote backend (Azure Storage)
✅ Enable state locking
✅ Enable versioning on storage account
✅ Regular state backups

### 3. Planning

✅ Always run `terraform plan` before `apply`
✅ Review changes carefully
✅ Save plans for audit trail
✅ Test in dev before prod

### 4. Naming Conventions

✅ Use consistent naming patterns
✅ Include environment in resource names
✅ Use `compact_prefix` for resources with length limits
✅ Tag all resources appropriately

### 5. Security

✅ Use managed identities
✅ Enable encryption at rest
✅ Use private endpoints for production
✅ Implement RBAC for state storage
✅ Never commit credentials

### 6. Team Collaboration

✅ Share `backend-config.tfbackend` securely
✅ Document changes in commit messages
✅ Use pull requests for reviews
✅ Communicate destructive changes

---

## Quick Reference Commands

### Initialization
```bash
terraform init -backend-config=backend-config.tfbackend
```

### Plan
```bash
terraform plan -var-file=../envs/dev/global-vars/main.tfvars
```

### Apply
```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars
```

### Destroy
```bash
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars
```

### State Management
```bash
terraform state list
terraform state show <resource>
terraform state pull > backup.json
```

### Validation
```bash
terraform fmt -recursive
terraform validate
```

### Backend Verification
```bash
az storage blob list --container-name tfstate --account-name <storage-account> --output table
```

---

## Getting Help

### Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/)

### Repository Documentation
- `README.md` - Project overview
- `CODE_GUIDE.md` - Code structure and implementation details
- `BACKEND.md` - Backend configuration details

### Support
For issues or questions:
1. Check the Troubleshooting section
2. Review Terraform logs
3. Verify Azure permissions
4. Contact your team lead

---

## Appendix

### Resource Naming Pattern

```
{compact_prefix}-{resource_type}-{suffix}-{environment}
```

**Examples:**
- Resource Group: `vdccpadm-integration-rg-dev`
- Managed Identity: `vdccpadm-mi-dev`

### Tags Structure

```hcl
tags = {
  product     = "vdc-cp-admin"
  environment = "dev|stage|prod"
  source      = "terraform"
}
```

### File Structure

```
platform/terraform/
├── global/                     # Global shared resources
│   ├── main.tf                # Module calls
│   ├── variables.tf           # Variable definitions
│   ├── locals.tf              # Local values
│   ├── providers.tf           # Provider config + backend
│   ├── output.tf              # Output definitions
│   ├── setup-backend.sh       # Backend setup script
│   ├── backend-config.tfbackend  # Backend config (not in Git)
│   ├── BACKEND.md             # Backend documentation
│   └── .terraform.lock.hcl    # Provider lock file
├── envs/                      # Environment configs
│   └── dev/
│       └── global-vars/
│           └── main.tfvars    # Dev environment vars
└── modules/                   # Reusable modules
    ├── resource-group/
    ├── managed-identity/
    └── federated-identity-credential/
```

---

**Last Updated:** November 5, 2025
**Version:** 1.0.0
