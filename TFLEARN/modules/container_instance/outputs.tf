output "containergrp_name" {
    value = azurerm_container_group.containergrp.name
}

output "container_ip" {
    value = azurerm_container_group.containergrp.ip_address
}