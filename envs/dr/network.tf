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

resource "azurerm_network_security_group" "dr" {
  name                = var.resource_names.network_security_group
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "dr" {
  subnet_id                 = azurerm_subnet.this[var.dr_subnet_key].id
  network_security_group_id = azurerm_network_security_group.dr.id
}
