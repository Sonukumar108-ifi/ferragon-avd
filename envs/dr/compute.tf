
resource "azurerm_network_interface" "dr" {
  for_each            = var.dr_vms
  name                = "${var.resource_names.network_interface_prefix}${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  ip_configuration {
    name                          = var.resource_names.ip_configuration
    subnet_id                     = azurerm_subnet.this[var.dr_subnet_key].id
    private_ip_address_allocation = var.compute_settings.private_ip_allocation
  }
}

resource "azurerm_windows_virtual_machine" "dr" {
  for_each            = var.dr_vms
  name                = each.key
  computer_name       = upper(substr(replace(each.key, "-", ""), 0, var.compute_settings.computer_name_max_length))
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = each.value.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  license_type        = var.compute_settings.license_type
  tags                = var.tags

  network_interface_ids = [azurerm_network_interface.dr[each.key].id]

  os_disk {
    name                 = "${var.resource_names.os_disk_prefix}${each.key}"
    caching              = var.compute_settings.os_disk_caching
    storage_account_type = each.value.disk_sku
  }

  source_image_reference {
    publisher = var.compute_settings.image_publisher
    offer     = var.compute_settings.image_offer
    sku       = var.compute_settings.image_sku
    version   = var.compute_settings.image_version
  }
}

# BOQ: SQL Standard, Pay-as-you-go licensing on each DR VM.
resource "azurerm_mssql_virtual_machine" "dr" {
  for_each              = var.dr_vms
  virtual_machine_id    = azurerm_windows_virtual_machine.dr[each.key].id
  sql_license_type      = var.compute_settings.sql_license_type
  sql_connectivity_port = var.compute_settings.sql_connectivity_port
  sql_connectivity_type = var.compute_settings.sql_connectivity_type
  tags                  = var.tags
}

locals {
  # Flattened map of every data disk across every DR VM, keyed uniquely,
  # each entry carrying its parent VM key so attachment can reference it
  # without re-parsing the composite key.
  dr_data_disks = {
    for pair in flatten([
      for vm_key, vm in var.dr_vms : [
        for i in range(vm.data_disk_count) : {
          key      = "${vm_key}-${i}"
          vm_key   = vm_key
          lun      = i
          size_gb  = vm.disk_size_gb
          disk_sku = vm.disk_sku
        }
      ]
    ]) : pair.key => pair
  }
}

resource "azurerm_managed_disk" "dr_data" {
  for_each = local.dr_data_disks

  name                 = "${var.resource_names.data_disk_prefix}${each.value.vm_key}-data${each.value.lun}"
  location             = azurerm_resource_group.this.location
  resource_group_name  = azurerm_resource_group.this.name
  storage_account_type = each.value.disk_sku
  create_option        = var.compute_settings.data_disk_create_option
  disk_size_gb         = each.value.size_gb
  tags                 = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "dr_data" {
  for_each = local.dr_data_disks

  managed_disk_id    = azurerm_managed_disk.dr_data[each.key].id
  virtual_machine_id = azurerm_windows_virtual_machine.dr[each.value.vm_key].id
  lun                = each.value.lun
  caching            = var.compute_settings.data_disk_caching
}
