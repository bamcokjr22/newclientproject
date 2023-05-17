resource "azurerm_service_plan" "appsvcplan" {
    name                =   var.appsvcplan_name
    resource_group_name =   var.resource_group_name
    location            =   var.location
    os_type             =   var.appsvc_os_type
    sku_name            =   var.appsvc_sku_name  
}

resource "azurerm_windows_web_app" "winappsvc" {
    name                =   var.winappsvc_name
    resource_group_name =   var.resource_group_name
    location            =   azurerm_service_plan.appsvcplan.location
    service_plan_id     =   azurerm_service_plan.appsvcplan.id
    site_config {}   
}

resource "azurerm_private_endpoint" "winappsvcpe" {
    name                =   var.winappsvcpe_name
    location            =   var.location
    resource_group_name =   var.resource_group_name
    subnet_id           =   var.pe_subnet_id

    private_service_connection {
        name                            =   var.winappsvc_con_name
        private_connection_resource_id  =   azurerm_windows_web_app.winappsvc.id
        subresource_names               =   ["sites"]
        is_manual_connection            =   var.is_manual_connection    
    }


    private_dns_zone_group {
        name                            =   var.winappsvc_pe_dns_zone_grp
        private_dns_zone_ids            =   [azurerm_private_dns_zone.winappsvc_pe_dns_zone.id]
    }  
}

resource "azurerm_private_dns_zone" "winappsvc_pe_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}