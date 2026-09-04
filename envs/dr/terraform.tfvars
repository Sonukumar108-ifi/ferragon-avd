tenant_id       = "1c8672ad-d9cc-4f59-b839-90be132d96ab"
subscription_id = "a011ac46-a4b0-4d1a-a49a-24f4088483a0"

location = "eastus2"

tags = {
  project     = "Ferragon"
  environment = "dr"
  managed_by  = "terraform"
}

resource_names = {
  resource_group             = "rg-ferragon-dr"
  virtual_network            = "vnet-ferragon-dr"
  network_security_group     = "nsg-ferragon-dr"
  network_interface_prefix   = "nic-"
  ip_configuration           = "internal"
  os_disk_prefix             = "osdisk-"
  data_disk_prefix           = "disk-"
  recovery_vault             = "rsv-ferragon-dr-asr"
  replication_policy         = "policy-ferragon-dr"
  container_mapping          = "mapping-primary-to-dr"
  network_mapping            = "network-mapping-primary-to-dr"
  log_analytics_workspace    = "log-ferragon-dr"
  application_insights       = "appi-ferragon-dr"
  traffic_manager_profile    = "tm-ferragon-dr"
  public_ip_prefix           = "pip-"
  dr_endpoint_prefix         = "ep-"
  primary_endpoint_prefix    = "ep-primary-"
  traffic_manager_dns_prefix = "ferragon-erp-"
}

vnet_address_space = ["10.20.0.0/16"]
subnet_config = {
  "snet-dr" = "10.20.1.0/24"
}
dr_subnet_key = "snet-dr"

admin_username = "azadmin"
admin_password = "REPLACE_WITH_SECURE_DR_ADMIN_PASSWORD"
dr_vms = {
  "dr-erp1-flx" = {
    vm_size         = "Standard_HB120rs_v2"
    disk_sku        = "Premium_LRS"
    data_disk_count = 2
    disk_size_gb    = 128
  }
  "dr-erp2-hycal" = {
    vm_size         = "Standard_E2bds_v5"
    disk_sku        = "Premium_LRS"
    data_disk_count = 2
    disk_size_gb    = 128
  }
  "dr-erp3-fmp" = {
    vm_size         = "Standard_E4s_v3"
    disk_sku        = "Premium_LRS"
    data_disk_count = 2
    disk_size_gb    = 128
  }
  "dr-sage-acc" = {
    vm_size         = "Standard_L8s_v2"
    disk_sku        = "Premium_LRS"
    data_disk_count = 2
    disk_size_gb    = 512
  }
}
compute_settings = {
  computer_name_max_length = 15
  private_ip_allocation    = "Dynamic"
  license_type             = "Windows_Server"
  os_disk_caching          = "ReadWrite"
  image_publisher          = "MicrosoftWindowsServer"
  image_offer              = "WindowsServer"
  image_sku                = "2022-datacenter-azure-edition"
  image_version            = "latest"
  sql_license_type         = "PAYG"
  sql_connectivity_port    = 1433
  sql_connectivity_type    = "PRIVATE"
  data_disk_create_option  = "Empty"
  data_disk_caching        = "ReadWrite"
}

primary_resource_group_name = "rg-ferragon-dc"
primary_vnet_name           = "vnet-ferragon-dc"

asr_sites = {
  primary = {
    fabric_name    = "fabric-primary"
    container_name = "container-primary"
    location       = "centralus"
  }
  dr = {
    fabric_name    = "fabric-dr"
    container_name = "container-dr"
    location       = "eastus2"
  }
}
site_recovery_settings = {
  vault_sku                                 = "Standard"
  soft_delete_enabled                       = true
  source_site_key                           = "primary"
  target_site_key                           = "dr"
  recovery_point_retention_in_minutes       = 1440
  app_consistent_snapshot_frequency_minutes = 240
}

monitoring_settings = {
  log_analytics_sku            = "PerGB2018"
  log_analytics_retention_days = 30
  application_type             = "web"
  application_retention_days   = 90
}

traffic_manager_settings = {
  public_ip_allocation_method = "Static"
  public_ip_sku               = "Standard"
  routing_method              = "Priority"
  dns_ttl                     = 60
  monitor_protocol            = "HTTPS"
  monitor_port                = 443
  monitor_path                = "/"
  monitor_interval_seconds    = 30
  monitor_timeout_seconds     = 10
  monitor_tolerated_failures  = 3
  random_suffix_byte_length   = 3
  dr_priority_offset          = 10
  primary_priority_offset     = 1
  primary_fqdn_suffix         = "ferragon-example.com"
}

provider_settings = {
  recover_soft_deleted_backup_protected_vm = true
  storage_use_azuread                      = true
}