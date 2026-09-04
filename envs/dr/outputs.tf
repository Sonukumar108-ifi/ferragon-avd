output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "dr_vm_ids" {
  value = { for k, v in azurerm_windows_virtual_machine.dr : k => v.id }
}

output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.this.fqdn
}

output "asr_vault_name" {
  value = azurerm_recovery_services_vault.asr.name
}
