# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD Helm Release - Complete configuration with all settings
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Wait for CRDs to be ready and ensure proper deployment
  wait             = true
  wait_for_jobs    = true
  timeout          = 600
  create_namespace = false # We create it explicitly above

  values = [
    templatefile("${path.module}/templates/values.yaml.tpl", {
      url                                = var.url
      idp_argocd_name                    = var.idp_argocd_name
      idp_endpoint                       = var.idp_endpoint
      sp_client_id                       = sensitive(var.sp_client_id)
      idp_argocd_allowed_oauth_scopes    = var.idp_argocd_allowed_oauth_scopes
      app_environment                    = split("/", var.app_path)[1]
      app_path                           = var.app_path
      argocd_notification_url_for_github = var.argocd_notification_url_for_github
      server_insecure                    = tostring(!var.tls_enabled)
      log_level                          = var.log_level
      default_role                       = var.default_role
      p_role                             = var.p_role
      grant_group_ids                    = local.grantGroupIds
      sp_client_secret                   = sensitive(var.sp_client_secret)
      github_private_key                 = sensitive(var.github_access["0"].private_key)
      github_repositories                = sensitive(var.github_access)
      ingress_class_name                 = var.ingress_class_name
      tls_enabled                        = var.tls_enabled
      github_app_id                      = sensitive(var.github_access["0"].app_id)
      github_installation_id             = sensitive(var.github_access["0"].installation_id)
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Limit Range for ArgoCD namespace
resource "kubernetes_limit_range" "default_resources" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "limit-range-ns-argocd"
    namespace = "argocd"
  }

  spec {
    limit {
      type = "Container"
      default = {
        memory = var.namespace_memory_limit
      }
    }
  }
}

# App of Apps using kubectl_manifest provider (more tolerant of missing CRDs)
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

  # Wait for ArgoCD helm chart to be fully deployed
  depends_on = [helm_release.argocd]
}
