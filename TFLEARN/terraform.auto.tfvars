resource_group_name         =       "ais-tf-rg"
vnet_name                   =       "ais-vnet"  
address_space               =       ["192.168.0.0/16"]
location                    =       "Central US"
subnets                     =       {
    appservice_subnet = {
        subnet_name             = "appsvc"
        subnet_address_prefix   = ["192.168.0.0/24"]
        create_delegation       = true
        delegations             = [{
            name                    = "appSvcDelegation"
            service_delegation_name = "Microsoft.Web/serverFarms"
            service_delegation_action = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }]
    }
    private_endpoint_subnet = {
        subnet_name             = "pvtep"
        subnet_address_prefix   = ["192.168.1.0/24"]
        create_delegation       = false
        delegations  = []
    }
    appgateway_subnet = {
        subnet_name             = "appgw"
        subnet_address_prefix   = ["192.168.2.0/27"]
        create_delegation       = false
        service_delegation_name = []
        service_delegation_action = []
    }
    container_instance_subnet = {
        subnet_name             = "aci"
        subnet_address_prefix   = ["192.168.3.0/24"]
        create_delegation       = true
        delegations             = [{
            name                    = "containerDelegation"
            service_delegation_name = "Microsoft.ContainerInstance/containerGroups"
            service_delegation_action = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }]
    }
}