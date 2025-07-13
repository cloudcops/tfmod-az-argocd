output "sp_client_secret" {
  description = "Service Principal Client Secret"
  value       = var.sp_client_secret
  sensitive   = true
}

output "github_access" {
  description = "GitHub access configuration"
  value       = var.github_access
  sensitive   = true
}
