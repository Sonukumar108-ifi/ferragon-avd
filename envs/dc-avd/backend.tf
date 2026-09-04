terraform {
  backend "azurerm" {
    resource_group_name  = "azure-vm-sonu"
    storage_account_name = "sonustorageaccoun"
    container_name       = "az-container"
    key                  = "terraform.tfstate"
    use_azuread_auth     = true
  }
}
