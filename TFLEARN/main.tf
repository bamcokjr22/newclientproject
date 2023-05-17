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

module "windows_app_service" {
    source                  =       "./modules/app_services"
    appsvcplan_name         =       var.appsvcplan_name
    resource_group_name     =       azurerm_resource_group.ais_rg.name
    location                =       azurerm_resource_group.ais_rg.location 
    appsvc_os_type          =       var.appsvc_os_type
    appsvc_sku_name         =       var.appsvc_sku_name
    winappsvc_name          =       var.winappsvc_name
    winappsvcpe_name        =       var.winappsvcpe_name
    pe_subnet_id            =       module.virtual_network.subnet_ids["private_endpoint_subnet"]
    winappsvc_con_name      =       var.winappsvc_con_name
    is_manual_connection    =       var.is_manual_connection
    winappsvc_pe_dns_zone_grp=      var.winappsvc_pe_dns_zone_grp
}