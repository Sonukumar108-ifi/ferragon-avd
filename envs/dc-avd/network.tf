resource "azurerm_resource_group" "this" {
  name     = var.resource_names.resource_group
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "this" {
  name                = var.resource_names.virtual_network
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each             = var.subnet_config
  name                 = each.key
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "dc" {
  name                = var.resource_names.dc_network_security_group
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "dc" {
  subnet_id                 = azurerm_subnet.this[var.subnet_keys.dc].id
  network_security_group_id = azurerm_network_security_group.dc.id
}

resource "azurerm_network_security_group" "avd" {
  name                = var.resource_names.avd_network_security_group
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "avd" {
  subnet_id                 = azurerm_subnet.this[var.subnet_keys.avd].id
  network_security_group_id = azurerm_network_security_group.avd.id
}
