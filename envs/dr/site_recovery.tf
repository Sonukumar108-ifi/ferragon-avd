
resource "azurerm_recovery_services_vault" "asr" {
  name                = var.resource_names.recovery_vault
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.site_recovery_settings.vault_sku
  soft_delete_enabled = var.site_recovery_settings.soft_delete_enabled
  tags                = var.tags
}

resource "azurerm_site_recovery_fabric" "this" {
  for_each            = var.asr_sites
  name                = each.value.fabric_name
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.asr.name
  location            = each.value.location
}

resource "azurerm_site_recovery_protection_container" "this" {
  for_each             = var.asr_sites
  name                 = each.value.container_name
  resource_group_name  = azurerm_resource_group.this.name
  recovery_vault_name  = azurerm_recovery_services_vault.asr.name
  recovery_fabric_name = azurerm_site_recovery_fabric.this[each.key].name
}

resource "azurerm_site_recovery_replication_policy" "this" {
  name                                                 = var.resource_names.replication_policy
  resource_group_name                                  = azurerm_resource_group.this.name
  recovery_vault_name                                  = azurerm_recovery_services_vault.asr.name
  recovery_point_retention_in_minutes                  = var.site_recovery_settings.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = var.site_recovery_settings.app_consistent_snapshot_frequency_minutes
}

resource "azurerm_site_recovery_protection_container_mapping" "this" {
  name                                      = var.resource_names.container_mapping
  resource_group_name                       = azurerm_resource_group.this.name
  recovery_vault_name                       = azurerm_recovery_services_vault.asr.name
  recovery_fabric_name                      = azurerm_site_recovery_fabric.this[var.site_recovery_settings.source_site_key].name
  recovery_source_protection_container_name = azurerm_site_recovery_protection_container.this[var.site_recovery_settings.source_site_key].name
  recovery_target_protection_container_id   = azurerm_site_recovery_protection_container.this[var.site_recovery_settings.target_site_key].id
  recovery_replication_policy_id            = azurerm_site_recovery_replication_policy.this.id
}

resource "azurerm_site_recovery_network_mapping" "this" {
  name                        = var.resource_names.network_mapping
  resource_group_name         = azurerm_resource_group.this.name
  recovery_vault_name         = azurerm_recovery_services_vault.asr.name
  source_recovery_fabric_name = azurerm_site_recovery_fabric.this[var.site_recovery_settings.source_site_key].name
  target_recovery_fabric_name = azurerm_site_recovery_fabric.this[var.site_recovery_settings.target_site_key].name
  source_network_id           = "/subscriptions/${var.subscription_id}/resourceGroups/${var.primary_resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.primary_vnet_name}"
  target_network_id           = azurerm_virtual_network.this.id
}

# Replicated VM resources require primary VM IDs and should be added as a
# for_each map after the primary environment exposes those IDs.
