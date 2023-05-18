terraform {
  backend "azurerm" {
    storage_account_name = "aisremotebackend"
    container_name       = "tfstate"
    key                  = "weuterraform.tfstate"  
    resource_group_name = "AIS-TFLEARN-RG"
  }
}