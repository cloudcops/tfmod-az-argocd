variable "argocd_chart_version" {
  description = "Version of ArgoCD Helm Chart to install"
  type        = string
  default     = "8.1.2"
}

variable "repo_revision" {
  description = "Specifies the Git branch name for the ArgoCD Application."
  type        = string
  default     = "main"
}

variable "repo_url" {
  description = "URL to the GitOps repository."
  type        = string
}

variable "url" {
  description = "URL to be used for connections or configurations."
  type        = string
}

variable "tls_enabled" {
  description = "Flag to enable or disable TLS security."
  type        = bool
  default     = false
}

variable "ingress_class_name" {
  description = "Specifies the name of the Ingress class used for routing traffic."
  type        = string
  default     = "nginx"
}

variable "app_path" {
  description = "Repo path to the application tools overlay."
  type        = string
}

variable "sp_client_id" {
  description = "Service Principal Client ID used for SSO."
  type        = string
}

variable "sp_client_secret" {
  description = "Service Principal Client Secret used for SSO."
  type        = string
  sensitive   = true
}

variable "idp_argocd_name" {
  description = "Display name used on the login page of ArgoCD for the identity provider."
  type        = string
  default     = "Azure"
}

variable "idp_endpoint" {
  description = "Endpoint URL for the identity provider, including the tenant ID."
  type        = string
}

variable "idp_argocd_allowed_oauth_scopes" {
  description = "List of OAuth scopes permitted for requests to the identity provider."
  type        = list(string)
  default     = ["email", "openid", "profile"]
}

variable "rbac4groups" {
  description = "Role-based access control settings for groups using OIDC."
  type        = list(map(any))
  default     = []
}

variable "default_role" {
  description = "Default access role assigned in ArgoCD via OIDC authentication."
  type        = string
  default     = "readonly"
}

variable "p_role" {
  description = "Placeholder role, typically assigning no access in ArgoCD via OIDC."
  type        = string
  default     = "no-access"
}

variable "github_access" {
  description = "Map of ArgoCD Github access token secret configuration."
  type = map(object({
    name            = string
    url             = string
    app_id          = string
    installation_id = string
    private_key     = string
  }))
  default = {}
}

variable "log_level" {
  description = "Defines the logging level for application logs (e.g., debug, info, warn)."
  type        = string
  default     = "info"
}

variable "argocd_notification_url_for_github" {
  type = string
}

variable "namespace_memory_limit" {
  description = "Kubernetes memory limit range."
  type        = string
  default     = "1Gi"
}

variable "kubernetes_host" {
  type = string
}

variable "kubernetes_client_certificate" {
  type = string
}

variable "kubernetes_client_key" {
  type = string
}

variable "kubernetes_cluster_ca_certificate" {
  type = string
}
