output "ais_rg_name" {
    value = azurerm_resource_group.ais_rg.name
}

output "vnet_name" {
    value = module.virtual_network.vnet_name
}