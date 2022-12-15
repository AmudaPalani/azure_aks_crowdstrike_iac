provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  skip_provider_registration = true
  features {}
}

provider "random" {
  version = "=2.2.1"
}

provider "external" {
  version = "~> 1.1"
}

provider "null" {
  version = "= 2.1.2"
}
