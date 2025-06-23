variable "github_app_id" {
  description = "GitHub App ID for ArgoCD repository access"
  type        = string
}

variable "github_installation_id" {
  description = "GitHub App Installation ID for ArgoCD repository access"
  type        = string
}

variable "github_private_key" {
  description = "GitHub App Private Key for ArgoCD repository access"
  type        = string
  sensitive   = true
}
