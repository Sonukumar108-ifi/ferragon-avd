resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.frontdoor.name
  resource_group_name = azurerm_resource_group.this.name
  sku_name            = var.frontdoor.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.frontdoor.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = var.frontdoor.origin_group_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = var.frontdoor.load_balancing_sample_size
    successful_samples_required = var.frontdoor.load_balancing_successful_samples_required
  }

  health_probe {
    path                = var.frontdoor.health_probe_path
    request_type        = var.frontdoor.health_probe_request_type
    protocol            = var.frontdoor.health_probe_protocol
    interval_in_seconds = var.frontdoor.health_probe_interval_in_seconds
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  name                           = var.frontdoor.origin_name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  enabled                        = var.frontdoor.origin_enabled
  host_name                      = var.frontdoor.origin_hostname
  origin_host_header             = var.frontdoor.origin_hostname
  http_port                      = var.frontdoor.origin_http_port
  https_port                     = var.frontdoor.origin_https_port
  priority                       = var.frontdoor.origin_priority
  weight                         = var.frontdoor.origin_weight
  certificate_name_check_enabled = var.frontdoor.certificate_name_check_enabled
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = var.frontdoor.route_name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this.id]

  supported_protocols    = var.frontdoor.supported_protocols
  patterns_to_match      = var.frontdoor.patterns_to_match
  forwarding_protocol    = var.frontdoor.forwarding_protocol
  https_redirect_enabled = var.frontdoor.https_redirect_enabled
  link_to_default_domain = var.frontdoor.link_to_default_domain
}
