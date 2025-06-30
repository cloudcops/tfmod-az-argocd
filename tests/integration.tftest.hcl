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
    condition     = helm_release.argocd.namespace == "argocd"
    error_message = "ArgoCD helm release not in correct namespace."
  }

  assert {
    condition     = kubernetes_namespace.argocd.metadata[0].name == "argocd"
    error_message = "ArgoCD namespace not created correctly."
  }


  # Test App of Apps deployment
  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed != null
    error_message = "App of Apps manifest not created."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.kind == "Application"
    error_message = "App of Apps is not an ArgoCD Application."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.yaml_body_parsed.metadata.name == "app-of-apps"
    error_message = "App of Apps name not correct."
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
