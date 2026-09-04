resource "azurerm_virtual_desktop_workspace" "this" {
  name                = var.resource_names.avd_workspace
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  friendly_name       = var.avd_settings.workspace_friendly_name
  tags                = var.tags
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  for_each                 = var.avd_host_pools
  name                     = "${var.resource_names.avd_host_pool_prefix}${each.key}"
  location                 = azurerm_resource_group.this.location
  resource_group_name      = azurerm_resource_group.this.name
  type                     = var.avd_settings.host_pool_type
  load_balancer_type       = var.avd_settings.load_balancer_type
  friendly_name            = each.key
  maximum_sessions_allowed = each.value.max_sessions_per_host
  start_vm_on_connect      = var.avd_settings.start_vm_on_connect
  tags                     = var.tags
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  for_each        = var.avd_host_pools
  hostpool_id     = azurerm_virtual_desktop_host_pool.this[each.key].id
  expiration_date = timeadd(timestamp(), var.avd_settings.registration_token_lifetime)

  lifecycle {
    ignore_changes = [expiration_date]
  }
}

resource "azurerm_virtual_desktop_application_group" "desktop" {
  for_each = var.avd_host_pools

  name                = "${var.resource_names.avd_application_group_prefix}${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  type                = var.avd_settings.application_group_type
  host_pool_id        = azurerm_virtual_desktop_host_pool.this[each.key].id
  friendly_name       = "${each.key}${var.avd_settings.application_group_suffix}"
  tags                = var.tags
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "this" {
  for_each             = var.avd_host_pools
  workspace_id         = azurerm_virtual_desktop_workspace.this.id
  application_group_id = azurerm_virtual_desktop_application_group.desktop[each.key].id
}

# --- Session host VMs -------------------------------------------------
# Flattened map: one entry per session host across all pools, e.g.
# "hp-20users-0", "hp-20users-1", "hp-15users-0", ...
locals {
  avd_session_hosts = merge([
    for pool_name, pool in var.avd_host_pools : {
      for i in range(pool.session_host_count) :
      "${pool_name}-${i}" => {
        pool_name = pool_name
        vm_size   = pool.vm_size
        index     = i
      }
    }
  ]...)
}

resource "azurerm_network_interface" "avd" {
  for_each            = local.avd_session_hosts
  name                = "${var.resource_names.avd_network_interface_prefix}${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = var.tags

  ip_configuration {
    name                          = var.resource_names.avd_ip_configuration
    subnet_id                     = azurerm_subnet.this[var.subnet_keys.avd].id
    private_ip_address_allocation = var.avd_settings.ip_allocation
  }
}

resource "azurerm_windows_virtual_machine" "avd" {
  for_each            = local.avd_session_hosts
  name                = "${var.resource_names.avd_virtual_machine_prefix}${substr(each.key, 0, var.avd_settings.vm_name_max_length)}"
  computer_name       = upper(substr(replace(each.key, "-", ""), 0, var.avd_settings.computer_name_max_length))
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = each.value.vm_size
  admin_username      = var.avd_admin_username
  admin_password      = random_password.avd_admin.result
  zone                = var.avd_settings.zone
  tags                = merge(var.tags, { avd_host_pool = each.value.pool_name })

  network_interface_ids = [azurerm_network_interface.avd[each.key].id]

  os_disk {
    name                 = "${var.resource_names.avd_os_disk_prefix}${each.key}"
    caching              = var.avd_settings.os_disk_caching
    storage_account_type = var.avd_settings.os_disk_storage_account_type
  }

  source_image_reference {
    publisher = var.avd_settings.image_publisher
    offer     = var.avd_settings.image_offer
    sku       = var.avd_settings.image_sku
    version   = var.avd_settings.image_version
  }
}

# Registers each session host into its host pool and installs the AVD agent.
resource "azurerm_virtual_machine_extension" "avd_agent" {
  for_each                   = local.avd_session_hosts
  name                       = var.resource_names.avd_agent_extension
  virtual_machine_id         = azurerm_windows_virtual_machine.avd[each.key].id
  publisher                  = var.avd_settings.agent_publisher
  type                       = var.avd_settings.agent_type
  type_handler_version       = var.avd_settings.agent_type_handler_version
  auto_upgrade_minor_version = var.avd_settings.agent_auto_upgrade_minor
  tags                       = var.tags

  settings = jsonencode({
    modulesUrl            = var.avd_settings.agent_modules_url
    configurationFunction = var.avd_settings.agent_configuration_function
    properties = {
      hostPoolName = azurerm_virtual_desktop_host_pool.this[each.value.pool_name].name
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = azurerm_virtual_desktop_host_pool_registration_info.this[each.value.pool_name].token
    }
  })
}
