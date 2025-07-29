output "sp_client_secret" {
  description = "Service Principal Client Secret"
  value       = var.sp_client_secret
  sensitive   = true
}

output "argocd_secret_validation" {
  description = "ArgoCD secret validation data for testing purposes"
  value = {
    name      = data.kubernetes_secret.argocd_secret.metadata[0].name
    namespace = data.kubernetes_secret.argocd_secret.metadata[0].namespace
    type      = data.kubernetes_secret.argocd_secret.type
    data_keys = keys(data.kubernetes_secret.argocd_secret.data)
  }
  sensitive = false
}
