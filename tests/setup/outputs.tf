output "client_id" {
  value = azuread_service_principal.this.client_id
}

output "password" {
  value     = azuread_service_principal_password.this.value
  sensitive = true
}

output "github_app_id" {
  value     = data.azurerm_key_vault_secret.github_app_id.value
  sensitive = true
}

output "github_installation_id" {
  value     = data.azurerm_key_vault_secret.github_installation_id.value
  sensitive = true
}

output "github_private_key" {
  value     = data.azurerm_key_vault_secret.github_private_key.value
  sensitive = true
}

output "host" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive = true
}

output "client_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  sensitive = true
}

output "client_key" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  sensitive = true
}
