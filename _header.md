# Terraform Module: `argocd`

## Overview
This module creates ArgoCD for an Azure AKS cluster in Azure.

## Example usage

```
module "argocd" {
  source       = "../modules/argocd"
  argocd_version     = "v2.10.7"
  repo_revision      = "main"
  repo_url           = "https://git.immonow.at/now/dev-ops/continuous-deployments/projects/argocd-cluster-apps.git"
  url                = "argocd.example.com"
  sp_client_id                = "..."
  sp_client_secret            = "..."
  cluster_name                = "..."
  cluster_resource_group_name = "..."
  tls_enabled        = true
  ingress_class_name = "nginx-public"
  app_path           = "overlays/tests"
  idp_endpoint       = "https://login.microsoftonline.com/39d11cc9-3e65-4ac2-938b-9e5264b7a7ce/v2.0"
  access_token_secret_configuration = {
    "0" = {
      url      = "https://git.immonow.at/now/dev-ops/continuous-deployments/projects/argocd-cluster-apps.git"
      username = "token"
      name     = "argocd-cluster-apps"
      password = "..."
      type     = "git"
    }
    "1" = {
      url      = "https://git.immonow.at/api/v4/projects/99/packages/helm/generic"
      username = "token"
      name     = "helm-charts"
      password = "..."
      type     = "helm"
    }
  }
  rbac4groups = [
    {
      name = "sg-now-devops"
      role = "admin"
    },
    {
      name = "sg-now-developer"
      role = "reader"
    }
  ]
}
```
