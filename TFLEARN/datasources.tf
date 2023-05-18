data "azurerm_traffic_manager_profile" "trafficmgr_profile_ref" {
    name                 =  var.trafficmgr_profile_name
    resource_group_name  =  azurerm_resource_group.ais_rg.name     
}