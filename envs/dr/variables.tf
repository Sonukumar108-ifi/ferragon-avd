variable "location" {
  description = "DR region (BOQ: East US 2)"
  type        = string
}

variable "tags" {
  type = map(string)
}

variable "resource_names" {
  description = "Explicit names and generated-name prefixes for DR resources"
  type = object({
    resource_group             = string
    virtual_network            = string
    network_security_group     = string
    network_interface_prefix   = string
    ip_configuration           = string
    os_disk_prefix             = string
    data_disk_prefix           = string
    recovery_vault             = string
    replication_policy         = string
    container_mapping          = string
    network_mapping            = string
    log_analytics_workspace    = string
    application_insights       = string
    traffic_manager_profile    = string
    public_ip_prefix           = string
    dr_endpoint_prefix         = string
    primary_endpoint_prefix    = string
    traffic_manager_dns_prefix = string
  })
}

variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_config" {
  type = map(string)
}

variable "dr_subnet_key" {
  description = "Key of the DR VM subnet in subnet_config"
  type        = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  description = "Local admin password for all DR VMs"
  type        = string
  sensitive   = true

  validation {
    condition     = var.admin_password != "REPLACE_WITH_SECURE_DR_ADMIN_PASSWORD"
    error_message = "Replace admin_password in terraform.tfvars before running plan or apply."
  }
}

# BOQ DR VMs: name => { size, os_disk_gb, data_disk_count, data_disk_gb, data_disk_tier }
variable "dr_vms" {
  type = map(object({
    vm_size         = string
    disk_sku        = string # "P10" (128GB) or "P20" (512GB) etc. mapped to storage_account_type
    data_disk_count = number
    disk_size_gb    = number
  }))
}

variable "compute_settings" {
  description = "DR VM image, disk, networking, and SQL settings"
  type = object({
    computer_name_max_length = number
    private_ip_allocation    = string
    license_type             = string
    os_disk_caching          = string
    image_publisher          = string
    image_offer              = string
    image_sku                = string
    image_version            = string
    sql_license_type         = string
    sql_connectivity_port    = number
    sql_connectivity_type    = string
    data_disk_create_option  = string
    data_disk_caching        = string
  })
}

# ---------------------------------------------------------------------------
# Azure Site Recovery
# ---------------------------------------------------------------------------
variable "primary_resource_group_name" {
  description = "Resource group name of the primary site (from the dc-avd environment)"
  type        = string
}

variable "primary_vnet_name" {
  type = string
}

variable "asr_sites" {
  description = "Primary and DR Site Recovery fabrics and protection containers"
  type = map(object({
    fabric_name    = string
    container_name = string
    location       = string
  }))
}

variable "site_recovery_settings" {
  description = "Recovery Services vault and replication policy settings"
  type = object({
    vault_sku                                 = string
    soft_delete_enabled                       = bool
    source_site_key                           = string
    target_site_key                           = string
    recovery_point_retention_in_minutes       = number
    app_consistent_snapshot_frequency_minutes = number
  })
}

variable "monitoring_settings" {
  description = "Log Analytics and Application Insights settings"
  type = object({
    log_analytics_sku            = string
    log_analytics_retention_days = number
    application_type             = string
    application_retention_days   = number
  })
}

variable "traffic_manager_settings" {
  description = "Traffic Manager profile, health probe, endpoint, and DNS settings"
  type = object({
    public_ip_allocation_method = string
    public_ip_sku               = string
    routing_method              = string
    dns_ttl                     = number
    monitor_protocol            = string
    monitor_port                = number
    monitor_path                = string
    monitor_interval_seconds    = number
    monitor_timeout_seconds     = number
    monitor_tolerated_failures  = number
    random_suffix_byte_length   = number
    dr_priority_offset          = number
    primary_priority_offset     = number
    primary_fqdn_suffix         = string
  })
}

variable "provider_settings" {
  description = "AzureRM provider feature settings"
  type = object({
    recover_soft_deleted_backup_protected_vm = bool
    storage_use_azuread                      = bool
  })
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used for Azure authentication"
  type        = string
}
