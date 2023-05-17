resource "azurerm_virtual_network" "vnet" {
    name                    =       var.vnet_name
    location                =       var.location 
    address_space           =       var.address_space 
    resource_group_name     =       var.resource_group_name 
}

resource "azurerm_subnet" "subnet" {
    for_each                =       var.subnets
    name                    =       each.value.subnet_name
    resource_group_name     =       var.resource_group_name
    virtual_network_name    =       azurerm_virtual_network.vnet.name
    address_prefixes        =       each.value.subnet_address_prefix
  

    dynamic delegation {
        for_each = each.value.create_delegation ? each.value.delegations : []

        content {
            name = delegation.value.name
            service_delegation {
                name    = delegation.value.service_delegation_name
                actions = delegation.value.service_delegation_action
            }
        }
    }
}