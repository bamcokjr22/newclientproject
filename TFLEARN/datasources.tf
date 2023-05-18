data "azurerm_traffic_manager_profile" "trafficmgr_profile_check" {
    name                = var.trafficmgr_profile_name
    resource_group_name = azurerm_resource_group.ais_rg.name
    
    depends_on = [azurerm_traffic_manager_profile.trafficmgr_profile]
}