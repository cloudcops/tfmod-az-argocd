<!-- BEGIN_TF_DOCS -->
# Terraform Module: `argocd`

## Overview
This module creates ArgoCD for a Kubernetes cluster and configures:
- SSO via Azure Entra ID
- GitHub App integration for notifications and deployments
- Dynamic notification configuration for Helm based ArgoCD apps using annotations `notifications.argoproj.io/github.sha=<full_commit_sha>` & `notifications.argoproj.io/github.repo=<github_repo_path>` on `Application` manifests
- Resource limits and metrics

Also implements a `wrapper` module so it can be consumed easier via Terragrunt.

## Example usage

```hcl
module "argocd" {
  source = "../modules/argocd"

  # Basic configuration
  argocd_chart_version = "8.1.2"
  repo_revision        = "main"
  repo_url             = "https://github.com/example/argocd-repo.git"
  url                  = "argocd.example.com"
  app_path             = "argocd-k8s-apps/overlays/dev"
  app_environment      = "dev"
  tls_enabled          = true
  ingress_class_name   = "nginx"

  # GitHub App configuration
  argocd_notification_url_for_github = "https://dev.example.com"
  github_access = {
    "0" = {
      name            = "argocd-github-app"
      url             = "https://github.com/example"
      app_id          = "123456"
      installation_id = "78910"
      private_key     = "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----"
    }
  }

  # Azure Entra ID SSO
  sp_client_id     = "your-client-id"
  sp_client_secret = "your-client-secret"
  idp_endpoint     = "https://login.microsoftonline.com/<tenant_id>/v2.0"
  idp_argocd_name  = "Azure"

  # RBAC configuration
  default_role = "readonly"
  rbac4groups = [
    {
      name = "sg-admin" # entra id group name
      role = "admin"
    },
    {
      name = "sg-developer"
      role = "reader"
    }
  ]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (2.51.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (4.37.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (3.0.2)

- <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) (1.19.0)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (2.37.1)

## Providers

The following providers are used by this module:

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (2.51.0)

- <a name="provider_helm"></a> [helm](#provider\_helm) (3.0.2)

- <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) (1.19.0)

- <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) (2.37.1)

## Resources

The following resources are used by this module:

- [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/3.0.2/docs/resources/release) (resource)
- [kubectl_manifest.app_of_apps](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) (resource)
- [kubectl_manifest.argocd_access_token](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) (resource)
- [kubectl_manifest.notification_secrets](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) (resource)
- [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/2.37.1/docs/resources/namespace) (resource)
- [azuread_group.rbac4groups](https://registry.terraform.io/providers/hashicorp/azuread/2.51.0/docs/data-sources/group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_app_path"></a> [app\_path](#input\_app\_path)

Description: Repo path to the application tools overlay.

Type: `string`

### <a name="input_argocd_notification_url_for_github"></a> [argocd\_notification\_url\_for\_github](#input\_argocd\_notification\_url\_for\_github)

Description: n/a

Type: `string`

### <a name="input_idp_endpoint"></a> [idp\_endpoint](#input\_idp\_endpoint)

Description: Endpoint URL for the identity provider, including the tenant ID.

Type: `string`

### <a name="input_repo_url"></a> [repo\_url](#input\_repo\_url)

Description: URL to the GitOps repository.

Type: `string`

### <a name="input_sp_client_id"></a> [sp\_client\_id](#input\_sp\_client\_id)

Description: Service Principal Client ID used for SSO.

Type: `string`

### <a name="input_sp_client_secret"></a> [sp\_client\_secret](#input\_sp\_client\_secret)

Description: Service Principal Client Secret used for SSO.

Type: `string`

### <a name="input_url"></a> [url](#input\_url)

Description: URL to be used for connections or configurations.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_argocd_applicationset_cpu_request"></a> [argocd\_applicationset\_cpu\_request](#input\_argocd\_applicationset\_cpu\_request)

Description: CPU requests for the ArgoCD ApplicationSet Controller

Type: `string`

Default: `"50m"`

### <a name="input_argocd_applicationset_memory_limit"></a> [argocd\_applicationset\_memory\_limit](#input\_argocd\_applicationset\_memory\_limit)

Description: Memory limit for the ArgoCD ApplicationSet Controller

Type: `string`

Default: `"128Mi"`

### <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version)

Description: Version of ArgoCD Helm Chart to install

Type: `string`

Default: `"8.1.2"`

### <a name="input_argocd_controller_cpu_request"></a> [argocd\_controller\_cpu\_request](#input\_argocd\_controller\_cpu\_request)

Description: CPU requests for the ArgoCD Application Controller

Type: `string`

Default: `"250m"`

### <a name="input_argocd_controller_memory_limit"></a> [argocd\_controller\_memory\_limit](#input\_argocd\_controller\_memory\_limit)

Description: Memory limit for the ArgoCD Application Controller

Type: `string`

Default: `"1536Mi"`

### <a name="input_argocd_dex_cpu_request"></a> [argocd\_dex\_cpu\_request](#input\_argocd\_dex\_cpu\_request)

Description: CPU requests for the ArgoCD Dex service

Type: `string`

Default: `"50m"`

### <a name="input_argocd_dex_memory_limit"></a> [argocd\_dex\_memory\_limit](#input\_argocd\_dex\_memory\_limit)

Description: Memory limit for the ArgoCD Dex service

Type: `string`

Default: `"128Mi"`

### <a name="input_argocd_notifications_cpu_request"></a> [argocd\_notifications\_cpu\_request](#input\_argocd\_notifications\_cpu\_request)

Description: CPU requests for the ArgoCD Notifications Controller

Type: `string`

Default: `"50m"`

### <a name="input_argocd_notifications_memory_limit"></a> [argocd\_notifications\_memory\_limit](#input\_argocd\_notifications\_memory\_limit)

Description: Memory limit for the ArgoCD Notifications Controller

Type: `string`

Default: `"256Mi"`

### <a name="input_argocd_redis_cpu_request"></a> [argocd\_redis\_cpu\_request](#input\_argocd\_redis\_cpu\_request)

Description: CPU requests for the ArgoCD Redis service

Type: `string`

Default: `"50m"`

### <a name="input_argocd_redis_memory_limit"></a> [argocd\_redis\_memory\_limit](#input\_argocd\_redis\_memory\_limit)

Description: Memory limit for the ArgoCD Redis service

Type: `string`

Default: `"128Mi"`

### <a name="input_argocd_reposerver_cpu_request"></a> [argocd\_reposerver\_cpu\_request](#input\_argocd\_reposerver\_cpu\_request)

Description: CPU requests for the ArgoCD Repository Server

Type: `string`

Default: `"50m"`

### <a name="input_argocd_reposerver_memory_limit"></a> [argocd\_reposerver\_memory\_limit](#input\_argocd\_reposerver\_memory\_limit)

Description: Memory limit for the ArgoCD Repository Server

Type: `string`

Default: `"256Mi"`

### <a name="input_argocd_server_cpu_request"></a> [argocd\_server\_cpu\_request](#input\_argocd\_server\_cpu\_request)

Description: CPU requests for the ArgoCD Server

Type: `string`

Default: `"100m"`

### <a name="input_argocd_server_memory_limit"></a> [argocd\_server\_memory\_limit](#input\_argocd\_server\_memory\_limit)

Description: Memory limit for the ArgoCD Server

Type: `string`

Default: `"256Mi"`

### <a name="input_default_role"></a> [default\_role](#input\_default\_role)

Description: Default access role assigned in ArgoCD via OIDC authentication.

Type: `string`

Default: `"readonly"`

### <a name="input_gateway_listener_name"></a> [gateway\_listener\_name](#input\_gateway\_listener\_name)

Description: Name of the Gateway listener (sectionName) for HTTPRoute.

Type: `string`

Default: `"websecure-argocd"`

### <a name="input_gateway_name"></a> [gateway\_name](#input\_gateway\_name)

Description: Name of the Gateway resource to attach HTTPRoute to.

Type: `string`

Default: `"traefik-gateway"`

### <a name="input_gateway_namespace"></a> [gateway\_namespace](#input\_gateway\_namespace)

Description: Namespace of the Gateway resource.

Type: `string`

Default: `"traefik-system"`

### <a name="input_github_access"></a> [github\_access](#input\_github\_access)

Description: Map of ArgoCD Github access token secret configuration.

Type:

```hcl
map(object({
    name            = string
    url             = string
    app_id          = string
    installation_id = string
    private_key     = string
  }))
```

Default: `{}`

### <a name="input_github_pr_comment_on_failure_enabled"></a> [github\_pr\_comment\_on\_failure\_enabled](#input\_github\_pr\_comment\_on\_failure\_enabled)

Description: Enable PR comments for failed deployments.

Type: `bool`

Default: `true`

### <a name="input_github_pr_comment_on_success_enabled"></a> [github\_pr\_comment\_on\_success\_enabled](#input\_github\_pr\_comment\_on\_success\_enabled)

Description: Enable PR comments for successful deployments.

Type: `bool`

Default: `false`

### <a name="input_helm_release_max_history"></a> [helm\_release\_max\_history](#input\_helm\_release\_max\_history)

Description: Maximum number of Helm release versions to retain as secrets in the namespace.

Type: `number`

Default: `3`

### <a name="input_idp_argocd_allowed_oauth_scopes"></a> [idp\_argocd\_allowed\_oauth\_scopes](#input\_idp\_argocd\_allowed\_oauth\_scopes)

Description: List of OAuth scopes permitted for requests to the identity provider.

Type: `list(string)`

Default:

```json
[
  "email",
  "openid",
  "profile"
]
```

### <a name="input_idp_argocd_name"></a> [idp\_argocd\_name](#input\_idp\_argocd\_name)

Description: Display name used on the login page of ArgoCD for the identity provider.

Type: `string`

Default: `"Azure"`

### <a name="input_log_level"></a> [log\_level](#input\_log\_level)

Description: Defines the logging level for application logs (e.g., debug, info, warn).

Type: `string`

Default: `"info"`

### <a name="input_metrics_enabled"></a> [metrics\_enabled](#input\_metrics\_enabled)

Description: Enable metrics endpoints for ArgoCD components.

Type: `bool`

Default: `false`

### <a name="input_p_role"></a> [p\_role](#input\_p\_role)

Description: Placeholder role, typically assigning no access in ArgoCD via OIDC.

Type: `string`

Default: `"no-access"`

### <a name="input_rbac4groups"></a> [rbac4groups](#input\_rbac4groups)

Description: Role-based access control settings for groups using OIDC.

Type: `list(map(any))`

Default: `[]`

### <a name="input_repo_revision"></a> [repo\_revision](#input\_repo\_revision)

Description: Specifies the Git branch name for the ArgoCD Application.

Type: `string`

Default: `"main"`

### <a name="input_service_monitor_enabled"></a> [service\_monitor\_enabled](#input\_service\_monitor\_enabled)

Description: Enable ServiceMonitor resources for Prometheus scraping.

Type: `bool`

Default: `false`

## Outputs

The following outputs are exported:

### <a name="output_sp_client_secret"></a> [sp\_client\_secret](#output\_sp\_client\_secret)

Description: Service Principal Client Secret

## Modules

No modules.

## Contribute
TBD

### Development
TBD

### Features
This terraform module features:
- Pre-Commit Hooks defined in `.pre-commit-config.yaml` :
  - `tfupdate`: Automatically update terraform version.
  - `terraform_fmt`: Run `terraform fmt` on all files.
  - `terraform_tflint`: Terraform linter that finds possible errors, warns about deprecated syntax and unused declerations, enforces best practices.
  - `terraform_validate`: Run `terraform validate`.
  - `terraform_checkov`: SCA (Static Code Analysis) tool for covering security and compliance best practices.
  - `terraform_trivy`: SCA tool for scanning misconfigurations and exposed secrets.
  - `terraform_wrapper_module_for_each`: Creates a wrapper module under `wrapper/` that can handle creating module instances in a loop. Useful for `terragrunt`.
  - `terraform_docs`: Run `terraform-docs` to automically generate a `README.md` readme file that covers the module requirements, providers, resources, variables and outputs. Uses `.terraform-docs.yml`
  - `conventional-pre-commit`: Strictly checks for conventional commits.
- Tests: Implements a `tests` directory where unit and integration tests are defined. They can be run with `terraform test`.

## Testing
The `tests` directory is meant run unit and integrations tests for the terraform module. For integration testing, prepare your environment in `tests/setup`.

Tests can be run with `terraform init && terraform test`.
<!-- END_TF_DOCS -->