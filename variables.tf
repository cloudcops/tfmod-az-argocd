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
  default   = {}
  sensitive = true
}

variable "log_level" {
  description = "Defines the logging level for application logs (e.g., debug, info, warn)."
  type        = string
  default     = "info"
}

variable "argocd_notification_url_for_github" {
  type = string
}

variable "argocd_server_memory_limit" {
  description = "Memory limit and request for ArgoCD Server (limits = requests)"
  type        = string
  default     = "256Mi"
}

variable "argocd_server_cpu_request" {
  description = "CPU request for ArgoCD Server (no CPU limits)"
  type        = string
  default     = "100m"
}

variable "argocd_controller_memory_limit" {
  description = "Memory limit and request for ArgoCD Application Controller (limits = requests)"
  type        = string
  default     = "1536Mi"
}

variable "argocd_controller_cpu_request" {
  description = "CPU request for ArgoCD Application Controller (no CPU limits)"
  type        = string
  default     = "250m"
}

variable "argocd_reposerver_memory_limit" {
  description = "Memory limit and request for ArgoCD Repository Server (limits = requests)"
  type        = string
  default     = "256Mi"
}

variable "argocd_reposerver_cpu_request" {
  description = "CPU request for ArgoCD Repository Server (no CPU limits)"
  type        = string
  default     = "200m"
}

variable "argocd_applicationset_memory_limit" {
  description = "Memory limit and request for ArgoCD ApplicationSet Controller (limits = requests)"
  type        = string
  default     = "128Mi"
}

variable "argocd_applicationset_cpu_request" {
  description = "CPU request for ArgoCD ApplicationSet Controller (no CPU limits)"
  type        = string
  default     = "50m"
}

variable "argocd_notifications_memory_limit" {
  description = "Memory limit and request for ArgoCD Notifications Controller (limits = requests)"
  type        = string
  default     = "128Mi"
}

variable "argocd_notifications_cpu_request" {
  description = "CPU request for ArgoCD Notifications Controller (no CPU limits)"
  type        = string
  default     = "50m"
}

variable "argocd_redis_memory_limit" {
  description = "Memory limit and request for Redis (limits = requests)"
  type        = string
  default     = "128Mi"
}

variable "argocd_redis_cpu_request" {
  description = "CPU request for Redis (no CPU limits)"
  type        = string
  default     = "50m"
}

variable "argocd_dex_memory_limit" {
  description = "Memory limit and request for Dex (limits = requests)"
  type        = string
  default     = "128Mi"
}

variable "argocd_dex_cpu_request" {
  description = "CPU request for Dex (no CPU limits)"
  type        = string
  default     = "50m"
}
