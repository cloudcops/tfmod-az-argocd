resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = file("${path.module}/manifests/namespace.yaml")
}

data "kubectl_file_documents" "argocd_cm" {
  content = templatefile("${path.module}/manifests/argocd-cm.tmpl",
    {
      url              = var.url
      name             = var.idp_argocd_name,
      endpoint         = format("%s%s", "https://", var.idp_endpoint),
      client_id        = var.sp_client_id
      requested_scopes = var.idp_argocd_allowed_oauth_scopes,
      log_level        = var.log_level
  })
}

resource "kubectl_manifest" "argocd_cm" {
  yaml_body          = data.kubectl_file_documents.argocd_cm.documents[0]
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd_namespace]
}

resource "kubectl_manifest" "argocd_cmd_params_cm" {
  yaml_body          = data.kubectl_file_documents.argocd_cm.documents[1]
  override_namespace = "argocd"
  depends_on         = [kubectl_manifest.argocd_namespace]
}


data "kubectl_file_documents" "argocd_rbac" {
  content = templatefile("${path.module}/manifests/argocd-rbac-cm.tmpl",
    {
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

data "external" "argocd_yaml_split" {
  program = ["${path.module}/split_yaml.sh", "https://raw.githubusercontent.com/argoproj/argo-cd/${var.argocd_version}/manifests/install.yaml"]
}

resource "kubectl_manifest" "argocd_install" {
  for_each           = { for idx, content in data.external.argocd_yaml_split.result : idx => content }
  override_namespace = "argocd"
  yaml_body          = each.value
  depends_on         = [data.external.argocd_yaml_split, kubectl_manifest.argocd_cm]
}

data "kubectl_file_documents" "argocd_secrets" {
  content = templatefile("${path.module}/manifests/argocd-secrets.tmpl",
    {
      client_secret = base64encode(var.sp_client_secret)
  })
}

resource "kubectl_manifest" "argocd_secrets" {
  yaml_body          = data.kubectl_file_documents.argocd_secrets.documents[0]
  depends_on         = [kubectl_manifest.argocd_install]
  override_namespace = "argocd"
}


resource "kubernetes_limit_range" "default_resources" {
  depends_on = [kubectl_manifest.argocd_secrets]
  metadata {
    name      = "limit-range-ns-argocd"
    namespace = "argocd"
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "1"
        memory = "2Gi"
      }
      default_request = {
        cpu    = "50m"
        memory = "96Mi"
      }
    }
  }
}

data "kubectl_file_documents" "argocd_ingress" {
  content = templatefile("${path.module}/manifests/ingress.tmpl",
    {
      url                = var.url,
      tls_enabled        = var.tls_enabled,
      ingress_class_name = var.ingress_class_name
  })
}

resource "kubectl_manifest" "argocd_ingress" {
  yaml_body          = data.kubectl_file_documents.argocd_ingress.documents[0]
  override_namespace = "argocd"
  depends_on         = [kubernetes_limit_range.default_resources]
}

resource "kubernetes_secret" "argocd_access_token" {
  for_each = var.access_token_secret_configuration
  metadata {
    name      = "argocd-access-token-${each.key}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }
  data = {
    "url"      = each.value.url
    "password" = each.value.password
    "username" = each.value.username
    "name"     = each.value.name
    "type"     = each.value.type
  }
  depends_on = [kubectl_manifest.argocd_ingress]
}

data "kubectl_file_documents" "apps" {
  content = templatefile("${path.module}/manifests/apps.tmpl",
    {
      repo_url      = var.repo_url,
      repo_revision = var.repo_revision,
      app_path      = var.app_path
  })
}

resource "kubectl_manifest" "apps" {
  yaml_body          = data.kubectl_file_documents.apps.documents[0]
  override_namespace = "argocd"
  ignore_fields      = ["yaml_incluster"]
  depends_on         = [kubernetes_secret.argocd_access_token]
}
