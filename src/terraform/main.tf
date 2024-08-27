resource "random_string" "main" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_resource_group" "main" {
  name     = "rg-ad-domain-services-${var.domain_dnsname}-${var.primary_region}-${random_string.main.result}"
  location = var.primary_region
}

