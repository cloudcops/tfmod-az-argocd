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
