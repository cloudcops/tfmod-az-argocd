terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.97.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.29.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
  }
}
