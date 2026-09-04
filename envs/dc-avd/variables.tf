variable "location" {
  description = "Primary Azure region"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
}

variable "resource_names" {
  description = "Explicit Azure resource and child configuration names"
  type = object({
    resource_group               = string
    virtual_network              = string
    dc_network_security_group    = string
    avd_network_security_group   = string
    dc_network_interface         = string
    dc_ip_configuration          = string
    dc_virtual_machine           = string
    dc_computer                  = string
    dc_os_disk                   = string
    dc_data_disk                 = string
    avd_workspace                = string
    avd_host_pool_prefix         = string
    avd_application_group_prefix = string
    avd_network_interface_prefix = string
    avd_virtual_machine_prefix   = string
    avd_os_disk_prefix           = string
    avd_ip_configuration         = string
    avd_agent_extension          = string
    storage_account_prefix       = string
    storage_share                = string
    firewall_public_ip           = string
    firewall                     = string
    firewall_ip_configuration    = string
    firewall_rule_collection     = string
    firewall_rule                = string
    vpn_public_ip                = string
    vpn_gateway                  = string
    vpn_ip_configuration         = string
    local_network_gateway        = string
    vpn_connection               = string
    recovery_vault               = string
    dc_backup_policy             = string
    file_share_backup_policy     = string
    log_analytics_workspace      = string
    application_insights         = string
    dc_diagnostic_setting        = string
    firewall_diagnostic_setting  = string
  })
}

variable "subnet_keys" {
  description = "Keys used to select functional subnets from subnet_config"
  type = object({
    dc       = string
    avd      = string
    firewall = string
    gateway  = string
  })
}

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------
variable "vnet_address_space" {
  type = list(string)
}

variable "subnet_config" {
  description = "Subnets to create: name => cidr"
  type        = map(string)
}

# ---------------------------------------------------------------------------
# Secondary Domain Controller VM (BOQ: "Secondary DC", D4s_v5, Windows)
# ---------------------------------------------------------------------------
variable "dc_vm_size" {
  type = string
}

variable "dc_admin_username" {
  type = string
}

variable "dc_data_disk_size_gb" {
  description = "BOQ: Standard SSD LRS, 128 GB data disk"
  type        = number
}

variable "dc_settings" {
  description = "Domain controller VM disk, licensing, and image settings"
  type = object({
    private_ip_allocation          = string
    license_type                   = string
    os_disk_caching                = string
    os_disk_storage_account_type   = string
    data_disk_storage_account_type = string
    data_disk_create_option        = string
    data_disk_lun                  = number
    data_disk_caching              = string
    image_publisher                = string
    image_offer                    = string
    image_sku                      = string
    image_version                  = string
    zone                           = string
  })
}

# ---------------------------------------------------------------------------
# VPN Gateway 
# ---------------------------------------------------------------------------
variable "vpn_gateway_sku" {
  type = string
}

variable "onprem_gateway_public_ip" {
  description = "Public IP of the on-prem VPN device (local network gateway)"
  type        = string
}

variable "onprem_address_space" {
  description = "On-prem network ranges reachable over the S2S tunnel"
  type        = list(string)
}

variable "vpn_settings" {
  description = "VPN gateway, public IP, and site-to-site connection settings"
  type = object({
    public_ip_allocation_method = string
    public_ip_sku               = string
    gateway_type                = string
    vpn_type                    = string
    private_ip_allocation       = string
    connection_type             = string
    public_ip_zones             = list(string)
  })
}

# ---------------------------------------------------------------------------
# Azure Virtual Desktop
#
# ---------------------------------------------------------------------------
variable "avd_host_pools" {
  description = "Map of AVD pooled host pools to deploy, keyed by pool name"
  type = map(object({
    vm_size               = string
    session_host_count    = number
    max_sessions_per_host = number
  }))
}

variable "avd_admin_username" {
  type = string
}

variable "avd_settings" {
  description = "AVD workspace, host pool, session host, image, and agent settings"
  type = object({
    workspace_friendly_name      = string
    host_pool_type               = string
    load_balancer_type           = string
    start_vm_on_connect          = bool
    registration_token_lifetime  = string
    application_group_type       = string
    application_group_suffix     = string
    vm_name_max_length           = number
    computer_name_max_length     = number
    ip_allocation                = string
    os_disk_caching              = string
    os_disk_storage_account_type = string
    image_publisher              = string
    image_offer                  = string
    image_sku                    = string
    image_version                = string
    agent_publisher              = string
    agent_type                   = string
    agent_type_handler_version   = string
    agent_auto_upgrade_minor     = bool
    agent_modules_url            = string
    agent_configuration_function = string
    zone                         = string
  })
}

# ---------------------------------------------------------------------------
# Azure Files
# ---------------------------------------------------------------------------
variable "files_provisioned_gb" {
  type = number
}

variable "storage_settings" {
  description = "FSLogix storage account and file share settings"
  type = object({
    random_suffix_length     = number
    random_suffix_special    = bool
    random_suffix_upper      = bool
    account_tier             = string
    account_replication_type = string
    account_kind             = string
    share_access_tier        = string
    share_protocol           = string
  })
}

# ---------------------------------------------------------------------------
# Azure Firewall 
# ---------------------------------------------------------------------------
variable "firewall_sku_tier" {
  type = string
}

variable "firewall_settings" {
  description = "Azure Firewall and outbound network rule settings"
  type = object({
    public_ip_allocation_method = string
    public_ip_sku               = string
    sku_name                    = string
    rule_collection_priority    = number
    rule_collection_action      = string
    destination_ports           = list(string)
    destination_addresses       = list(string)
    protocols                   = list(string)
  })
}

# ---------------------------------------------------------------------------
# Front Door 
# ---------------------------------------------------------------------------
variable "frontdoor" {
  description = "Azure Front Door names and routing configuration"
  type = object({
    name                                       = string
    endpoint_name                              = string
    origin_group_name                          = string
    origin_name                                = string
    route_name                                 = string
    sku_name                                   = string
    load_balancing_sample_size                 = number
    load_balancing_successful_samples_required = number
    health_probe_path                          = string
    health_probe_request_type                  = string
    health_probe_protocol                      = string
    health_probe_interval_in_seconds           = number
    origin_enabled                             = bool
    origin_hostname                            = string
    origin_http_port                           = number
    origin_https_port                          = number
    origin_priority                            = number
    origin_weight                              = number
    certificate_name_check_enabled             = bool
    supported_protocols                        = list(string)
    patterns_to_match                          = list(string)
    forwarding_protocol                        = string
    https_redirect_enabled                     = bool
    link_to_default_domain                     = bool
  })
}

variable "backup_settings" {
  description = "Recovery Services vault and backup policy settings"
  type = object({
    vault_sku                   = string
    storage_mode_type           = string
    soft_delete_enabled         = bool
    vm_frequency                = string
    vm_time                     = string
    vm_retention_daily_count    = number
    files_frequency             = string
    files_time                  = string
    files_retention_daily_count = number
  })
}

variable "monitoring_settings" {
  description = "Log Analytics, Application Insights, and diagnostics settings"
  type = object({
    log_analytics_sku            = string
    log_analytics_retention_days = number
    application_type             = string
    application_retention_days   = number
    metric_category              = string
    firewall_log_category_group  = string
  })
}

variable "defender_settings" {
  description = "Microsoft Defender for Cloud pricing resource types and tiers"
  type = object({
    tier                  = string
    servers_subplan       = string
    virtual_machines_type = string
    storage_accounts_type = string
    key_vaults_type       = string
  })
}

variable "subscription_id" {
  description = "Azure subscription ID this environment deploys into"
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID used for Azure authentication"
  type        = string
}
