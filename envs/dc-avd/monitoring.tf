resource "azurerm_log_analytics_workspace" "this" {
  name                = var.resource_names.log_analytics_workspace
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = var.monitoring_settings.log_analytics_sku
  retention_in_days   = var.monitoring_settings.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.resource_names.application_insights
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  application_type    = var.monitoring_settings.application_type
  workspace_id        = azurerm_log_analytics_workspace.this.id
  retention_in_days   = var.monitoring_settings.application_retention_days
  tags                = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "dc_vm" {
  name                       = var.resource_names.dc_diagnostic_setting
  target_resource_id         = azurerm_windows_virtual_machine.dc.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  metric {
    category = var.monitoring_settings.metric_category
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = var.resource_names.firewall_diagnostic_setting
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category_group = var.monitoring_settings.firewall_log_category_group
  }

  metric {
    category = var.monitoring_settings.metric_category
  }
}
