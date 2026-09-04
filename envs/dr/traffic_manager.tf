resource "azurerm_public_ip" "dr_endpoint" {
  for_each            = var.dr_vms
  name                = "${var.resource_names.public_ip_prefix}${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = var.traffic_manager_settings.public_ip_allocation_method
  sku                 = var.traffic_manager_settings.public_ip_sku
  tags                = var.tags
}

resource "azurerm_traffic_manager_profile" "this" {
  name                   = var.resource_names.traffic_manager_profile
  resource_group_name    = azurerm_resource_group.this.name
  traffic_routing_method = var.traffic_manager_settings.routing_method
  tags                   = var.tags

  dns_config {
    relative_name = "${var.resource_names.traffic_manager_dns_prefix}${random_id.tm_suffix.hex}"
    ttl           = var.traffic_manager_settings.dns_ttl
  }

  monitor_config {
    protocol                     = var.traffic_manager_settings.monitor_protocol
    port                         = var.traffic_manager_settings.monitor_port
    path                         = var.traffic_manager_settings.monitor_path
    interval_in_seconds          = var.traffic_manager_settings.monitor_interval_seconds
    timeout_in_seconds           = var.traffic_manager_settings.monitor_timeout_seconds
    tolerated_number_of_failures = var.traffic_manager_settings.monitor_tolerated_failures
  }
}

resource "random_id" "tm_suffix" {
  byte_length = var.traffic_manager_settings.random_suffix_byte_length
}

resource "azurerm_traffic_manager_azure_endpoint" "dr" {
  for_each           = var.dr_vms
  name               = "${var.resource_names.dr_endpoint_prefix}${each.key}"
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = azurerm_public_ip.dr_endpoint[each.key].id
  priority           = index(keys(var.dr_vms), each.key) + var.traffic_manager_settings.dr_priority_offset
}

# Primary-site (external) endpoints - one per DR VM, pointing at the
# matching production FQDN. Replace with real hostnames once known.
resource "azurerm_traffic_manager_external_endpoint" "primary" {
  for_each   = var.dr_vms
  name       = "${var.resource_names.primary_endpoint_prefix}${each.key}"
  profile_id = azurerm_traffic_manager_profile.this.id
  target     = "${each.key}.${var.traffic_manager_settings.primary_fqdn_suffix}"
  priority   = index(keys(var.dr_vms), each.key) + var.traffic_manager_settings.primary_priority_offset
}
