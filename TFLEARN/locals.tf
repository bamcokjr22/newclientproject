locals {
  trafficmgr_profile_id = var.create_trafficmgr_profile ? data.azurerm_traffic_manager_profile.trafficmgr_profile_check.id : null
}