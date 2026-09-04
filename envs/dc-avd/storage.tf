# Azure Files storage account and file share configuration for FSLogix profiles

resource "random_string" "storage_suffix" {
  length  = var.storage_settings.random_suffix_length
  special = var.storage_settings.random_suffix_special
  upper   = var.storage_settings.random_suffix_upper
}

resource "azurerm_storage_account" "files" {
  name                     = "${var.resource_names.storage_account_prefix}${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = var.storage_settings.account_tier
  account_replication_type = var.storage_settings.account_replication_type
  account_kind             = var.storage_settings.account_kind
  tags                     = var.tags
}

resource "azurerm_storage_share" "profiles" {
  name                 = var.resource_names.storage_share
  storage_account_name = azurerm_storage_account.files.name
  quota                = var.files_provisioned_gb
  access_tier          = var.storage_settings.share_access_tier
  enabled_protocol     = var.storage_settings.share_protocol
}
