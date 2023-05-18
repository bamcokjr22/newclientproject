resource "azurerm_public_ip" "appgwpip" {
  name                = var.appgwpip
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
}

resource "azurerm_application_gateway" "appgw" {
  name                = var.appgw
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.appgw_sku
    tier     = var.appgw_sku_tier
    capacity = var.appgw_sku_capacity
  }

  gateway_ip_configuration {
    name      = var.gateway_ip_configuration_name
    subnet_id = var.appgw_subnet_id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgwpip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
    ip_addresses = var.bend_ip_address
    fqdns = var.bend_fqdns
  }

  backend_http_settings {
    name                  = var.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = var.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = var.listener_name
    backend_address_pool_name  = var.backend_address_pool_name
    backend_http_settings_name = var.http_setting_name
  }
}