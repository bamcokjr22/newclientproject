resource "azurerm_service_plan" "appsvcplan" {
    name                =   var.appsvcplan_name
    resource_group_name =   var.resource_group_name
    location            =   var.location
    os_type             =   var.appsvc_os_type
    sku_name            =   var.appsvc_sku_name  
}

resource "azurerm_linux_web_app" "lnxappsvc" {
    name                =   var.lnxappsvc_name
    resource_group_name =   var.resource_group_name
    location            =   azurerm_service_plan.appsvcplan.location
    service_plan_id     =   azurerm_service_plan.appsvcplan.id
    site_config {
        http2_enabled = true
        minimum_tls_version = "1.2"
    }  
    
    auth_settings {
        enabled = true     
        unauthenticated_client_action = "AllowAnonymous" 
    } 
    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_private_endpoint" "lnxappsvcpe" {
    name                =   var.lnxappsvcpe_name
    location            =   var.location
    resource_group_name =   var.resource_group_name
    subnet_id           =   var.pe_subnet_id

    private_service_connection {
        name                            =   var.lnxappsvc_con_name
        private_connection_resource_id  =   azurerm_linux_web_app.lnxappsvc.id
        subresource_names               =   ["sites"]
        is_manual_connection            =   var.is_manual_connection    
    }


    private_dns_zone_group {
        name                            =   var.lnxappsvc_pe_dns_zone_grp
        private_dns_zone_ids            =   [azurerm_private_dns_zone.lnxappsvc_pe_dns_zone.id]
    }  
}

resource "azurerm_private_dns_zone" "lnxappsvc_pe_dns_zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "lnxappsvc_pe_dns_zone_vlink" {
  name                  = var.lnxappsvc_pe_dns_zone_vlink_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.lnxappsvc_pe_dns_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "lnxappsvc_swift_con" {
    app_service_id      = azurerm_linux_web_app.lnxappsvc.id
    subnet_id           = var.web_subnet_id
}