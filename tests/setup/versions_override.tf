terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
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
  subscription_id                 = "90d6584a-70ce-4e7f-835f-b9a8beee820f"
  tenant_id                       = "501655c0-c0b2-4265-bf84-aa957f7272cf"
  resource_provider_registrations = "none"
  features {}
}
