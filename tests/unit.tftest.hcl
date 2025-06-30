provider "azurerm" {
  subscription_id                 = var.subscription_id
  tenant_id                       = var.tenant_id
  resource_provider_registrations = "none"
  features {}
}

run "setup" {
  module {
    source = "./tests/setup"
  }
}

variables {
  argocd_chart_version               = "8.1.2"
  repo_revision                      = "main"
  repo_url                           = "https://github.com/example/test-argocd-repo"
  url                                = "argocd-test.example.com"
  tls_enabled                        = true
  ingress_class_name                 = "nginx"
  app_path                           = "overlays/dev"
  idp_argocd_name                    = "tf_test_Azure"
  idp_endpoint                       = "login.microsoftonline.com/501655c0-c0b2-4265-bf84-aa957f7272cf/v2.0"
  idp_argocd_allowed_oauth_scopes    = ["email", "openid", "profile"]
  rbac4groups                        = []
  default_role                       = "readonly"
  p_role                             = "no-access"
  log_level                          = "info"
  argocd_notification_url_for_github = "http://example.com/notification"
}

run "plan" {
  command = plan

  variables {
    sp_client_id     = run.setup.client_id
    sp_client_secret = run.setup.password
    github_access = {
      "0" = {
        url             = "https://github.com/example/test-argocd-repo"
        name            = "token"
        app_id          = run.setup.github_app_id
        installation_id = run.setup.github_installation_id
        private_key     = run.setup.github_private_key
      }
    }
    kubernetes_host                   = run.setup.host
    kubernetes_client_certificate     = run.setup.client_certificate
    kubernetes_client_key             = run.setup.client_key
    kubernetes_cluster_ca_certificate = run.setup.cluster_ca_certificate
  }

  # Test basic resource creation
  assert {
    condition     = kubernetes_namespace.argocd.metadata[0].name == "argocd"
    error_message = "ArgoCD namespace not planned correctly."
  }

  assert {
    condition     = helm_release.argocd.name == "argocd"
    error_message = "ArgoCD helm release name not correct."
  }

  assert {
    condition     = helm_release.argocd.chart == "argo-cd"
    error_message = "ArgoCD helm chart not correct."
  }

  assert {
    condition     = helm_release.argocd.version == var.argocd_chart_version
    error_message = "ArgoCD helm chart version not correct."
  }

  # Test outputs are properly exposed
  assert {
    condition     = output.argocd_namespace == "argocd"
    error_message = "ArgoCD namespace output not correct."
  }

  assert {
    condition     = output.argocd_helm_release_name == "argocd"
    error_message = "ArgoCD Helm release name output not correct."
  }

  assert {
    condition     = output.argocd_helm_release_version == var.argocd_chart_version
    error_message = "ArgoCD Helm chart version output not correct."
  }

  # Test rendered Helm values contain expected configurations
  assert {
    condition     = length(output.argocd_helm_values) > 0
    error_message = "ArgoCD Helm values output is empty."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "domain: ${var.url}")
    error_message = "ArgoCD URL not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "name: ${var.idp_argocd_name}")
    error_message = "IDP name not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "server.log.level: ${var.log_level}")
    error_message = "Log level not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "policy.default: ${var.default_role}")
    error_message = "Default role not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "role:${var.p_role}")
    error_message = "P role not found in rendered values."
  }

  # Test OIDC configuration
  assert {
    condition     = contains(output.argocd_helm_values, "oidc.config:")
    error_message = "OIDC configuration not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "issuer: https://${var.idp_endpoint}")
    error_message = "OIDC issuer not found in rendered values."
  }

  # Test secret references (not actual secrets)
  assert {
    condition     = contains(output.argocd_helm_values, "$oidc.clientSecret")
    error_message = "OIDC client secret reference not found in rendered values."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "$github-privateKey")
    error_message = "GitHub private key reference not found in rendered values."
  }

  # Test app-of-apps manifest structure
  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.kind == "Application"
    error_message = "App of Apps is not an ArgoCD Application."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.metadata.name == "app-of-apps"
    error_message = "App of Apps name not correct."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.spec.source.repoURL == var.repo_url
    error_message = "App of Apps repo URL not correct."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.spec.source.path == var.app_path
    error_message = "App of Apps path not correct."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.spec.syncPolicy.automated.prune == true
    error_message = "App of Apps sync policy prune not enabled."
  }

  # Test limit range configuration
  assert {
    condition     = kubernetes_limit_range.default_resources.metadata[0].name == "limit-range-ns-argocd"
    error_message = "Limit range name not correct."
  }

  assert {
    condition     = output.limit_range_config.name == "limit-range-ns-argocd"
    error_message = "Limit range name output not correct."
  }

  assert {
    condition     = output.limit_range_config.namespace == "argocd"
    error_message = "Limit range namespace output not correct."
  }
}
