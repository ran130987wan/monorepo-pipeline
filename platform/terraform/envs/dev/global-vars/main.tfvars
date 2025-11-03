/*--------------------------------------------------------------------------------------------------*/
/*                          Global Configuration Variables                                          */
/*--------------------------------------------------------------------------------------------------*/
global_config = {
    prefix                          =   "vdc-cp-admin"
    compact_prefix                  =   "vdccpadm"
    environment                     =   "dev"
    location                        =   "centralus"
    region_code                     =   "cus"
    tags                            =   {
                                            product     = "vdc-cp-admin"
                                            environment = "dev"
                                            source       = "terraform"
                                        }
}

managed_identity = {
    umi_name                        =   "vdccpadmin-mi-dev"
    resource_group_name             =   "vdccpadmin-integration-rg-dev"
    location                        =   "centralus"
    tags                            =   {
                                            product     = "vdc-cp-admin"
                                            environment = "dev"
                                            source       = "terraform"
                                        }
}