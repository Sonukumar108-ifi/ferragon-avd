
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
