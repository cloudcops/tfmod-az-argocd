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
