# Terraform Module: `argocd`

## Overview
This module creates ArgoCD for a Kubernetes cluster and configures:
- SSO via Azure Entra ID
- GitHub App integration for notifications and deployments
- Dynamic notification configuration for Helm based ArgoCD apps using annotations `notifications.argoproj.io/github.sha=<full_commit_sha>` & `notifications.argoproj.io/github.repo=<github_repo_path>` on `Application` manifests
- Resource limits and metrics

Also implements a `wrapper` module so it can be consumed easier via Terragrunt.

## Example usage

```hcl
module "argocd" {
  source = "../modules/argocd"

  # Basic configuration
  argocd_chart_version = "8.1.2"
  repo_revision        = "main"
  repo_url             = "https://github.com/example/argocd-repo.git"
  url                  = "argocd.example.com"
  app_path             = "argocd-k8s-apps/overlays/dev"
  app_environment      = "dev"
  tls_enabled          = true
  ingress_class_name   = "nginx"

  # GitHub App configuration
  argocd_notification_url_for_github = "https://dev.example.com"
  github_access = {
    "0" = {
      name            = "argocd-github-app"
      url             = "https://github.com/example"
      app_id          = "123456"
      installation_id = "78910"
      private_key     = "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
    }
  }

  # Azure Entra ID SSO
  sp_client_id     = "your-client-id"
  sp_client_secret = "your-client-secret"
  idp_endpoint     = "https://login.microsoftonline.com/<tenant_id>/v2.0"
  idp_argocd_name  = "Azure"

  # RBAC configuration
  default_role = "readonly"
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
