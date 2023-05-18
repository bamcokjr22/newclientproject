resource_group_name         =       "ais-tf-rg"
vnet_name                   =       "ais-vnet"  
address_space               =       ["192.168.0.0/16"]
location                    =       "West Europe"
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
        subnet_address_prefix   = ["192.168.2.0/24"]
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
appsvcplan_name                     =       "aislnxappsvcplan"
appsvc_os_type                      =       "Windows"
appsvc_sku_name                     =       "B1"
lnxappsvc_name                      =       "aislnxwebapptflearn"
lnxappsvcpe_name                    =       "aislnxwebapptflearn_pe"
lnxappsvc_con_name                  =       "aislnxwebapptflearn_con"
is_manual_connection                =       false
lnxappsvc_pe_dns_zone_grp           =      "aislnxwebapptflearndns"
lnxappsvc_pe_dns_zone_vlink_name    =       "aisvlink"

containergrp_name                   =   "aiscontainerinstance"
ip_address_type                     =   "Private"
dns_name_label                      =   "aisaci"
os_type                             =   "Linux" 

appgw                               =   "aisappgw"
appgwpip                            =   "aisappgw-pip"
appgw_sku                           =   "Standard_Small"
appgw_sku_tier                      =   "Standard"
appgw_sku_capacity                  =   2
allocation_method                   =   "Dynamic"
gateway_ip_configuration_name       =   "ais-gateway-ip-configuration"
frontend_port_name                  =   "aisappgw-feport" 
frontend_ip_configuration_name      =   "aisappgw-feip"    
backend_address_pool_name           =   "aisappgw-beap" 
http_setting_name                   =   "aisappgw-be-htst"
listener_name                       =   "apisappgw-httplstn"
request_routing_rule_name           =   "aisappgw-rqrt"