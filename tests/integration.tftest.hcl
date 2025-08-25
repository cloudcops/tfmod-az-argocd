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

provider "kubernetes" {
  alias                  = "test"
  host                   = run.setup.host
  client_certificate     = run.setup.client_certificate
  client_key             = run.setup.client_key
  cluster_ca_certificate = run.setup.cluster_ca_certificate
}

provider "helm" {
  alias = "test"
  kubernetes = {
    host                   = run.setup.host
    client_certificate     = run.setup.client_certificate
    client_key             = run.setup.client_key
    cluster_ca_certificate = run.setup.cluster_ca_certificate
  }
}

provider "kubectl" {
  alias                  = "test"
  host                   = run.setup.host
  client_certificate     = run.setup.client_certificate
  client_key             = run.setup.client_key
  cluster_ca_certificate = run.setup.cluster_ca_certificate
  load_config_file       = false
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

  argocd_server_memory_limit         = "128Mi"
  argocd_server_cpu_request          = "50m"
  argocd_controller_memory_limit     = "512Mi"
  argocd_controller_cpu_request      = "100m"
  argocd_reposerver_memory_limit     = "128Mi"
  argocd_reposerver_cpu_request      = "50m"
  argocd_applicationset_memory_limit = "64Mi"
  argocd_applicationset_cpu_request  = "25m"
  argocd_notifications_memory_limit  = "64Mi"
  argocd_notifications_cpu_request   = "25m"
  argocd_redis_memory_limit          = "64Mi"
  argocd_redis_cpu_request           = "25m"
  argocd_dex_memory_limit            = "64Mi"
  argocd_dex_cpu_request             = "25m"
}

run "apply" {
  command = apply

  providers = {
    kubernetes = kubernetes.test
    helm       = helm.test
    kubectl    = kubectl.test
  }

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
    condition     = kubectl_manifest.app_of_apps.api_version == "argoproj.io/v1alpha1"
    error_message = "App of Apps API version not correct."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.kind == "Application"
    error_message = "App of Apps is not an ArgoCD Application."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.name == "app-of-apps"
    error_message = "App of Apps name not correct."
  }

  assert {
    condition     = kubectl_manifest.app_of_apps.namespace == "argocd"
    error_message = "App of Apps namespace not correct."
  }

  # Test Terraform-managed repository secret
  assert {
    condition     = kubectl_manifest.argocd_access_token.name == "github-access-secret"
    error_message = "GitHub access token secret name not correct."
  }

  assert {
    condition     = kubectl_manifest.argocd_access_token.namespace == "argocd"
    error_message = "GitHub access token secret namespace not correct."
  }

  # Test Terraform-managed notification secret
  assert {
    condition     = kubectl_manifest.notification_secrets.name == "argocd-notifications-secret"
    error_message = "Notifications secret name not correct."
  }

  assert {
    condition     = kubectl_manifest.notification_secrets.namespace == "argocd"
    error_message = "Notifications secret namespace not correct."
  }
}
