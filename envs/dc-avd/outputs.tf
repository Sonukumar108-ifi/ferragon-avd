output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "dc_vm_private_ip" {
  value = azurerm_network_interface.dc.private_ip_address
}

output "vpn_gateway_public_ip" {
  value = azurerm_public_ip.vpngw.ip_address
}

output "firewall_public_ip" {
  value = azurerm_public_ip.firewall.ip_address
}

output "avd_workspace_name" {
  value = azurerm_virtual_desktop_workspace.this.name
}

output "avd_host_pool_names" {
  value = { for k, v in azurerm_virtual_desktop_host_pool.this : k => v.name }
}

output "storage_account_name" {
  value = azurerm_storage_account.files.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}

output "frontdoor_endpoint_hostname" {
  value = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "dc_admin_password" {
  value     = random_password.dc_admin.result
  sensitive = true
}

output "avd_admin_password" {
  value     = random_password.avd_admin.result
  sensitive = true
}

output "vpn_shared_key" {
  value     = random_password.vpn_shared_key.result
  sensitive = true
}
