output "appgw" {
    value = azurerm_application_gateway.appgw.name
}

output "appgw_id" {
    value = azurerm_application_gateway.appgw.id
}

output "appgw_pip_id" {
    value = azurerm_public_ip.appgwpip.id
}