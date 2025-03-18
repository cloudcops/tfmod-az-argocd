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
  subscription_id            = "90d6584a-70ce-4e7f-835f-b9a8beee820f"
  tenant_id                  = "501655c0-c0b2-4265-bf84-aa957f7272cf"
  skip_provider_registration = true
  features {}
}
