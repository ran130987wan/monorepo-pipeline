global_config = {
  prefix         = "vdc-entra-admin"
  compact_prefix = "vdcentraadm"
  environment    = "dev"
  location       = "centralus"
  region_code    = "cus"
  tags = {
    product     = "vdc-Entra-Admin"
    environment = "dev"
    source      = "terraform-gh-runner"
  }
}

storageaccount = {
  name                          = "vdcentraadminsacusdevtfbe"
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  min_tls_version               = "TLS1_2"
  network_rules_enabled         = false
  blob_versioning_enabled       = true
  large_file_share_enabled      = true
}