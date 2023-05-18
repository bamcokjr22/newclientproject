resource "azurerm_container_group" "containergrp" {
    name                =   var.containergrp_name
    location            =   var.location
    resource_group_name =   var.resource_group_name
    ip_address_type     =   var.ip_address_type
    os_type             =   var.os_type

    container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = 443
      protocol = "TCP"
    }
  }  

  subnet_ids =  [var.aci_subnet_id] 
}