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

run "apply" {
  command = apply

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

  # Test ArgoCD Helm deployment status
  assert {
    condition     = helm_release.argocd.status == "deployed"
    error_message = "ArgoCD helm release not deployed successfully."
  }

  assert {
    condition     = output.argocd_namespace == "argocd"
    error_message = "ArgoCD namespace not created correctly."
  }

  assert {
    condition     = output.argocd_helm_release_name == "argocd"
    error_message = "ArgoCD Helm release name not correct."
  }

  assert {
    condition     = output.argocd_helm_release_version == var.argocd_chart_version
    error_message = "ArgoCD Helm chart version not correct."
  }

  # Test rendered values are properly deployed
  assert {
    condition     = length(output.argocd_helm_values) > 100
    error_message = "ArgoCD Helm values seem too short - template may not be rendering properly."
  }

  assert {
    condition     = contains(output.argocd_helm_values, "enabled: true")
    error_message = "ArgoCD configurations not properly enabled in deployed values."
  }


  # Test App of Apps deployment via output
  assert {
    condition     = output.app_of_apps_manifest != null
    error_message = "App of Apps manifest not created."
  }

  assert {
    condition     = output.app_of_apps_manifest.kind == "Application"
    error_message = "App of Apps is not an ArgoCD Application."
  }

  assert {
    condition     = output.app_of_apps_manifest.metadata.name == "app-of-apps"
    error_message = "App of Apps name not correct."
  }

  assert {
    condition     = output.app_of_apps_manifest.spec.source.repoURL == var.repo_url
    error_message = "App of Apps repository URL not correct."
  }

  assert {
    condition     = output.app_of_apps_manifest.spec.syncPolicy.automated.prune == true
    error_message = "App of Apps automated pruning not enabled."
  }

  assert {
    condition     = length(output.app_of_apps_manifest.spec.syncPolicy.syncOptions) >= 4
    error_message = "App of Apps does not have sufficient sync options configured."
  }

  # Test resource limits
  assert {
    condition     = kubernetes_limit_range.default_resources.metadata[0].name == "limit-range-ns-argocd"
    error_message = "Limit range not created with correct name."
  }

  assert {
    condition     = kubernetes_limit_range.default_resources.spec[0].limit[0].type == "Container"
    error_message = "Limit range not configured for containers."
  }

  # Test time sleep for CRD readiness
  assert {
    condition     = time_sleep.wait_for_crds.create_duration == "60s"
    error_message = "CRD wait time not configured correctly."
  }
}
