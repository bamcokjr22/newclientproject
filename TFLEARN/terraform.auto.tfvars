resource_group_name         =       "ais-tf-rg"
vnet_name                   =       "ais-vnet"  
address_space               =       ["192.168.0.0/16"]
location                    =       "Central US"
subnets                     =       {
    appservice_subnet = {
        subnet_name             = "appsvc"
        subnet_address_prefix   = ["192.168.0.0/24"]
    }
    private_endpoint_subnet = {
        subnet_name             = "pvtep"
        subnet_address_prefix   = ["192.168.1.0/24"]
    }
    appgateway_subnet = {
        subnet_name             = "appgw"
        subnet_address_prefix   = ["192.168.2.0/27"]
    }
    container_instance_subnet = {
        subnet_name             = "aci"
        subnet_address_prefix   = ["192.168.3.0/24"]
    }
}