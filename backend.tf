terraform {
  backend "azurerm" {
    storage_account_name = "aisremotebackend"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"  
  }
}