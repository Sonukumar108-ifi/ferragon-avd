resource "azurerm_public_ip" "firewall" {
  name                = var.resource_names.firewall_public_ip
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = var.firewall_settings.public_ip_allocation_method
  sku                 = var.firewall_settings.public_ip_sku
  tags                = var.tags
}

resource "azurerm_firewall" "this" {
  name                = var.resource_names.firewall
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.firewall_settings.sku_name
  sku_tier            = var.firewall_sku_tier
  tags                = var.tags

  ip_configuration {
    name                 = var.resource_names.firewall_ip_configuration
    subnet_id            = azurerm_subnet.this[var.subnet_keys.firewall].id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "allow_outbound" {
  name                = var.resource_names.firewall_rule_collection
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = azurerm_resource_group.this.name
  priority            = var.firewall_settings.rule_collection_priority
  action              = var.firewall_settings.rule_collection_action

  rule {
    name                  = var.resource_names.firewall_rule
    source_addresses      = var.vnet_address_space
    destination_ports     = var.firewall_settings.destination_ports
    destination_addresses = var.firewall_settings.destination_addresses
    protocols             = var.firewall_settings.protocols
  }
}
