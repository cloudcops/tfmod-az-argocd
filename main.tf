resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name        = "argocd"
  repository  = "https://argoproj.github.io/argo-helm"
  chart       = "argo-cd"
  version     = var.argocd_chart_version
  namespace   = kubernetes_namespace.argocd.metadata[0].name
  max_history = var.helm_release_max_history

  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      url                                = var.url
      idp_argocd_name                    = var.idp_argocd_name
      idp_endpoint                       = var.idp_endpoint
      sp_client_id                       = var.sp_client_id
      idp_argocd_allowed_oauth_scopes    = var.idp_argocd_allowed_oauth_scopes
      app_environment                    = split("/", var.app_path)[1]
      app_path                           = var.app_path
      argocd_notification_url_for_github = var.argocd_notification_url_for_github
      log_level                          = var.log_level
      default_role                       = var.default_role
      p_role                             = var.p_role
      grant_group_ids                    = local.grantGroupIds
      sp_client_secret                   = sensitive(var.sp_client_secret)
      github_private_key                 = sensitive(var.github_access["0"].private_key)
      github_repositories                = sensitive(var.github_access)
      gateway_name                       = var.gateway_name
      gateway_namespace                  = var.gateway_namespace
      gateway_listener_name              = var.gateway_listener_name
      github_app_id                      = sensitive(var.github_access["0"].app_id)
      github_installation_id             = sensitive(var.github_access["0"].installation_id)

      argocd_server_memory              = var.argocd_server_memory_limit
      argocd_server_cpu_request         = var.argocd_server_cpu_request
      argocd_controller_memory          = var.argocd_controller_memory_limit
      argocd_controller_cpu_request     = var.argocd_controller_cpu_request
      argocd_reposerver_memory          = var.argocd_reposerver_memory_limit
      argocd_reposerver_cpu_request     = var.argocd_reposerver_cpu_request
      argocd_applicationset_memory      = var.argocd_applicationset_memory_limit
      argocd_applicationset_cpu_request = var.argocd_applicationset_cpu_request
      argocd_notifications_memory       = var.argocd_notifications_memory_limit
      argocd_notifications_cpu_request  = var.argocd_notifications_cpu_request
      argocd_redis_memory               = var.argocd_redis_memory_limit
      argocd_redis_cpu_request          = var.argocd_redis_cpu_request
      argocd_dex_memory                 = var.argocd_dex_memory_limit
      argocd_dex_cpu_request            = var.argocd_dex_cpu_request

      metrics_enabled         = var.metrics_enabled
      service_monitor_enabled = var.service_monitor_enabled

      github_pr_comment_on_success_enabled = var.github_pr_comment_on_success_enabled
      github_pr_comment_on_failure_enabled = var.github_pr_comment_on_failure_enabled
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubectl_manifest" "argocd_access_token" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
      name      = "github-access-secret"
      namespace = "argocd"
    }
    type = "Opaque"
    stringData = {
      type                    = "git"
      url                     = var.github_access["0"].url
      githubAppID             = var.github_access["0"].app_id
      githubAppInstallationID = var.github_access["0"].installation_id
      githubAppPrivateKey     = var.github_access["0"].private_key
    }
  })

  sensitive_fields = [
    "stringData.githubAppPrivateKey",
    "stringData.githubAppID",
    "stringData.githubAppInstallationID"
  ]

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "notification_secrets" {
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      labels = {
        "app.kubernetes.io/component" = "notifications-controller"
        "app.kubernetes.io/name"      = "argocd-notifications-controller"
        "app.kubernetes.io/part-of"   = "argocd"
      }
      name      = "argocd-notifications-secret"
      namespace = "argocd"
    }
    type = "Opaque"
    stringData = {
      github-privateKey = var.github_access["0"].private_key
    }
  })

  sensitive_fields = [
    "stringData.github-privateKey"
  ]

  depends_on = [helm_release.argocd]
}

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = yamlencode({
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      annotations = {
        "notifications.argoproj.io/subscribe.on-deployed.github" = ""
      }
    }
    spec = {
      destination = {
        namespace = "argocd"
        server    = "https://kubernetes.default.svc"
      }
      project = "default"
      source = {
        path           = var.app_path
        repoURL        = var.repo_url
        targetRevision = var.repo_revision
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
          "FailOnSharedResource=false"
        ]
        retry = {
          limit = 10
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "30s"
          }
        }
      }
    }
  })

  depends_on = [
    kubectl_manifest.argocd_access_token,
    kubectl_manifest.notification_secrets
  ]
}
