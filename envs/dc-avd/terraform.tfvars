tenant_id       = "1c8672ad-d9cc-4f59-b839-90be132d96ab"
subscription_id = "a011ac46-a4b0-4d1a-a49a-24f4088483a0"

location = "centralindia"

tags = {
  project     = "Ferragon"
  environment = "primary-dc-avd"
  managed_by  = "terraform"
}

resource_names = {
  resource_group               = "rg-ferragon-dc"
  virtual_network              = "vnet-ferragon-dc"
  dc_network_security_group    = "nsg-ferragon-dc-dc"
  avd_network_security_group   = "nsg-ferragon-avd"
  dc_network_interface         = "nic-ferragon-secondarydc"
  dc_ip_configuration          = "internal"
  dc_virtual_machine           = "vm-secondarydc"
  dc_computer                  = "SECDC01"
  dc_os_disk                   = "osdisk-secondarydc"
  dc_data_disk                 = "disk-secondarydc-data"
  avd_workspace                = "vdws-ferragon-dc"
  avd_host_pool_prefix         = "hp-ferragon-dc-"
  avd_application_group_prefix = "dag-ferragon-dc"
  avd_network_interface_prefix = "nic-ferragon-dc-"
  avd_virtual_machine_prefix   = "vm-"
  avd_os_disk_prefix           = "osdisk-ferragon-dc"
  avd_ip_configuration         = "internal"
  avd_agent_extension          = "AddSessionHost"
  storage_account_prefix       = "stferragondc"
  storage_share                = "fslogix-profiles"
  firewall_public_ip           = "pip-ferragon-fw"
  firewall                     = "afw-ferragon-dc"
  firewall_ip_configuration    = "fw-ipconfig"
  firewall_rule_collection     = "allow-basic-outbound"
  firewall_rule                = "allow-dns-https"
  vpn_public_ip                = "pip-ferragon-dc-vpngw"
  vpn_gateway                  = "vpngw-ferragon-dc"
  vpn_ip_configuration         = "vnetGatewayConfig"
  local_network_gateway        = "lng-ferragon-dc-onprem"
  vpn_connection               = "conn-ferragon-dc-onprem"
  recovery_vault               = "rsv-ferragon-dc"
  dc_backup_policy             = "bkp-policy-secondarydc"
  file_share_backup_policy     = "bkp-policy-azurefiles"
  log_analytics_workspace      = "log-ferragon-dc"
  application_insights         = "appi-ferragon-dc"
  dc_diagnostic_setting        = "diag-secondarydc"
  firewall_diagnostic_setting  = "diag-firewall"
}

vnet_address_space = ["10.10.0.0/16"]
subnet_config = {
  "snet-dc"             = "10.10.1.0/24"
  "snet-avd"            = "10.10.2.0/24"
  "AzureFirewallSubnet" = "10.10.3.0/26"
  "GatewaySubnet"       = "10.10.255.0/27"
}
subnet_keys = {
  dc       = "snet-dc"
  avd      = "snet-avd"
  firewall = "AzureFirewallSubnet"
  gateway  = "GatewaySubnet"
}

dc_vm_size           = "Standard_D4s_v5"
dc_admin_username    = "azadmin"
dc_data_disk_size_gb = 128
dc_settings = {
  private_ip_allocation          = "Dynamic"
  license_type                   = "Windows_Server"
  os_disk_caching                = "ReadWrite"
  os_disk_storage_account_type   = "StandardSSD_LRS"
  data_disk_storage_account_type = "StandardSSD_LRS"
  data_disk_create_option        = "Empty"
  data_disk_lun                  = 0
  data_disk_caching              = "ReadWrite"
  image_publisher                = "MicrosoftWindowsServer"
  image_offer                    = "WindowsServer"
  image_sku                      = "2022-datacenter-azure-edition"
  image_version                  = "latest"
  zone                           = "1"
}

frontdoor = {
  name                                       = "afd-ferragon"
  endpoint_name                              = "afd-ep-ferragon"
  origin_group_name                          = "og-ferragon"
  origin_name                                = "origin-ferragon"
  route_name                                 = "route-ferragon"
  sku_name                                   = "Standard_AzureFrontDoor"
  load_balancing_sample_size                 = 4
  load_balancing_successful_samples_required = 3
  health_probe_path                          = "/"
  health_probe_request_type                  = "HEAD"
  health_probe_protocol                      = "Https"
  health_probe_interval_in_seconds           = 100
  origin_enabled                             = true
  origin_hostname                            = "app.ferragon-example.com"
  origin_http_port                           = 80
  origin_https_port                          = 443
  origin_priority                            = 1
  origin_weight                              = 1000
  certificate_name_check_enabled             = true
  supported_protocols                        = ["Http", "Https"]
  patterns_to_match                          = ["/*"]
  forwarding_protocol                        = "HttpsOnly"
  https_redirect_enabled                     = true
  link_to_default_domain                     = true
}

avd_host_pools = {
  "hp-20users" = {
    vm_size               = "Standard_D4s_v5"
    session_host_count    = 2
    max_sessions_per_host = 10
  }
  "hp-15users" = {
    vm_size               = "Standard_D4s_v5"
    session_host_count    = 1
    max_sessions_per_host = 8
  }
  "hp-10users" = {
    vm_size               = "Standard_D4s_v5"
    session_host_count    = 1
    max_sessions_per_host = 10
  }
}

avd_admin_username = "avdadmin"
avd_settings = {
  workspace_friendly_name      = "Ferragon AVD Workspace"
  host_pool_type               = "Pooled"
  load_balancer_type           = "BreadthFirst"
  start_vm_on_connect          = true
  registration_token_lifetime  = "48h"
  application_group_type       = "Desktop"
  application_group_suffix     = " Desktop"
  vm_name_max_length           = 12
  computer_name_max_length     = 12
  ip_allocation                = "Dynamic"
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  image_publisher              = "MicrosoftWindowsDesktop"
  image_offer                  = "office-365"
  image_sku                    = "win11-23h2-avd-m365"
  image_version                = "latest"
  agent_publisher              = "Microsoft.Powershell"
  agent_type                   = "DSC"
  agent_type_handler_version   = "2.73"
  agent_auto_upgrade_minor     = true
  agent_modules_url            = "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_1.0.02714.342.zip"
  agent_configuration_function = "Configuration.ps1\\AddSessionHost"
  zone                         = "1"
}

files_provisioned_gb = 300
storage_settings = {
  random_suffix_length     = 6
  random_suffix_special    = false
  random_suffix_upper      = false
  account_tier             = "Premium"
  account_replication_type = "LRS"
  account_kind             = "FileStorage"
  share_access_tier        = "Premium"
  share_protocol           = "SMB"
}

firewall_sku_tier = "Standard"
firewall_settings = {
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  sku_name                    = "AZFW_VNet"
  rule_collection_priority    = 100
  rule_collection_action      = "Allow"
  destination_ports           = ["53", "443"]
  destination_addresses       = ["*"]
  protocols                   = ["TCP", "UDP"]
}

vpn_gateway_sku          = "VpnGw1AZ"
onprem_gateway_public_ip = "203.0.113.1"
onprem_address_space     = ["192.168.0.0/16"]
vpn_settings = {
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  gateway_type                = "Vpn"
  vpn_type                    = "RouteBased"
  private_ip_allocation       = "Dynamic"
  connection_type             = "IPsec"
  public_ip_zones             = ["1", "2", "3"]
}

backup_settings = {
  vault_sku                   = "Standard"
  storage_mode_type           = "LocallyRedundant"
  soft_delete_enabled         = true
  vm_frequency                = "Daily"
  vm_time                     = "23:00"
  vm_retention_daily_count    = 30
  files_frequency             = "Daily"
  files_time                  = "23:00"
  files_retention_daily_count = 30
}

monitoring_settings = {
  log_analytics_sku            = "PerGB2018"
  log_analytics_retention_days = 30
  application_type             = "web"
  application_retention_days   = 90
  metric_category              = "AllMetrics"
  firewall_log_category_group  = "allLogs"
}

defender_settings = {
  tier                  = "Standard"
  servers_subplan       = "P2"
  virtual_machines_type = "VirtualMachines"
  storage_accounts_type = "StorageAccounts"
  key_vaults_type       = "KeyVaults"
}