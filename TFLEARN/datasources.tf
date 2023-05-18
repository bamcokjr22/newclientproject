data "azurerm_traffic_manager_profile" "trafficmgr_profile_ref" {
    # count               =   var.create_trafficmgr_profile == true ? 1 : 0
    name                 =  var.trafficmgr_profile_name
    resource_group_name  =  "weu-ais-tf-rg"    
}