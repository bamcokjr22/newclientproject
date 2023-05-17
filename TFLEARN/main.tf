resource "azurerm_resource_group" "ais_rg" {
    name                    =       var.resource_group_name
    location                =       var.location
}

module "virtualnetwork" {
    source                  =       "./modules/virtual_network"
    vnet_name               =       var.vnet_name
    resource_group_name     =       azurerm_resource_group.ais_rg.name
    location                =       azurerm_resource_group.ais_rg.location
    address_space           =       var.address_space
    subnets                 =       var.subnets
}