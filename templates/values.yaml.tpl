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
      clientSecret: $oidc.auth0.clientSecret
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
    server.insecure: "true"
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
    createSecret: true
    extra:
      # OIDC client secret
      oidc.auth0.clientSecret: ${sp_client_secret}

# Server configuration
server:
  resources:
    limits:
      memory: ${argocd_server_memory}
    requests:
      memory: ${argocd_server_memory}
      cpu: ${argocd_server_cpu_request}
  metrics:
    enabled: ${metrics_enabled}
    serviceMonitor:
      enabled: ${service_monitor_enabled}

  ingress:
    enabled: false

  httproute:
    enabled: true
    parentRefs:
      - name: ${gateway_name}
        namespace: ${gateway_namespace}
        sectionName: ${gateway_listener_name}
    hostnames:
      - ${url}

# Application Controller configuration
controller:
  resources:
    limits:
      memory: ${argocd_controller_memory}
    requests:
      memory: ${argocd_controller_memory}
      cpu: ${argocd_controller_cpu_request}
  metrics:
    enabled: ${metrics_enabled}
    serviceMonitor:
      enabled: ${service_monitor_enabled}

# Repository Server configuration
repoServer:
  resources:
    limits:
      memory: ${argocd_reposerver_memory}
    requests:
      memory: ${argocd_reposerver_memory}
      cpu: ${argocd_reposerver_cpu_request}
  metrics:
    enabled: ${metrics_enabled}
    serviceMonitor:
      enabled: ${service_monitor_enabled}

# ApplicationSet Controller configuration
applicationSet:
  resources:
    limits:
      memory: ${argocd_applicationset_memory}
    requests:
      memory: ${argocd_applicationset_memory}
      cpu: ${argocd_applicationset_cpu_request}
  metrics:
    enabled: ${metrics_enabled}
    serviceMonitor:
      enabled: ${service_monitor_enabled}

# Redis configuration
redis:
  resources:
    limits:
      memory: ${argocd_redis_memory}
    requests:
      memory: ${argocd_redis_memory}
      cpu: ${argocd_redis_cpu_request}
  metrics:
    enabled: ${metrics_enabled}
    serviceMonitor:
      enabled: ${service_monitor_enabled}

# Dex configuration (OIDC)
dex:
  resources:
    limits:
      memory: ${argocd_dex_memory}
    requests:
      memory: ${argocd_dex_memory}
      cpu: ${argocd_dex_cpu_request}

# Notifications configuration
notifications:
  enabled: true

  resources:
    limits:
      memory: ${argocd_notifications_memory}
    requests:
      memory: ${argocd_notifications_memory}
      cpu: ${argocd_notifications_cpu_request}
  
  # Notification services configuration
  notifiers:
    service.github: |
      appID: "${github_app_id}"
      installationID: "${github_installation_id}"
      privateKey: $github-privateKey

  # Trigger configuration
  triggers:
    trigger.on-deployed: |
      - description: "Application is synced and healthy. Triggered once per commit."
        oncePer: "app.metadata.annotations[\"notifications.argoproj.io/github.sha\"]"
        send: ["app-deployed"]
        when: "app.status.operationState != nil and app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'"
    trigger.on-deploy-failed: |
      - description: "Application sync failed or is unhealthy. Triggered once per commit."
        oncePer: "app.metadata.annotations[\"notifications.argoproj.io/github.sha\"]"
        send: ["app-deploy-failed"]
        when: "app.status.operationState != nil and (app.status.operationState.phase in ['Error', 'Failed'] or app.status.health.status in ['Degraded', 'Missing', 'Unknown'])"

  # Template configuration
  templates:
    template.app-deployed: |
      message: |
        Deployment {{ if and (eq .app.status.sync.status "Synced") (eq .app.status.health.status "Healthy") }}successful{{ else }}failed{{ end }} - ${app_environment}
      github:
        repoURLPath: "{{ (get .app.metadata.annotations \"notifications.argoproj.io/github.repo\") | default .app.spec.source.repoURL }}"
        revisionPath: "{{ get .app.metadata.annotations \"notifications.argoproj.io/github.sha\" }}"
        status:
          state: "{{ if and (eq .app.status.sync.status \"Synced\") (eq .app.status.health.status \"Healthy\") }}success{{ else }}pending{{ end }}"
          label: "{{ .app.metadata.name }}"
          targetURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
        deployment:
          state: "{{ if and (eq .app.status.sync.status \"Synced\") (eq .app.status.health.status \"Healthy\") }}success{{ else }}failure{{ end }}"
          environment: "${app_environment}"
          environmentURL: "${argocd_notification_url_for_github}"
          logURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
          requiredContexts: []
          autoMerge: true
          transientEnvironment: false
%{ if github_pr_comment_on_success_enabled ~}
        pullRequestComment:
          content: |
            :tada: **Deployment Status:**
            Application `{{ .app.metadata.name }}` is **{{ default "Unknown" .app.status.sync.status }}** with health **{{ default "Unknown" .app.status.health.status }}** in **${app_environment}**.

            ---

            **Operation Details:**
            {{- if .app.status.operationState.finishedAt }}
            - **Finished At:** `{{ .app.status.operationState.finishedAt }}`
            {{- end }}
            {{- if .app.status.operationState.message }}
            - **Message:** `{{ .app.status.operationState.message }}`
            {{- end }}

            :link: **[View in ArgoCD](https://${url}/applications/{{.app.metadata.name}}?operation=true)**

            :robot: *Automated notification via ArgoCD*
%{ endif ~}
    template.app-deploy-failed: |
      message: |
        Deployment failed - ${app_environment}
      github:
        repoURLPath: "{{ (get .app.metadata.annotations \"notifications.argoproj.io/github.repo\") | default .app.spec.source.repoURL }}"
        revisionPath: "{{ get .app.metadata.annotations \"notifications.argoproj.io/github.sha\" }}"
        status:
          state: "failure"
          label: "{{ .app.metadata.name }}"
          targetURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
        deployment:
          state: "failure"
          environment: "${app_environment}"
          environmentURL: "${argocd_notification_url_for_github}"
          logURL: "https://${url}/applications/{{.app.metadata.name}}?operation=true"
%{ if github_pr_comment_on_failure_enabled ~}
        pullRequestComment:
          content: |
            :x: **Deployment Failed:**
            Application `{{ .app.metadata.name }}` has **{{ default "Unknown" .app.status.sync.status }}** sync status with **{{ default "Unknown" .app.status.health.status }}** health in **${app_environment}**.
            ---

            **Operation Details:**
            {{- if .app.status.operationState.finishedAt }}
            - **Finished At:** `{{ .app.status.operationState.finishedAt }}`
            {{- end }}
            {{- if .app.status.operationState.message }}
            - **Message:** `{{ .app.status.operationState.message }}`
            {{- end }}

            :link: **[View in ArgoCD](https://${url}/applications/{{.app.metadata.name}}?operation=true)**

            :robot: *Automated notification via ArgoCD*
%{ endif ~}
