terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.51.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.29.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.28.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1"
    }
  }
}

provider "kubectl" {
  host                   = var.kubernetes_host
  client_certificate     = var.kubernetes_client_certificate
  client_key             = var.kubernetes_client_key
  cluster_ca_certificate = var.kubernetes_cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host                   = var.kubernetes_host
  client_certificate     = var.kubernetes_client_certificate
  client_key             = var.kubernetes_client_key
  cluster_ca_certificate = var.kubernetes_cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_host
    client_certificate     = var.kubernetes_client_certificate
    client_key             = var.kubernetes_client_key
    cluster_ca_certificate = var.kubernetes_cluster_ca_certificate
  }
}
