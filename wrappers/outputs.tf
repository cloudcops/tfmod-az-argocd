output "wrapper" {
  description = "Map of outputs of a wrapper."
  value       = module.wrapper
  sensitive   = true # Contains sensitive data: github_private_key, sp_client_secret, etc.
}
