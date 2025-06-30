# Outputs for testing and validation

output "argocd_namespace" {
  description = "ArgoCD namespace name"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_helm_release_name" {
  description = "ArgoCD Helm release name"
  value       = helm_release.argocd.name
}

output "argocd_helm_release_version" {
  description = "ArgoCD Helm chart version"
  value       = helm_release.argocd.version
}

output "argocd_helm_values" {
  description = "Rendered ArgoCD Helm values for testing (sensitive values are referenced, not exposed)"
  value       = helm_release.argocd.values[0]
  sensitive   = false
}

output "app_of_apps_manifest" {
  description = "App of Apps manifest for validation"
  value       = kubectl_manifest.app_of_apps.yaml_body_parsed
}

output "limit_range_config" {
  description = "Namespace limit range configuration"
  value = {
    name      = kubernetes_limit_range.default_resources.metadata[0].name
    namespace = kubernetes_limit_range.default_resources.metadata[0].namespace
    limits    = kubernetes_limit_range.default_resources.spec[0].limit
  }
}