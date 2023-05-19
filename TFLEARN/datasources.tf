data "azurerm_traffic_manager_profile" "trafficmgr_profile_check" {
    name                = var.trafficmgr_profile_name
    resource_group_name = "weu-ais-tf-rg"
    
    depends_on = [azurerm_traffic_manager_profile.trafficmgr_profile]
}