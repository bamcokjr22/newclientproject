output "appsvcplan_name" {
    value = azurerm_service_plan.appsvcplan.name
}

output "lnxappsvc_name" {
    value = azurerm_linux_web_app.lnxappsvc.name
}