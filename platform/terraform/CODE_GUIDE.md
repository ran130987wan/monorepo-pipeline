# Terraform Code Structure Guide

This document explains the code architecture, implementation details, and module structure for the global infrastructure configuration.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Directory Structure](#directory-structure)
- [Configuration Files](#configuration-files)
- [Module Deep Dive](#module-deep-dive)
- [Variables and Locals](#variables-and-locals)
- [Provider Configuration](#provider-configuration)
- [State Management](#state-management)
- [Code Patterns](#code-patterns)

---

## Architecture Overview

### Design Principles

1. **Modularity** - Reusable modules for common resources
2. **DRY (Don't Repeat Yourself)** - Shared logic in locals and modules
3. **Separation of Concerns** - Configuration vs. implementation
4. **Environment Agnostic** - Same code for dev/stage/prod
5. **Remote State** - Azure Blob Storage backend

### Resource Hierarchy

```
Global Infrastructure
├── Resource Groups (8)
│   ├── container-rg
│   ├── web-rg
│   ├── security-rg
│   ├── data-rg
│   ├── monitoring-rg
│   ├── network-rg
│   ├── platform-rg
│   └── integration-rg
└── Managed Identity (1)
    └── User-Assigned Managed Identity
```

---

## Directory Structure

```
platform/terraform/
├── global/                              # Global infrastructure layer
│   ├── main.tf                         # Primary module orchestration
│   ├── variables.tf                    # Input variable definitions
│   ├── locals.tf                       # Computed local values
│   ├── providers.tf                    # Provider and backend config
│   ├── output.tf                       # Output value definitions
│   ├── setup-backend.sh                # Automated backend setup
│   ├── backend-config.tfbackend        # Backend credentials (ignored)
│   └── BACKEND.md                      # Backend documentation
│
├── envs/                               # Environment-specific configs
│   ├── dev/
│   │   └── global-vars/
│   │       └── main.tfvars            # Dev environment values
│   ├── stage/                          # (Future)
│   └── prod/                           # (Future)
│
└── modules/                            # Reusable Terraform modules
    ├── resource-group/
    │   ├── main.tf                    # Resource group implementation
    │   ├── variables.tf               # Module inputs
    │   ├── outputs.tf                 # Module outputs
    │   ├── versions.tf                # Provider version constraints
    │   └── README.md                  # Module documentation
    │
    ├── managed-identity/
    │   ├── main.tf                    # Managed identity implementation
    │   ├── variables.tf               # Module inputs
    │   ├── outputs.tf                 # Module outputs
    │   ├── versions.tf                # Provider version constraints
    │   └── README.md                  # Module documentation
    │
    └── federated-identity-credential/
        ├── main.tf                    # Federated credential implementation
        ├── variables.tf               # Module inputs
        ├── outputs.tf                 # Module outputs
        ├── versions.tf                # Provider version constraints
        └── README.md                  # Module documentation
```

---

## Configuration Files

### main.tf - Module Orchestration

**Purpose:** Orchestrates module calls and defines resource dependencies.

```hcl
# Resource Groups Module
module "resource_groups" {
  source          = "../modules/resource-group"
  resource_groups = local.resource_groups
}

# Managed Identity Module
module "managed_identity" {
  source           = "../modules/managed-identity"
  managed_identity = var.managed_identity
  depends_on       = [module.resource_groups]
}
```

**Key Concepts:**

1. **Module Source:** Relative path to module directory
2. **Module Inputs:** Variables passed to the module
3. **Dependencies:** `depends_on` ensures proper creation order
4. **Commented Sections:** Future modules (VNet, AKS, ACR) ready to enable

**Module Flow:**
```
Step 1: Create Resource Groups
        ↓
Step 2: Create Managed Identity (depends on RG)
        ↓
Step 3: (Future) Federated Identity Credential
```

### variables.tf - Input Definitions

**Purpose:** Defines all input variables with types and descriptions.

```hcl
variable "global_config" {
  type = object({
    prefix         = string
    compact_prefix = string
    environment    = string
    location       = string
    region_code    = string
    tags           = map(string)
  })
}

variable "azure_region_map" {
  type = map(string)
  default = {
    "centralus"  = "cus"
    "eastus"     = "eus"
    # ... more regions
  }
}

variable "managed_identity" {
  description = "Combined configuration for the managed identity module."
  type = object({
    umi_name            = string
    location            = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })
}
```

**Variable Types:**

1. **Object Variables:** Complex structured data
2. **Map Variables:** Key-value pairs (e.g., region mapping)
3. **Optional Fields:** `optional()` allows defaults

**Design Pattern:**
- Required fields: No default value
- Optional fields: Default value provided
- Complex objects: Use `object()` type

### locals.tf - Computed Values

**Purpose:** Computes derived values from variables to reduce duplication.

```hcl
locals {
  # Resource group definitions
  resource_groups_map = {
    container = {
      name = "container"
      type = "container"
    },
    web = {
      name = "web"
      type = "web"
    },
    # ... more RGs
  }

  # Computed region code
  region_code = var.azure_region_map[var.global_config.location]
  
  # Conditional lock enablement
  enable_resource_group_lock = var.global_config.environment == "prod" || var.global_config.environment == "stage" ? true : false

  # Generate resource group list
  resource_groups = [
    for rg in local.resource_groups_map : {
      name     = "${var.global_config.compact_prefix}-${rg.name}-rg-${var.global_config.environment}"
      location = var.global_config.location
      locks    = local.enable_resource_group_lock
      tags     = var.global_config.tags
    }
  ]
}
```

**Key Patterns:**

1. **For Loops:** `for rg in local.resource_groups_map : { ... }`
2. **String Interpolation:** `"${prefix}-${name}-${env}"`
3. **Conditional Logic:** Ternary operators for environment-specific behavior
4. **Map Lookups:** `var.azure_region_map[var.global_config.location]`

**Why Use Locals?**
- Reduce code duplication
- Centralize naming logic
- Enable dynamic resource generation
- Improve maintainability

### providers.tf - Provider Configuration

**Purpose:** Configures Terraform providers and backend state storage.

```hcl
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
  required_version = ">= 1.12.0"
  
  backend "azurerm" {
    # Configuration provided via backend-config.tfbackend file
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
```

**Key Components:**

1. **Required Providers:** Specifies provider sources and versions
2. **Version Constraints:** `~> 4.0` means >= 4.0.0 and < 5.0.0
3. **Backend Configuration:** External file for security
4. **Provider Features:** Azure-specific behavior customization
5. **Multiple Providers:** Alias support for multi-subscription deployments

### output.tf - Output Values

**Purpose:** Exports values for reference by other configurations or users.

```hcl
output "resource_group_ids" {
  description = "Map of resource group names to their IDs"
  value       = module.resource_groups.resource_group_ids
}

output "managed_identity_id" {
  description = "The resource ID of the user-assigned managed identity"
  value       = module.managed_identity.managed_identity_id
}

output "managed_identity_client_id" {
  description = "The client ID of the managed identity"
  value       = module.managed_identity.managed_identity_client_id
}

output "managed_identity_principal_id" {
  description = "The principal ID of the managed identity"
  value       = module.managed_identity.managed_identity_obj_id
}
```

**Usage:**
- Reference in other Terraform configs
- Display after `terraform apply`
- Use in CI/CD pipelines
- Pass to application configurations

---

## Module Deep Dive

### Resource Group Module

**Location:** `modules/resource-group/`

#### main.tf
```hcl
resource "azurerm_resource_group" "this" {
  for_each = { for rg in var.resource_groups : rg.name => rg }

  name     = each.value.name
  location = each.value.location
  tags     = each.value.tags
}

resource "azurerm_management_lock" "rg_lock" {
  for_each = {
    for rg in var.resource_groups : rg.name => rg
    if rg.locks
  }

  name       = "${each.value.name}-lock"
  scope      = azurerm_resource_group.this[each.key].id
  lock_level = "CanNotDelete"
  notes      = "Resource group lock enabled via Terraform."
}
```

**Pattern Explanation:**

1. **for_each Loop:** Creates multiple resources from list
2. **Map Conversion:** `{ for rg in var.resource_groups : rg.name => rg }`
   - Converts list to map with name as key
3. **Conditional Creation:** `if rg.locks` only creates locks when enabled
4. **Resource Reference:** `azurerm_resource_group.this[each.key].id`

#### variables.tf
```hcl
variable "resource_groups" {
  description = "List of configuration objects for the Resource Group module."
  type = list(object({
    name        = string
    location    = string
    locks       = bool
    tags        = optional(map(string), {})
  }))
  default = []
}
```

**Variable Structure:**
- **List of Objects:** Multiple resource groups
- **Required Fields:** name, location, locks
- **Optional Fields:** tags with empty map default

#### outputs.tf
```hcl
output "resource_group_ids" {
  description = "Map of resource group names to their IDs"
  value       = { for k, v in azurerm_resource_group.this : k => v.id }
}

output "resource_group_names" {
  description = "List of resource group names"
  value       = [for rg in azurerm_resource_group.this : rg.name]
}
```

**Output Patterns:**
- **Map Output:** Key-value pairs for easy lookup
- **List Output:** Simple list of names

### Managed Identity Module

**Location:** `modules/managed-identity/`

#### main.tf
```hcl
resource "azurerm_user_assigned_identity" "umi" {
  name                = var.managed_identity.umi_name
  location            = var.managed_identity.location
  resource_group_name = var.managed_identity.resource_group_name
  tags                = var.managed_identity.tags
}
```

**Simple Pattern:**
- Single resource creation
- Direct variable mapping
- No complex logic needed

#### outputs.tf
```hcl
output "managed_identity_id" {
  description = "The resource ID of the user-assigned managed identity"
  value       = azurerm_user_assigned_identity.umi.id
}

output "managed_identity_obj_id" {
  description = "The principal/object ID of the managed identity"
  value       = azurerm_user_assigned_identity.umi.principal_id
}

output "managed_identity_client_id" {
  description = "The client ID of the managed identity"
  value       = azurerm_user_assigned_identity.umi.client_id
}
```

**Three Critical IDs:**
1. **Resource ID:** Full Azure resource identifier
2. **Principal/Object ID:** For RBAC assignments
3. **Client ID:** For application authentication

### Federated Identity Credential Module

**Location:** `modules/federated-identity-credential/`

#### main.tf
```hcl
resource "azurerm_federated_identity_credential" "federated_identity" {
  name                = var.federated_identity_credential.name
  resource_group_name = var.federated_identity_credential.resource_group_name
  parent_id           = var.federated_identity_credential.parent_id
  audience            = var.federated_identity_credential.audience
  issuer              = var.federated_identity_credential.issuer
  subject             = var.federated_identity_credential.subject
}
```

**Purpose:** Enables OIDC authentication (e.g., GitHub Actions)

**Key Fields:**
- **parent_id:** Managed identity to link to
- **issuer:** Identity provider URL (e.g., GitHub)
- **subject:** Claim pattern to match (e.g., repo path)
- **audience:** Token audience (usually `api://AzureADTokenExchange`)

---

## Variables and Locals

### Variable Flow

```
main.tfvars
    ↓
variables.tf (definitions)
    ↓
locals.tf (computations)
    ↓
main.tf (module calls)
    ↓
modules/*/variables.tf
    ↓
modules/*/main.tf (resources)
```

### Naming Convention Logic

**Implemented in locals.tf:**

```hcl
name = "${var.global_config.compact_prefix}-${rg.name}-rg-${var.global_config.environment}"
```

**Breakdown:**
- `compact_prefix`: Short project identifier (e.g., "vdccpadm")
- `rg.name`: Resource type (e.g., "integration")
- `rg`: Fixed suffix for resource groups
- `environment`: Environment name (e.g., "dev")

**Result:** `vdccpadm-integration-rg-dev`

### Region Code Mapping

**Purpose:** Convert full region names to short codes

```hcl
azure_region_map = {
  "centralus"  = "cus"
  "eastus"     = "eus"
  "westus"     = "wus"
  # ...
}

region_code = var.azure_region_map[var.global_config.location]
```

**Usage:** Useful for resource names with length constraints

### Environment-Specific Logic

**Conditional Resource Locks:**

```hcl
enable_resource_group_lock = var.global_config.environment == "prod" || var.global_config.environment == "stage" ? true : false
```

**Logic:**
- Production and Staging: Locks enabled (CanNotDelete)
- Development: No locks (easier cleanup)

---

## Provider Configuration

### Version Constraints

```hcl
required_providers {
  azurerm = {
    source  = "hashicorp/azurerm"
    version = "~> 4.0"
  }
}
```

**Version Syntax:**
- `~> 4.0`: Compatible with 4.x (pessimistic constraint)
- `>= 1.12.0`: Minimum version 1.12.0
- `= 1.0.0`: Exact version (not recommended)

### Provider Features

```hcl
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
```

**Safety Feature:** Prevents accidental deletion of non-empty resource groups

### Multi-Provider Setup

**Use Case:** Multiple Azure subscriptions

```hcl
provider "azurerm" {
  alias           = "platform"
  subscription_id = "<platform-subscription-id>"
}

# Usage in modules:
module "example" {
  source = "./modules/example"
  providers = {
    azurerm = azurerm.platform
  }
}
```

---

## State Management

### Backend Configuration

**providers.tf:**
```hcl
backend "azurerm" {
  # Configuration provided via backend-config.tfbackend file
}
```

**backend-config.tfbackend:**
```hcl
resource_group_name  = "terraform-state-rg"
storage_account_name = "tfstate2159128673"
container_name       = "tfstate"
key                  = "global.tfstate"
```

**Why Separate File?**
1. Security: Exclude from version control
2. Flexibility: Different backends per environment
3. Reusability: Share across team securely

### State Structure

```json
{
  "version": 4,
  "terraform_version": "1.13.4",
  "resources": [
    {
      "module": "module.resource_groups",
      "type": "azurerm_resource_group",
      "name": "this",
      "instances": [...]
    },
    {
      "module": "module.managed_identity",
      "type": "azurerm_user_assigned_identity",
      "name": "umi",
      "instances": [...]
    }
  ]
}
```

### State Locking

**Azure Blob Storage provides:**
- Automatic state locking via blob leases
- Prevents concurrent modifications
- 15-second timeout for lock acquisition

---

## Code Patterns

### 1. for_each Pattern

**Use Case:** Create multiple similar resources

```hcl
resource "azurerm_resource_group" "this" {
  for_each = { for rg in var.resource_groups : rg.name => rg }
  
  name     = each.value.name
  location = each.value.location
}
```

**Advantages:**
- Resources identified by meaningful keys
- Easy to add/remove individual resources
- Better state management than count

### 2. Conditional Resource Creation

**Use Case:** Create resources only when needed

```hcl
resource "azurerm_management_lock" "rg_lock" {
  for_each = {
    for rg in var.resource_groups : rg.name => rg
    if rg.locks  # Condition
  }
  # ...
}
```

### 3. Dynamic Block Pattern

**Use Case:** Conditional nested blocks (not currently used but available)

```hcl
dynamic "identity" {
  for_each = var.enable_identity ? [1] : []
  content {
    type = "SystemAssigned"
  }
}
```

### 4. Module Dependency Pattern

**Use Case:** Ensure proper resource creation order

```hcl
module "managed_identity" {
  source     = "../modules/managed-identity"
  # ...
  depends_on = [module.resource_groups]
}
```

### 5. Output Chaining Pattern

**Use Case:** Pass module outputs to other modules

```hcl
# Module A output
output "rg_id" {
  value = azurerm_resource_group.this.id
}

# Module B usage
resource "azurerm_resource" "example" {
  resource_group_id = module.resource_group.rg_id
}
```

---

## Best Practices in Code

### 1. Variable Validation

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be dev, stage, or prod."
  }
}
```

### 2. Resource Naming

**Consistent Pattern:**
```
{prefix}-{resource_type}-{suffix}-{environment}
```

### 3. Tagging Strategy

**Always include:**
- `environment`: dev/stage/prod
- `product`: Project name
- `source`: terraform
- `cost_center`: (optional) For billing
- `owner`: (optional) Team name

### 4. Module Versioning

```hcl
module "example" {
  source = "git::https://github.com/org/repo.git//modules/example?ref=v1.0.0"
}
```

### 5. Comments and Documentation

```hcl
variable "example" {
  description = "Clear description of purpose"  # Always describe
  type        = string                          # Always specify type
}

# Inline comments for complex logic
locals {
  # Calculate resource lock enablement based on environment
  enable_locks = var.env == "prod" ? true : false
}
```

---

## Code Evolution Path

### Current State (v1.0.0)

✅ Resource Groups  
✅ Managed Identity  
✅ Azure Backend  
✅ Basic module structure

### Phase 2 (Future)

- [ ] Federated Identity Credential
- [ ] VNet and Subnet modules
- [ ] NAT Gateway
- [ ] Network Security Groups

### Phase 3 (Future)

- [ ] AKS Cluster
- [ ] Azure Container Registry
- [ ] Key Vault
- [ ] Private Endpoints

### Phase 4 (Future)

- [ ] Monitoring and Alerts
- [ ] Log Analytics
- [ ] Application Insights
- [ ] Policy Assignments

---

## References

### Official Documentation

- [Terraform Language](https://www.terraform.io/language)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Module Development](https://www.terraform.io/language/modules/develop)

### Internal Documentation

- `USAGE_GUIDE.md` - Execution instructions
- `BACKEND.md` - Backend configuration
- `README.md` - Project overview

---

**Last Updated:** November 5, 2025  
**Version:** 1.0.0  
**Maintainer:** Infrastructure Team
