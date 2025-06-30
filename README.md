<!-- BEGIN_TF_DOCS -->
# Terraform Module: `argocd`

## Overview
This module creates ArgoCD for an Azure AKS cluster in Azure.

## Example usage

```
module "argocd" {
  source       = "../modules/argocd"
  argocd_version     = "v2.10.7"
  repo_revision      = "main"
  repo_url           = "https://git.immonow.at/now/dev-ops/continuous-deployments/projects/argocd-cluster-apps.git"
  url                = "argocd.example.com"
  sp_client_id                = "..."
  sp_client_secret            = "..."
  cluster_name                = "..."
  cluster_resource_group_name = "..."
  tls_enabled        = true
  ingress_class_name = "nginx-public"
  app_path           = "overlays/tests"
  idp_endpoint       = "https://login.microsoftonline.com/39d11cc9-3e65-4ac2-938b-9e5264b7a7ce/v2.0"
  access_token_secret_configuration = {
    "0" = {
      url      = "https://git.immonow.at/now/dev-ops/continuous-deployments/projects/argocd-cluster-apps.git"
      username = "token"
      name     = "argocd-cluster-apps"
      password = "..."
      type     = "git"
    }
    "1" = {
      url      = "https://git.immonow.at/api/v4/projects/99/packages/helm/generic"
      username = "token"
      name     = "helm-charts"
      password = "..."
      type     = "helm"
    }
  }
  rbac4groups = [
    {
      name = "sg-now-devops"
      role = "admin"
    },
    {
      name = "sg-now-developer"
      role = "reader"
    }
  ]
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.0)

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.8.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (2.51.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (3.105.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (4.28.0)

- <a name="requirement_helm"></a> [helm](#requirement\_helm) (2.17.0)

- <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) (1.19.0)

- <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) (2.29.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (0.13.1)

## Providers

The following providers are used by this module:

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (2.51.0)

- <a name="provider_helm"></a> [helm](#provider\_helm) (2.17.0)

- <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) (1.19.0)

- <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) (2.29.0)

- <a name="provider_time"></a> [time](#provider\_time) (0.13.1)

## Resources

The following resources are used by this module:

- [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/2.17.0/docs/resources/release) (resource)
- [kubectl_manifest.app_of_apps](https://registry.terraform.io/providers/gavinbunney/kubectl/1.19.0/docs/resources/manifest) (resource)
- [kubernetes_limit_range.default_resources](https://registry.terraform.io/providers/hashicorp/kubernetes/2.29.0/docs/resources/limit_range) (resource)
- [kubernetes_namespace.argocd](https://registry.terraform.io/providers/hashicorp/kubernetes/2.29.0/docs/resources/namespace) (resource)
- [time_sleep.wait_for_crds](https://registry.terraform.io/providers/hashicorp/time/0.13.1/docs/resources/sleep) (resource)
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

### <a name="input_kubernetes_client_certificate"></a> [kubernetes\_client\_certificate](#input\_kubernetes\_client\_certificate)

Description: n/a

Type: `string`

### <a name="input_kubernetes_client_key"></a> [kubernetes\_client\_key](#input\_kubernetes\_client\_key)

Description: n/a

Type: `string`

### <a name="input_kubernetes_cluster_ca_certificate"></a> [kubernetes\_cluster\_ca\_certificate](#input\_kubernetes\_cluster\_ca\_certificate)

Description: n/a

Type: `string`

### <a name="input_kubernetes_host"></a> [kubernetes\_host](#input\_kubernetes\_host)

Description: n/a

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

### <a name="input_argocd_chart_version"></a> [argocd\_chart\_version](#input\_argocd\_chart\_version)

Description: Version of ArgoCD Helm Chart to install

Type: `string`

Default: `"8.1.2"`

### <a name="input_default_role"></a> [default\_role](#input\_default\_role)

Description: Default access role assigned in ArgoCD via OIDC authentication.

Type: `string`

Default: `"readonly"`

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

### <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name)

Description: Specifies the name of the Ingress class used for routing traffic.

Type: `string`

Default: `"nginx"`

### <a name="input_log_level"></a> [log\_level](#input\_log\_level)

Description: Defines the logging level for application logs (e.g., debug, info, warn).

Type: `string`

Default: `"info"`

### <a name="input_namespace_memory_limit"></a> [namespace\_memory\_limit](#input\_namespace\_memory\_limit)

Description: Kubernetes memory limit range.

Type: `string`

Default: `"1Gi"`

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

### <a name="input_tls_enabled"></a> [tls\_enabled](#input\_tls\_enabled)

Description: Flag to enable or disable TLS security.

Type: `bool`

Default: `false`

## Outputs

No outputs.

## Modules

No modules.

## Contribute

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

## Note
This module is meant to be used internally by `myperfectstay.ai`. When selling products that rely on Terraform, be careful with HashiCorps BSL license. In such a case, get an enterprise license or try to use [OpenTofu](https://opentofu.org/).
<!-- END_TF_DOCS -->