resource "azurerm_resource_group" "ais_rg" {
    name                    =       var.resource_group_name
    location                =       var.location
}

module "virtual_network" {
    source                  =       "./modules/virtual_network"
    vnet_name               =       var.vnet_name
    resource_group_name     =       azurerm_resource_group.ais_rg.name
    location                =       azurerm_resource_group.ais_rg.location
    address_space           =       var.address_space
    subnets                 =       var.subnets
}

module "linux_app_service" {
    source                              =       "./modules/app_services"
    appsvcplan_name                     =       var.appsvcplan_name
    resource_group_name                 =       azurerm_resource_group.ais_rg.name
    location                            =       azurerm_resource_group.ais_rg.location 
    appsvc_os_type                      =       var.appsvc_os_type
    appsvc_sku_name                     =       var.appsvc_sku_name
    lnxappsvc_name                      =       var.lnxappsvc_name
    lnxappsvcpe_name                    =       var.lnxappsvcpe_name
    pe_subnet_id                        =       module.virtual_network.subnet_ids["private_endpoint_subnet"]
    lnxappsvc_con_name                  =       var.lnxappsvc_con_name
    is_manual_connection                =       var.is_manual_connection
    lnxappsvc_pe_dns_zone_grp           =       var.lnxappsvc_pe_dns_zone_grp
    lnxappsvc_pe_dns_zone_vlink_name    =       var.lnxappsvc_pe_dns_zone_vlink_name
    virtual_network_id                  =       module.virtual_network.vnet_id
    web_subnet_id                       =       module.virtual_network.subnet_ids["appservice_subnet"]
}

module "container_instance" {
    source                              =    "./modules/container_instance"
    containergrp_name                   =   var.containergrp_name
    location                            =   azurerm_resource_group.ais_rg.location
    resource_group_name                 =   azurerm_resource_group.ais_rg.name  
    ip_address_type                     =   var.ip_address_type
    os_type                             =   var.os_type 
    aci_subnet_id                       =   module.virtual_network.subnet_ids["container_instance_subnet"] 
}

module "application_gateway" {
    source                              =    "./modules/appgw"
    appgw                               =   var.appgw
    appgwpip                            =   var.appgwpip
    appgw_sku                           =   var.appgw_sku
    appgw_sku_tier                      =   var.appgw_sku_tier
    appgw_sku_capacity                  =   var.appgw_sku_capacity
    allocation_method                   =   var.allocation_method
    appgw_subnet_id                     =   module.virtual_network.subnet_ids["appgateway_subnet"]
    gateway_ip_configuration_name       =   var.gateway_ip_configuration_name
    frontend_port_name                  =   var.frontend_port_name 
    frontend_ip_configuration_name      =   var.frontend_ip_configuration_name    
    backend_address_pool_name           =   var.backend_address_pool_name 
    http_setting_name                   =   var.http_setting_name
    listener_name                       =   var.listener_name
    request_routing_rule_name           =   var.request_routing_rule_name
    resource_group_name                 =   azurerm_resource_group.ais_rg.name
    location                            =   azurerm_resource_group.ais_rg.location
}