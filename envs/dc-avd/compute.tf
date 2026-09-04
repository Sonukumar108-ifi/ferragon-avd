resource "azurerm_network_interface" "dc" {
  name                = var.resource_names.dc_network_interface
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  ip_configuration {
    name                          = var.resource_names.dc_ip_configuration
    subnet_id                     = azurerm_subnet.this[var.subnet_keys.dc].id
    private_ip_address_allocation = var.dc_settings.private_ip_allocation
  }
}

resource "azurerm_windows_virtual_machine" "dc" {
  name                = var.resource_names.dc_virtual_machine
  computer_name       = var.resource_names.dc_computer
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = var.dc_vm_size
  admin_username      = var.dc_admin_username
  admin_password      = random_password.dc_admin.result
  license_type        = var.dc_settings.license_type
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.dc.id]

  os_disk {
    name                 = var.resource_names.dc_os_disk
    caching              = var.dc_settings.os_disk_caching
    storage_account_type = var.dc_settings.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.dc_settings.image_publisher
    offer     = var.dc_settings.image_offer
    sku       = var.dc_settings.image_sku
    version   = var.dc_settings.image_version
  }
}

## Data Disk for Domain Controller (DC) 
resource "azurerm_managed_disk" "dc_data" {
  name                 = var.resource_names.dc_data_disk
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_type = var.dc_settings.data_disk_storage_account_type
  create_option        = var.dc_settings.data_disk_create_option
  disk_size_gb         = var.dc_data_disk_size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "dc_data" {
  managed_disk_id    = azurerm_managed_disk.dc_data.id
  virtual_machine_id = azurerm_windows_virtual_machine.dc.id
  lun                = var.dc_settings.data_disk_lun
  caching            = var.dc_settings.data_disk_caching
}
