terraform {
  backend "azurerm" {
    storage_account_name = "aisremotebackend"
    container_name       = "tfstate"
    key                  = "eusterraform.tfstate"  
    resource_group_name = "AIS-TFLEARN-RG"
  }
}