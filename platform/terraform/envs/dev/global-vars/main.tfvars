# ============================================================================
# Environment-Specific Variables - DEV
# ============================================================================
# Variable values for the development environment
# This file is passed to Terraform via: -var-file=../envs/dev/global-vars/main.tfvars
# ============================================================================

global_config = {
  prefix         = "vdc-cp-admin"   # Full prefix for resource naming
  compact_prefix = "vdccpadm"       # Shortened prefix for storage accounts (24 char limit)
  environment    = "dev"            # Environment identifier (dev/stage/prod)
  location       = "centralus"      # Azure region for resource deployment
  region_code    = "cus"            # Short region code for naming
  tags = {
    product     = "vdc-cp-admin"    # Product/project identifier
    environment = "dev"             # Environment tag for cost tracking
    source      = "terraform"       # Infrastructure-as-Code indicator
  }
}