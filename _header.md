# Terraform Module: `argocd`

## Overview
This module creates ArgoCD for a Kubernetes cluster and configures SSO via Azure Entra ID.

## Example usage

```
module "argocd" {
  source       = "../modules/argocd"
  argocd_version     = "v3.0.0"
  repo_revision      = "main"
  repo_url           = "https://example.com/argocd-repo.git"
  url                = "argocd.example.com"
  sp_client_id                = "..."
  sp_client_secret            = "..."
  cluster_name                = "..."
  cluster_resource_group_name = "..."
  tls_enabled        = true
  ingress_class_name = "nginx-public"
  app_path           = "overlays/dev"
  idp_endpoint       = "https://login.microsoftonline.com/<your_tenant_id>/v2.0"
  access_token_secret_configuration = {
    "0" = {
      url      = "https://example.com/argocd-repo.git"
      username = "token"
      name     = "argocd-cluster-apps"
      password = "..."
      type     = "git"
    }
    "1" = {
      url      = "https://example.com/helm-repo.git"
      username = "token"
      name     = "helm-charts"
      password = "..."
      type     = "helm"
    }
  }
  rbac4groups = [
    {
      name = "sg-admin" # entra id group name
      role = "admin"
    },
    {
      name = "sg-developer"
      role = "reader"
    }
  ]
}
```
