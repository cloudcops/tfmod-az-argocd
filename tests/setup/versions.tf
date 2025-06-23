# DO NOT EDIT; MANAGED BY TERRAFORM
# create override.tf file if you want to override specific values or add providers
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.105.0"
    }
  }
}

provider "azurerm" {
  subscription_id            = "85d71b04-6605-42a0-8cc2-a8ccb374fdb9"
  tenant_id                  = "a2727b52-014e-4273-ba69-33db2948ea02"
  skip_provider_registration = true
  features {}
}
