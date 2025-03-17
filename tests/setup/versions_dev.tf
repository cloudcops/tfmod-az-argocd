provider "azurerm" {
  subscription_id                 = "ed0262c2-eeb4-42a1-b9a5-a97632f229aa"
  tenant_id                       = "501655c0-c0b2-4265-bf84-aa957f7272cf"
  resource_provider_registrations = "none"
  features {}

  alias = "dev"
}
