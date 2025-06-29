# ArgoCD Namespace
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ArgoCD Helm Release - Complete configuration with all settings
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  # Wait for CRDs to be ready
  wait             = true
  wait_for_jobs    = true
  timeout          = 600

  values = [
    yamlencode({
      global = {
        domain = var.url
      }

      configs = {
        # ArgoCD ConfigMap settings
        cm = {
          "admin.enabled" = true
          
          # Application instance label key
          "application.instanceLabelKey" = "argocd.argoproj.io/instance"
          
          # Kustomize build options
          "kustomize.buildOptions" = "--enable-helm"
          
          # Server URL
          url = "https://${var.url}"
          
          # OIDC Configuration
          "oidc.config" = yamlencode({
            name                                     = var.idp_argocd_name
            issuer                                   = "https://${var.idp_endpoint}"
            clientID                                 = var.sp_client_id
            clientSecret                             = "$oidc.clientSecret"
            skipAudienceCheckWhenTokenHasNoAudience = true
            requestedScopes                          = var.idp_argocd_allowed_oauth_scopes
            requestedIDTokenClaims = {
              groups = {
                essential = true
              }
            }
          })
          
          # Resource customizations for ArgoCD Application health
          "resource.customizations" = yamlencode({
            "argoproj.io/Application" = {
              "health.lua" = <<-EOF
                hs = {}
                hs.status = "Progressing"
                hs.message = ""
                if obj.status ~= nil then
                  if obj.status.health ~= nil then
                    hs.status = obj.status.health.status
                    if obj.status.health.message ~= nil then
                      hs.message = obj.status.health.message
                    end
                  end
                end
                return hs
              EOF
            }
            "batch/Job" = {
              "health.lua" = <<-EOF
                hs = {}
                if obj.metadata.name == "viator-full-sync" then
                    hs.status = "Healthy"
                    hs.message = "Custom override: treating viator-full-sync as healthy"
                    return hs
                end
                if obj.status ~= nil then
                    if obj.status.succeeded ~= nil and obj.status.succeeded >= 1 then
                    hs.status = "Healthy"
                    hs.message = "Job completed successfully"
                    elseif obj.status.failed ~= nil and obj.status.failed > 0 then
                    hs.status = "Degraded"
                    hs.message = "Job has failed"
                    else
                    hs.status = "Progressing"
                    hs.message = "Job is running"
                    end
                else
                    hs.status = "Progressing"
                    hs.message = "Waiting for job status"
                end
                return hs
              EOF
            }
          })
          
          # Timeout settings
          "timeout.hard.reconciliation" = "0s"
          "timeout.reconciliation"      = "180s"
          
          # Application Configuration 
          "application.config" = yamlencode({
            environment = split("/", var.app_path)[1]
            path        = var.app_path
          })
          
          # GitHub App Configuration for notifications
          "notificationUrl.github" = var.argocd_notification_url_for_github
        }

        # ArgoCD Command Parameters
        params = {
          "server.insecure"                        = tostring(!var.tls_enabled)
          "server.log.level"                       = var.log_level
          "controller.log.level"                   = var.log_level
          "applicationsetcontroller.log.level"     = var.log_level
          "notificationscontroller.log.level"      = var.log_level
          "reposerver.log.level"                   = var.log_level
        }

        # RBAC Configuration
        rbac = {
          "policy.default"   = var.default_role
          "scopes"          = "[groups, email]"
          "policy.matchMode" = "glob"
          "policy.csv" = join("\n", concat(
            ["p, role:${var.p_role}, applications, *, */*, deny",
             "p, role:${var.p_role}, clusters, get, *, deny",
             "p, role:${var.p_role}, repositories, get, *, deny", 
             "p, role:${var.p_role}, repositories, create, *, deny",
             "p, role:${var.p_role}, repositories, update, *, deny",
             "p, role:${var.p_role}, repositories, delete, *, deny",
             "p, role:${var.p_role}, logs, get, *, deny",
             "p, role:${var.p_role}, exec, create, */*, deny"],
            [for group in local.grantGroupIds : "g, ${group.name}, role:${group.role}"]
          ))
        }

        # Secret configuration
        secret = {
          # OIDC client secret
          "oidc.clientSecret" = var.sp_client_secret
          
          # GitHub App credentials for notifications
          "github-privateKey" = var.github_access["0"].private_key
        }

        # Repository credentials
        repositories = {
          for key, repo in var.github_access : repo.name => {
            url                     = repo.url
            type                    = "git"
            githubAppID             = repo.app_id
            githubAppInstallationID = repo.installation_id
            githubAppPrivateKey     = repo.private_key
          }
        }
      }

      # Server configuration with ingress
      server = {
        ingress = {
          enabled          = true
          ingressClassName = var.ingress_class_name
          hostname         = var.url
          tls              = var.tls_enabled
          
          annotations = var.tls_enabled ? {
            "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
              if ($http_x_forwarded_proto = 'http') {
                return 301 https://$host$request_uri;
              }
            EOF
            "nginx.ingress.kubernetes.io/rewrite-target" = "/"
            "nginx.ingress.kubernetes.io/use-regex"      = "true"
            "cert-manager.io/cluster-issuer"             = "letsencrypt-prod"
          } : {}
        }
      }

      # Notifications configuration
      notifications = {
        enabled = true
        
        cm = {
          # Notification services configuration
          "service.github" = yamlencode({
            appID          = var.github_access["0"].app_id
            installationID = var.github_access["0"].installation_id
            privateKey     = "$github-privateKey"
          })
          
          # Trigger configuration
          "trigger.on-deployed" = yamlencode([{
            description = "Application is synced and healthy. Triggered once per commit."
            oncePer     = "app.status.operationState?.syncResult?.revision"
            send        = ["app-deployed"]
            when        = "app.status.operationState != nil and app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"
          }])
          
          # Template configuration
          "template.app-deployed" = yamlencode({
            message = "All Applications of {{.app.metadata.name}} are synced and healthy."
            github = {
              repoURLPath  = "{{.app.spec.source.repoURL}}"
              revisionPath = "{{.app.status.operationState.syncResult.revision}}"
              status = {
                state     = "success"
                label     = var.app_path
                targetURL = "https://${var.url}/applications/{{.app.metadata.name}}?operation=true"
              }
              deployment = {
                state               = "success"
                environment         = split("/", var.app_path)[1]
                environmentURL      = var.argocd_notification_url_for_github
                logURL             = "https://${var.url}/applications/{{.app.metadata.name}}?operation=true"
                requiredContexts   = []
                autoMerge          = true
                transientEnvironment = false
              }
              pullRequestComment = {
                content = <<-EOF
:wave: @myperfectstay/developers @myperfectstay/devops

:tada: **Deployment Status:**
Your deployment for `Application` `{{.app.metadata.name}}` was successful! :rocket:

All related applications are **synced** and **healthy**. :white_check_mark:

### :package: MPS Backend Applications Overview
| Application         | Status                        | Link                                                                            |
|---------------------|-------------------------------|---------------------------------------------------------------------------------|
| `app-of-apps`       | ✔ {{.app.status.sync.status}} | [Go to Operations](https://${var.url}/applications/{{.app.metadata.name}}?operation=true) |
| `mps-core`          | ✔ {{.app.status.sync.status}} | [Go to Application](https://${var.url}/applications/mps-core)                             |
| `mps-celery-beat`   | ✔ {{.app.status.sync.status}} | [Go to Application](https://${var.url}/applications/mps-celery-beat)                      |
| `mps-celery-worker` | ✔ {{.app.status.sync.status}} | [Go to Application](https://${var.url}/applications/mps-celery-worker)                    |

---

:link: **Quick Access:**
- [MPS backend API docs](${var.argocd_notification_url_for_github})
- [ArgoCD Operations for `app-of-apps`](https://${var.url}/applications/{{.app.metadata.name}}?operation=true)

---

:robot: *Automated notification via ArgoCD*
                EOF
              }
            }
          })
        }
      }

      # Install CRDs and wait for them to be ready
      crds = {
        install = true
        keep    = false
      }
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

# Limit Range for ArgoCD namespace
resource "kubernetes_limit_range" "default_resources" {
  depends_on = [helm_release.argocd]
  metadata {
    name      = "limit-range-ns-argocd"
    namespace = "argocd"
  }

  spec {
    limit {
      type = "Container"
      default = {
        memory = var.namespace_memory_limit
      }
    }
  }
}

# App of Apps using kubernetes_manifest provider
resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "app-of-apps"
      namespace = "argocd"
      annotations = {
        "notifications.argoproj.io/subscribe.on-deployed.github" = ""
      }
    }
    spec = {
      destination = {
        namespace = "argocd"
        server    = "https://kubernetes.default.svc"
      }
      project = "default"
      source = {
        path           = var.app_path
        repoURL        = var.repo_url
        targetRevision = var.repo_revision
      }
      syncPolicy = {
        automated = {
          prune      = true
          selfHeal   = true
          allowEmpty = false
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
          "FailOnSharedResource=false"
        ]
        retry = {
          limit = 10
          backoff = {
            duration    = "5s"
            factor      = 2
            maxDuration = "30s"
          }
        }
      }
    }
  }

  # Prevent status drift from causing unnecessary updates
  computed_fields = ["status"]

  depends_on = [helm_release.argocd]
}
