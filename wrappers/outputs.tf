output "wrapper" {
  description = "Map of outputs of a wrapper."
  value       = module.wrapper
  sensitive   = true # At least one sensitive module output (kubernetes_host_reference) found (requires Terraform 0.14+)
}
