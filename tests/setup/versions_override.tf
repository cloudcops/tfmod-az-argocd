terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.51.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
provider "azurerm" {
  subscription_id                 = "85d71b04-6605-42a0-8cc2-a8ccb374fdb9"
  tenant_id                       = "a2727b52-014e-4273-ba69-33db2948ea02"
  resource_provider_registrations = "none"
  features {}
}
