terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  features {
    recovery_services_vaults {
      recover_soft_deleted_backup_protected_vm = var.provider_settings.recover_soft_deleted_backup_protected_vm
    }
  }
  storage_use_azuread = var.provider_settings.storage_use_azuread
}
