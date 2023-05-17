output "appsvcplan_name" {
    value = azurerm_service_plan.appsvcplan.name
}

output "winappsvc_name" {
    value = azurerm_windows_web_app.winappsvc.name
}