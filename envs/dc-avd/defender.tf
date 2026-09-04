resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = var.defender_settings.tier
  resource_type = var.defender_settings.virtual_machines_type
  subplan       = var.defender_settings.servers_subplan
}

resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = var.defender_settings.tier
  resource_type = var.defender_settings.storage_accounts_type
}

resource "azurerm_security_center_subscription_pricing" "keyvault" {
  tier          = var.defender_settings.tier
  resource_type = var.defender_settings.key_vaults_type
}
