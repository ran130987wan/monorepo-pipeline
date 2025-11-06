# Terraform Infrastructure Deployment Guide

This guide provides step-by-step instructions for deploying Azure infrastructure using Terraform from your local machine.

## 📋 Prerequisites

Before you begin, ensure you have the following installed on your laptop:

### Required Tools
- **Terraform** (>= 1.12.0)
  - Download: https://developer.hashicorp.com/terraform/install
  - Verify: `terraform version`

- **Azure CLI** (>= 2.0)
  - Download: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
  - Verify: `az --version`

- **Git**
  - Download: https://git-scm.com/downloads
  - Verify: `git --version`

### Azure Requirements
- Active Azure subscription
- Contributor or Owner permissions on the target subscription
- Azure Storage Account for remote state backend (already configured)

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ran130987wan/monorepo-pipeline.git
cd monorepo-pipeline/platform/terraform/global
```

### 2. Authenticate to Azure

Login to your Azure account:

```bash
az login
```

For headless/remote environments, use device code authentication:

```bash
az login --use-device-code
```

Verify you're logged in to the correct subscription:

```bash
az account show
```

If you need to switch subscriptions:

```bash
az account list --output table
az account set --subscription "f107fc08-072b-4963-8f72-e3550697e67f"
```

---

## 📁 Project Structure

```
platform/terraform/
├── docs/
│   └── README.md              # This file
├── envs/
│   └── dev/
│       └── global-vars/
│           └── main.tfvars    # Environment-specific variables
└── global/
    ├── providers.tf           # Provider and backend configuration
    ├── variables.tf           # Input variable definitions
    ├── locals.tf              # Local computed values
    ├── main.tf                # Main resource definitions
    └── output.tf              # Output values
```

---

## 🔧 Configuration Files Explained

### `providers.tf`
- Defines Azure provider versions (AzureRM ~> 4.0, AzureAD ~> 3.3)
- Configures remote state backend in Azure Storage
- Sets subscription and feature flags

### `variables.tf`
- Defines input variables (global_config, azure_region_map)
- Specifies variable types and descriptions

### `locals.tf`
- Maps resource group types (container, web, data, security, etc.)
- Computes naming patterns: `{prefix}-{workload}-rg-{env}`
- Enables conditional locks for prod/stage environments

### `main.tf`
- Calls the resource-group module from external Git repository
- Creates 8 resource groups based on workload types

### `output.tf`
- Exports resource group IDs and names
- Provides outputs for use in downstream modules

---

## 🏗️ Deployment Steps

### Step 1: Initialize Terraform

Initialize the Terraform working directory and download required providers:

```bash
cd /path/to/monorepo-pipeline/platform/terraform/global
terraform init
```

**Expected Output:**
```
Initializing the backend...
Successfully configured the backend "azurerm"!
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 2: Validate Configuration

Validate the Terraform configuration syntax:

```bash
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### Step 3: Format Code (Optional)

Format Terraform files to canonical style:

```bash
terraform fmt
```

### Step 4: Review Execution Plan

Generate and review the execution plan:

```bash
terraform plan -var-file=../envs/dev/global-vars/main.tfvars
```

**What to Review:**
- Number of resources to be added (should be 8 resource groups)
- Resource names match your naming convention
- Tags are correctly applied
- No unexpected changes or deletions

### Step 5: Apply Configuration

Deploy the infrastructure:

```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars
```

You'll be prompted to confirm. Type `yes` to proceed.

**For automated/CI workflows, use auto-approve:**
```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars -auto-approve
```

**Expected Output:**
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
container_rg_id = "/subscriptions/.../resourceGroups/vdccpadm-container-rg-dev"
data_rg_id = "/subscriptions/.../resourceGroups/vdccpadm-data-rg-dev"
...
```

### Step 6: Verify Deployment

Check the created resources in Azure:

```bash
# List all resource groups in the subscription
az group list --query "[?starts_with(name, 'vdccpadm')].{Name:name, Location:location, Tags:tags}" --output table
```

Or verify using Terraform:

```bash
terraform show
```

---

## 🔍 View Outputs

Display output values:

```bash
terraform output
```

Get specific output:

```bash
terraform output container_rg_id
terraform output resource_group_names
```

---

## 🔄 Updating Infrastructure

To modify the infrastructure:

1. **Edit the configuration files** (e.g., add a new resource group in `locals.tf`)
2. **Review changes:**
   ```bash
   terraform plan -var-file=../envs/dev/global-vars/main.tfvars
   ```
3. **Apply changes:**
   ```bash
   terraform apply -var-file=../envs/dev/global-vars/main.tfvars
   ```

---

## 🗑️ Destroying Resources

To destroy all Terraform-managed resources:

```bash
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars
```

Confirm by typing `yes` when prompted.

**For automated destruction:**
```bash
terraform destroy -var-file=../envs/dev/global-vars/main.tfvars -auto-approve
```

⚠️ **Warning:** This will permanently delete all 8 resource groups and their contents!

---

## 🎯 What Gets Deployed

This Terraform configuration creates the following Azure resource groups:

| Resource Group | Purpose | Example Name |
|----------------|---------|--------------|
| Container | Container services (AKS, ACI) | `vdccpadm-container-rg-dev` |
| Web | Web apps and frontend services | `vdccpadm-web-rg-dev` |
| Data | Data services (SQL, Cosmos) | `vdccpadm-data-rg-dev` |
| Security | Security tools (Key Vault) | `vdccpadm-security-rg-dev` |
| Monitoring | Observability (Log Analytics) | `vdccpadm-monitoring-rg-dev` |
| Network | Networking (VNet, NSG) | `vdccpadm-network-rg-dev` |
| Platform | Platform services (APIM) | `vdccpadm-platform-rg-dev` |
| Integration | Integration services (Functions) | `vdccpadm-integration-rg-dev` |

**Common Tags Applied:**
- `environment`: `dev`
- `product`: `vdc-cp-admin`
- `source`: `terraform`

---

## 🔐 State Management

### Remote State Backend

State is stored remotely in Azure Storage:
- **Resource Group:** `vdc-cp-admin-cus-bootstrap-rg-dev`
- **Storage Account:** `vdccpadmsacusdevtfbe1`
- **Container:** `tfstatecpadmin`
- **State File:** `dev-global.terraform.tfstate`

### Why Remote State?
- **Team Collaboration:** Multiple team members can work on the same infrastructure
- **State Locking:** Prevents concurrent modifications
- **Security:** State is encrypted at rest in Azure Storage
- **Versioning:** Azure Storage can enable blob versioning for state history

### Viewing State

```bash
# Show current state
terraform show

# List resources in state
terraform state list

# Show specific resource
terraform state show module.resource_groups.azurerm_resource_group.this[\"vdccpadm-container-rg-dev\"]
```

---

## 🛠️ Troubleshooting

### Issue: "Error: Backend initialization required"

**Solution:** Run `terraform init`

### Issue: "Error: unable to build authorizer for Resource Manager API"

**Solution:** You're not logged into Azure. Run `az login`

### Issue: "Error: Insufficient permissions"

**Solution:** Ensure your Azure account has Contributor or Owner role on the subscription

### Issue: State lock timeout

**Solution:** If a previous operation crashed, manually release the lock:
```bash
terraform force-unlock <LOCK_ID>
```

### Issue: Module not found

**Solution:** Re-initialize to download modules:
```bash
terraform init -upgrade
```

### Issue: Provider version conflict

**Solution:** Update provider versions:
```bash
terraform init -upgrade
```

---

## 📝 Environment-Specific Deployments

### Development Environment

```bash
terraform apply -var-file=../envs/dev/global-vars/main.tfvars
```

### Staging Environment (when created)

```bash
terraform apply -var-file=../envs/stage/global-vars/main.tfvars
```

### Production Environment (when created)

```bash
terraform apply -var-file=../envs/prod/global-vars/main.tfvars
```

---

## 🔒 Best Practices

1. **Always run `terraform plan` first** - Review changes before applying
2. **Use version control** - Commit changes to Git before applying
3. **Use workspaces or separate state files** - For different environments
4. **Enable state locking** - Already configured via Azure Storage
5. **Use remote state** - Already configured for team collaboration
6. **Tag all resources** - Already implemented via global_config
7. **Use modules** - Already using external module for resource groups
8. **Validate before commit** - Run `terraform validate` and `terraform fmt`
9. **Document changes** - Update this README when adding new resources
10. **Review outputs** - Use outputs to reference resources in other modules

---

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure CLI Reference](https://docs.microsoft.com/en-us/cli/azure/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Azure Naming Conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)

---

## 🆘 Support

For issues or questions:
- Check the troubleshooting section above
- Review Terraform plan output carefully
- Check Azure Portal for resource status
- Review Terraform documentation
- Contact the infrastructure team

---

## 📄 License

This infrastructure code is proprietary to the organization.

---

**Last Updated:** November 6, 2025
**Terraform Version:** >= 1.12.0
**Azure Provider Version:** ~> 4.0
