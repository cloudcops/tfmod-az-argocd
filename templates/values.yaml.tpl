global:
  domain: ${url}
  installCRDs: true

configs:
  # ArgoCD ConfigMap settings
  cm:
    admin.enabled: true
    application.instanceLabelKey: "argocd.argoproj.io/instance"
    kustomize.buildOptions: "--enable-helm"
    url: "https://${url}"
    
    # OIDC Configuration
    oidc.config: |
      name: ${idp_argocd_name}
      issuer: https://${idp_endpoint}
      clientID: ${sp_client_id}
      clientSecret: $oidc.clientSecret
      skipAudienceCheckWhenTokenHasNoAudience: true
      requestedScopes: [${join(", ", formatlist("\"%s\"", idp_argocd_allowed_oauth_scopes))}]
      requestedIDTokenClaims:
        groups:
          essential: true

    # Resource customizations for ArgoCD Application health
    resource.customizations: |
      argoproj.io/Application:
        health.lua: |
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
      batch/Job:
        health.lua: |
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

    # Timeout settings
    timeout.hard.reconciliation: "0s"
    timeout.reconciliation: "180s"

    # Application Configuration 
    application.config: |
      environment: ${app_environment}
      path: ${app_path}

    # GitHub App Configuration for notifications
    notificationUrl.github: ${argocd_notification_url_for_github}

  # ArgoCD Command Parameters
  params:
    server.insecure: "${server_insecure}"
    server.log.level: ${log_level}
    controller.log.level: ${log_level}
    applicationsetcontroller.log.level: ${log_level}
    notificationscontroller.log.level: ${log_level}
    reposerver.log.level: ${log_level}

  # RBAC Configuration
  rbac:
    policy.default: ${default_role}
    scopes: "[groups, email]"
    policy.matchMode: "glob"
    policy.csv: |
      p, role:${p_role}, applications, *, */*, deny
      p, role:${p_role}, clusters, get, *, deny
      p, role:${p_role}, repositories, get, *, deny
      p, role:${p_role}, repositories, create, *, deny
      p, role:${p_role}, repositories, update, *, deny
      p, role:${p_role}, repositories, delete, *, deny
      p, role:${p_role}, logs, get, *, deny
      p, role:${p_role}, exec, create, */*, deny
%{ for group in grant_group_ids ~}
      g, ${group.name}, role:${group.role}
%{ endfor ~}

  # Secret configuration
  secret:
    # OIDC client secret
    oidc.clientSecret: ${sp_client_secret}
    # GitHub App credentials for notifications
    github-privateKey: |-
${indent(6, github_private_key)}

  # Repository credentials
  repositories:
%{ for repo in github_repositories ~}
    ${repo.name}:
      url: ${repo.url}
      type: git
      githubAppID: ${repo.app_id}
      githubAppInstallationID: ${repo.installation_id}
      githubAppPrivateKey: |-
${indent(8, repo.private_key)}
%{ endfor ~}

# Server configuration with ingress
server:
  ingress:
    enabled: true
    ingressClassName: ${ingress_class_name}
    hostname: ${url}
    tls: ${tls_enabled}
%{ if tls_enabled ~}
    annotations:
      nginx.ingress.kubernetes.io/configuration-snippet: |
        if ($http_x_forwarded_proto = 'http') {
          return 301 https://$host$request_uri;
        }
      nginx.ingress.kubernetes.io/rewrite-target: "/"
      nginx.ingress.kubernetes.io/use-regex: "true"
      cert-manager.io/cluster-issuer: "letsencrypt-prod"
%{ endif ~}

# Notifications configuration
notifications:
  enabled: true
  
  cm:
    # Notification services configuration
    service.github: |
      appID: ${github_app_id}
      installationID: ${github_installation_id}
      privateKey: $github-privateKey

    # Trigger configuration
    trigger.on-deployed: |
      - description: "Application is synced and healthy. Triggered once per commit."
        oncePer: "app.status.operationState?.syncResult?.revision"
        send: ["app-deployed"]
        when: "app.status.operationState != nil and app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"

    # Template configuration
    template.app-deployed: |
      message: "All Applications of {{.app.metadata.name}} are synced and healthy."
      github:
        repoURLPath: "{{.app.spec.source.repoURL}}"
        revisionPath: "{{.app.status.operationState.syncResult.revision}}"
        status:
          state: "success"
          label: "${app_path}"
          targetURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
        deployment:
          state: "success"
          environment: "${app_environment}"
          environmentURL: "${argocd_notification_url_for_github}"
          logURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
          requiredContexts: []
          autoMerge: true
          transientEnvironment: false
        pullRequestComment:
          content: |-
${indent(12, <<EOT
:wave: @myperfectstay/developers @myperfectstay/devops
:tada: **Deployment Status:**
Your deployment for `Application` `{{.app.metadata.name}}` was successful! :rocket:
All related applications are **synced** and **healthy**. :white_check_mark:
### :package: MPS Backend Applications Overview
| Application         | Status                        | Link                                                                            |
|---------------------|-------------------------------|---------------------------------------------------------------------------------|
| `app-of-apps`       | ✔ {{.app.status.sync.status}} | [Go to Operations](https://${url}/applications/{{.app.metadata.name}}?operation=true) |
| `mps-core`          | ✔ {{.app.status.sync.status}} | [Go to Application](https://${url}/applications/mps-core)                             |
| `mps-celery-beat`   | ✔ {{.app.status.sync.status}} | [Go to Application](https://${url}/applications/mps-celery-beat)                      |
| `mps-celery-worker` | ✔ {{.app.status.sync.status}} | [Go to Application](https://argocd-test.example.com/applications/mps-celery-worker)                    |
---
:link: **Quick Access:**
- [MPS backend API docs](${argocd_notification_url_for_github})
- [ArgoCD Operations for `app-of-apps`](https://${url}/applications/{{.app.metadata.name}}?operation=true)
---
:robot: *Automated notification via ArgoCD*
EOT
)}