resource "azurerm_public_ip" "vpngw" {
  name                = var.resource_names.vpn_public_ip
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = var.vpn_settings.public_ip_allocation_method
  sku                 = var.vpn_settings.public_ip_sku
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "this" {
  name                = var.resource_names.vpn_gateway
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  type                = var.vpn_settings.gateway_type
  vpn_type            = var.vpn_settings.vpn_type
  sku                 = var.vpn_gateway_sku
  tags                = var.tags

  ip_configuration {
    name                          = var.resource_names.vpn_ip_configuration
    public_ip_address_id          = azurerm_public_ip.vpngw.id
    private_ip_address_allocation = var.vpn_settings.private_ip_allocation
    subnet_id                     = azurerm_subnet.this[var.subnet_keys.gateway].id
  }
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = var.resource_names.local_network_gateway
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = var.onprem_gateway_public_ip
  address_space       = var.onprem_address_space
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                       = var.resource_names.vpn_connection
  location                   = azurerm_resource_group.this.location
  resource_group_name        = azurerm_resource_group.this.name
  type                       = var.vpn_settings.connection_type
  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id
  shared_key                 = random_password.vpn_shared_key.result
  tags                       = var.tags
}
