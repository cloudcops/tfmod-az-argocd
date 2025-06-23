# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD Helm Release - Core installation with minimal config
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  values = [
    yamlencode({
      global = {
        domain = var.url
      }

      configs = {
        # Basic configuration - detailed configs will be overlayed via templates
        cm = {
          "admin.enabled" = true
        }
        params = {
          "server.insecure" = tostring(!var.tls_enabled)
        }
      }

      # Disable built-in ingress and notifications - we'll use our templates
      server = {
        ingress = {
          enabled = false
        }
      }

      notifications = {
        enabled = true # Enable but configure via templates
        cm = {
          # Minimal config - will be overridden by template
        }
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# ArgoCD ConfigMaps using existing templates (override Helm defaults)
data "kubectl_file_documents" "argocd_cm" {
  content = templatefile("${path.module}/manifests/argocd-cm.tmpl", {
    url                                = var.url
    name                               = var.idp_argocd_name
    endpoint                           = format("%s%s", "https://", var.idp_endpoint)
    client_id                          = var.sp_client_id
    requested_scopes                   = var.idp_argocd_allowed_oauth_scopes
    log_level                          = var.log_level
    github_app_id                      = var.github_access["0"].app_id
    github_installation_id             = var.github_access["0"].installation_id
    argocd_environment                 = split("/", var.app_path)[1]
    argocd_path                        = var.app_path
    argocd_notification_url_for_github = var.argocd_notification_url_for_github
  })
}

resource "kubectl_manifest" "argocd_cm" {
  yaml_body          = data.kubectl_file_documents.argocd_cm.documents[0]
  override_namespace = "argocd"
  depends_on         = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_cmd_params_cm" {
  yaml_body          = data.kubectl_file_documents.argocd_cm.documents[1]
  override_namespace = "argocd"
  depends_on         = [helm_release.argocd]
}

resource "kubectl_manifest" "argocd_notifications_cm" {
  yaml_body          = data.kubectl_file_documents.argocd_cm.documents[2]
  override_namespace = "argocd"
  depends_on         = [helm_release.argocd]
}

# ArgoCD RBAC ConfigMap
data "kubectl_file_documents" "argocd_rbac" {
  content = templatefile("${path.module}/manifests/argocd-rbac-cm.tmpl", {
    p_role       = var.p_role
    rbac4groups  = local.grantGroupIds
    default_role = var.default_role
  })
}

resource "kubectl_manifest" "argocd_rbac" {
  yaml_body          = data.kubectl_file_documents.argocd_rbac.documents[0]
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd_cm]
}

# ArgoCD Secrets
data "kubectl_file_documents" "argocd_secrets" {
  content = templatefile("${path.module}/manifests/argocd-secrets.tmpl", {
    client_secret = base64encode(var.sp_client_secret)
  })
}

resource "kubectl_manifest" "argocd_secrets" {
  yaml_body          = data.kubectl_file_documents.argocd_secrets.documents[0]
  depends_on         = [kubectl_manifest.argocd_rbac]
  override_namespace = "argocd"
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

# ArgoCD Ingress using existing template
data "kubectl_file_documents" "argocd_ingress" {
  content = templatefile("${path.module}/manifests/ingress.tmpl", {
    url                = var.url
    tls_enabled        = var.tls_enabled
    ingress_class_name = var.ingress_class_name
  })
}

resource "kubectl_manifest" "argocd_ingress" {
  yaml_body          = data.kubectl_file_documents.argocd_ingress.documents[0]
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd_secrets]
}

# ArgoCD GitHub access tokens (Repository credentials)
resource "kubectl_manifest" "argocd_access_token" {
  for_each = var.github_access
  yaml_body = yamlencode({
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
      name      = each.value.name
      namespace = "argocd"
    }
    type = "Opaque"
    stringData = {
      type                    = "git"
      url                     = each.value.url
      githubAppID             = each.value.app_id
      githubAppInstallationID = each.value.installation_id
      githubAppPrivateKey     = each.value.private_key
    }
  })
  sensitive_fields = [
    "stringData.githubAppPrivateKey",
    "stringData.githubAppID",
    "stringData.githubAppInstallationID"
  ]
  depends_on = [kubectl_manifest.argocd_ingress]
}

# ArgoCD notification secret
resource "kubectl_manifest" "notification_secrets" {
  for_each = var.github_access
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
      github-privateKey = each.value.private_key
    }
  })
  sensitive_fields = [
    "stringData.github-privateKey",
  ]
  depends_on = [kubectl_manifest.argocd_ingress]
}

# App of Apps using the existing template
data "kubectl_file_documents" "apps" {
  content = templatefile("${path.module}/manifests/apps.tmpl", {
    repo_url      = var.repo_url
    repo_revision = var.repo_revision
    app_path      = var.app_path
  })
}

resource "kubectl_manifest" "app_of_apps" {
  yaml_body          = data.kubectl_file_documents.apps.documents[0]
  override_namespace = "argocd"
  ignore_fields      = ["yaml_incluster"]
  depends_on         = [kubectl_manifest.argocd_access_token]
}
