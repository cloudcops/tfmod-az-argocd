module "wrapper" {
  source = "../."

  for_each = var.items

  app_path                           = try(each.value.app_path, var.defaults.app_path)
  argocd_notification_url_for_github = try(each.value.argocd_notification_url_for_github, var.defaults.argocd_notification_url_for_github)
  argocd_version                     = try(each.value.argocd_version, var.defaults.argocd_version, "v2.10.7")
  default_role                       = try(each.value.default_role, var.defaults.default_role, "readonly")
  github_access                      = try(each.value.github_access, var.defaults.github_access, {})
  idp_argocd_allowed_oauth_scopes    = try(each.value.idp_argocd_allowed_oauth_scopes, var.defaults.idp_argocd_allowed_oauth_scopes, ["email", "openid", "profile"])
  idp_argocd_name                    = try(each.value.idp_argocd_name, var.defaults.idp_argocd_name, "Azure")
  idp_endpoint                       = try(each.value.idp_endpoint, var.defaults.idp_endpoint)
  ingress_class_name                 = try(each.value.ingress_class_name, var.defaults.ingress_class_name, "nginx")
  log_level                          = try(each.value.log_level, var.defaults.log_level, "info")
  p_role                             = try(each.value.p_role, var.defaults.p_role, "no-access")
  rbac4groups                        = try(each.value.rbac4groups, var.defaults.rbac4groups, [])
  repo_revision                      = try(each.value.repo_revision, var.defaults.repo_revision, "main")
  repo_url                           = try(each.value.repo_url, var.defaults.repo_url)
  sp_client_id                       = try(each.value.sp_client_id, var.defaults.sp_client_id)
  sp_client_secret                   = try(each.value.sp_client_secret, var.defaults.sp_client_secret)
  tls_enabled                        = try(each.value.tls_enabled, var.defaults.tls_enabled, false)
  url                                = try(each.value.url, var.defaults.url)
}
