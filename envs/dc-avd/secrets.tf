resource "random_password" "dc_admin" {
  length      = 24
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

resource "random_password" "avd_admin" {
  length      = 24
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}

resource "random_password" "vpn_shared_key" {
  length      = 32
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
  special     = true
}