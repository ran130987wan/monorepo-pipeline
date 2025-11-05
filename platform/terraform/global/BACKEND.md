# Azure Backend Configuration

This document describes the Azure backend setup for Terraform state storage.

## Overview

The Terraform state is stored remotely in Azure Blob Storage for:
- **State locking** - Prevents concurrent modifications
- **Team collaboration** - Shared state across team members
- **State versioning** - Automatic versioning of state files
- **Security** - Encrypted at rest, no local state files

## Backend Resources

### Storage Account Details
- **Resource Group**: `terraform-state-rg`
- **Storage Account**: `tfstate2159128673`
- **Container**: `tfstate`
- **Location**: `centralus`
- **Subscription**: `f107fc08-072b-4963-8f72-e3550697e67f`

### State Files
- **Global Infrastructure**: `global.tfstate`

### Security Features
- ✅ TLS 1.2 minimum
- ✅ Blob encryption enabled
- ✅ Public blob access disabled
- ✅ Blob versioning enabled
- ✅ State locking enabled

## Setup Instructions

### Initial Setup

The backend has already been configured. If you need to set it up again:

```bash
cd /workspaces/monorepo-pipeline/platform/terraform/global
./setup-backend.sh
```

This script will:
1. Create the resource group
2. Create the storage account
3. Create the blob container
4. Enable blob versioning
5. Generate `backend-config.tfbackend` file

### Initialize Terraform with Backend

For new team members or fresh clones:

```bash
cd /workspaces/monorepo-pipeline/platform/terraform/global
terraform init -backend-config=backend-config.tfbackend
```

**Note**: You'll need to create the `backend-config.tfbackend` file or get it from a team member (it's in `.gitignore`).

### Migrate Existing State

If migrating from local state:

```bash
terraform init -backend-config=backend-config.tfbackend -migrate-state
```

## Backend Configuration File

The `backend-config.tfbackend` file contains:

```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate2159128673"
container_name       = "tfstate"
key                  = "global.tfstate"
```

**⚠️ Important**: This file is excluded from Git (`.gitignore`) and must be shared securely with team members.

## State Operations

### View Current State

```bash
terraform state list
```

### Pull State Locally

```bash
terraform state pull > state.json
```

### Unlock State (if locked)

If state is locked and operation failed:

```bash
# Get lock ID from error message
terraform force-unlock <lock-id>
```

### Verify Backend Configuration

```bash
terraform show
```

## Azure CLI Access

### View Storage Account

```bash
az storage account show \
  --name tfstate2159128673 \
  --resource-group terraform-state-rg
```

### List Blobs

```bash
az storage blob list \
  --container-name tfstate \
  --account-name tfstate2159128673 \
  --output table
```

### Download State Manually

```bash
az storage blob download \
  --container-name tfstate \
  --name global.tfstate \
  --file local-state-backup.tfstate \
  --account-name tfstate2159128673
```

## Backup and Recovery

### Automatic Backups

- **Blob Versioning**: Enabled - previous versions retained automatically
- **Access**: Via Azure Portal > Storage Account > Containers > tfstate > global.tfstate > Versions

### Manual Backup

```bash
# Download current state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
```

### Restore from Backup

```bash
# Push state from backup file
terraform state push backup-YYYYMMDD-HHMMSS.tfstate
```

## Multi-Environment Setup

For additional environments, update the state key:

### Development
```hcl
key = "dev/global.tfstate"
```

### Staging
```hcl
key = "stage/global.tfstate"
```

### Production
```hcl
key = "prod/global.tfstate"
```

## Troubleshooting

### Error: Backend Configuration Changed

```bash
terraform init -reconfigure -backend-config=backend-config.tfbackend
```

### Error: Failed to Acquire State Lock

**Cause**: Another process is running, or previous operation failed

**Solution**:
1. Wait for other operations to complete
2. If stuck, force unlock: `terraform force-unlock <lock-id>`

### Error: Authentication Failed

```bash
# Re-login to Azure
az login
az account set --subscription f107fc08-072b-4963-8f72-e3550697e67f
```

### Error: Storage Account Not Found

Verify resources exist:
```bash
az group show --name terraform-state-rg
az storage account show --name tfstate2159128673 --resource-group terraform-state-rg
```

## Security Best Practices

1. **Access Control**
   - Use Azure RBAC to control who can access state
   - Minimum required: `Storage Blob Data Contributor`

2. **Network Security**
   - Consider enabling storage firewall rules
   - Use private endpoints for production

3. **Encryption**
   - State is encrypted at rest automatically
   - Consider customer-managed keys for compliance

4. **State File Protection**
   - Never commit state files to Git
   - Never share state files via insecure channels
   - State contains sensitive resource IDs and data

5. **Audit Logging**
   - Enable diagnostic logs on storage account
   - Monitor access via Azure Monitor

## Cost Optimization

Current configuration uses:
- **SKU**: Standard_LRS (Locally Redundant Storage)
- **Cost**: ~$0.02/GB/month + operations

To reduce costs in non-production:
- Use LRS (current)
- Clean up old state versions periodically
- Consider lifecycle management policies

## References

- [Terraform Azure Backend Documentation](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
- [Azure Storage Security](https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide)
- [State Locking](https://www.terraform.io/docs/language/state/locking.html)
