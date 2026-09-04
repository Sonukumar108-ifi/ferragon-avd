resource "azurerm_recovery_services_vault" "this" {
  name                = var.resource_names.recovery_vault
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.backup_settings.vault_sku
  storage_mode_type   = var.backup_settings.storage_mode_type
  soft_delete_enabled = var.backup_settings.soft_delete_enabled
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "dc" {
  name                = var.resource_names.dc_backup_policy
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  backup {
    frequency = var.backup_settings.vm_frequency
    time      = var.backup_settings.vm_time
  }

  retention_daily {
    count = var.backup_settings.vm_retention_daily_count
  }
}

resource "azurerm_backup_protected_vm" "dc" {
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = azurerm_windows_virtual_machine.dc.id
  backup_policy_id    = azurerm_backup_policy_vm.dc.id
}

resource "azurerm_backup_policy_file_share" "files" {
  name                = var.resource_names.file_share_backup_policy
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  backup {
    frequency = var.backup_settings.files_frequency
    time      = var.backup_settings.files_time
  }

  retention_daily {
    count = var.backup_settings.files_retention_daily_count
  }
}

resource "azurerm_backup_container_storage_account" "files" {
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  storage_account_id  = azurerm_storage_account.files.id
}

resource "azurerm_backup_protected_file_share" "profiles" {
  resource_group_name       = azurerm_resource_group.this.name
  recovery_vault_name       = azurerm_recovery_services_vault.this.name
  source_storage_account_id = azurerm_backup_container_storage_account.files.storage_account_id
  source_file_share_name    = azurerm_storage_share.profiles.name
  backup_policy_id          = azurerm_backup_policy_file_share.files.id
}
