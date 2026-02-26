# [3.0.0](https://github.com/cloudcops/tfmod-az-argocd/compare/2.6.2...3.0.0) (2026-02-26)


* feat!: add Gateway API support for ArgoCD routing ([#24](https://github.com/cloudcops/tfmod-az-argocd/issues/24)) ([eaebc4e](https://github.com/cloudcops/tfmod-az-argocd/commit/eaebc4e88d6d4c8bfb4fd00aed0fc5ca5617c2ae))


### BREAKING CHANGES

* Removed variables tls_enabled, ingress_class_name, use_gateway_api.
ArgoCD now only supports Gateway API routing via HTTPRoute.
Server runs in insecure mode (HTTP) with TLS termination at Gateway.

* MPS-1061: restore comments removed in previous commit

* feat!(MPS-1061): update CI secrets

* feat: add provider

* MPS-1061: hard coded tenant

* feat: execute CI

* feat: remove resolved TODO comment

* MPS-1061: update gateway variable defaults from Envoy to Traefik

* feat: run precommit

* feat!(MPS-1061): upgrade argo-cd chart to 9.0.0 for HTTPRoute support

* fix(MPS-1061): install Gateway API CRDs in test setup for HTTPRoute

## [2.6.2](https://github.com/cloudcops/tfmod-az-argocd/compare/2.6.1...2.6.2) (2026-02-10)


### Bug Fixes

* **MPS-1147:** limit helm release history to prevent secret accumulation ([#26](https://github.com/cloudcops/tfmod-az-argocd/issues/26)) ([5521ddb](https://github.com/cloudcops/tfmod-az-argocd/commit/5521ddb21f7bb6daa02559cf7ad5ddd7db97b812))

## [2.3.2](https://github.com/cloudcops/tfmod-az-argocd/compare/2.3.1...2.3.2) (2025-09-12)


### Bug Fixes

* **MPS-654:** make argoCD PR comments sticky ([#18](https://github.com/cloudcops/tfmod-az-argocd/issues/18)) ([e807724](https://github.com/cloudcops/tfmod-az-argocd/commit/e8077246925b565ff0c6b93c6c751fa83a3ce265))

## [2.3.1](https://github.com/cloudcops/tfmod-az-argocd/compare/2.3.0...2.3.1) (2025-08-27)


### Bug Fixes

* **MPS-579:** use valid values for notification ([#14](https://github.com/cloudcops/tfmod-az-argocd/issues/14)) ([0159a2b](https://github.com/cloudcops/tfmod-az-argocd/commit/0159a2b5076388ff448ea4b36525b698d3da0e91))

# [2.3.0](https://github.com/cloudcops/tfmod-az-argocd/compare/2.2.0...2.3.0) (2025-08-04)


### Features

* **MPS-529:** add service monitor setting  ([588951a](https://github.com/cloudcops/tfmod-az-argocd/commit/588951adc9ddf70fb04803d934456feefa5db640))

# [2.2.0](https://github.com/cloudcops/tfmod-az-argocd/compare/2.1.0...2.2.0) (2025-07-31)


### Features

* **CC-9:** add necessary argocd secrets ([d424d95](https://github.com/cloudcops/tfmod-az-argocd/commit/d424d95043a03048c8272d7fae2818d7e7ebbd15))

# [2.1.0](https://github.com/cloudcops/tfmod-az-argocd/compare/2.0.0...2.1.0) (2025-07-25)


### Features

* **CC-15:** Configure Renovate and upgrade provider versions ([#2](https://github.com/cloudcops/tfmod-az-argocd/issues/2)) ([324e08e](https://github.com/cloudcops/tfmod-az-argocd/commit/324e08ef2dd7c202119f74f498a84e5a0d588aca))

# [2.0.0](https://github.com/cloudcops/tfmod-az-argocd/compare/1.5.0...2.0.0) (2025-07-25)


### Features

* **CC-9:** rework ArgoCD with resource definitions ([#3](https://github.com/cloudcops/tfmod-az-argocd/issues/3)) ([7bd867f](https://github.com/cloudcops/tfmod-az-argocd/commit/7bd867f4afb44ce0be82bdbc9bdb36df3688354b))


### BREAKING CHANGES

* **CC-9:** remove unnecessary variables

* feat(CC-9): adjust resource capacity based on best practice

* feat(CC-9): run precommit

* fix(CC-9): rename argocd resources variable names

* fix(CC-9): run precommit

* feat(CC-9): add dryrun option and sensitive true

* feat(CC-9): add sensitive output for wrapper module

* feat(CC-9): remove unnecessary commentremove unnecessary memory limitsremove limit range resources

* feat(CC-9): add validation for resource variables

* fix(CC-9): modifying descriptions properly

* fix(CC-9): remove unnecessary description

* chore(CC-9): run pre commit

* fix(CC-9): modifying resource capacities

* fix(CC-9): run precommit

* feat(CC-9): use latest version providers

* hotfix(CC-9): apply latest helm version

# [1.5.0](https://github.com/cloudcops/tfmod-az-argocd/compare/1.4.0...1.5.0) (2025-07-04)


### Features

* **CC-9:** Rework ArgoCD Module ([#1](https://github.com/cloudcops/tfmod-az-argocd/issues/1)) ([08a200a](https://github.com/cloudcops/tfmod-az-argocd/commit/08a200ac879abd7228398912ed43bdcae65be414))

# [1.4.0](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.3.0...1.4.0) (2025-05-14)


### Features

* upgrade azurerm version with latest ([#14](https://github.com/myperfectstay/tfmod-az-argocd/issues/14)) ([4395b72](https://github.com/myperfectstay/tfmod-az-argocd/commit/4395b7229e1a3b8147e523f4282b4b311c0a832a))

# [1.3.0](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.2.2...1.3.0) (2025-05-12)


### Features

* update azurerm version ([#13](https://github.com/myperfectstay/tfmod-az-argocd/issues/13)) ([b4b1ea8](https://github.com/myperfectstay/tfmod-az-argocd/commit/b4b1ea87d5ddfafa577d99390827160fc6c07419))

## [1.2.2](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.2.1...1.2.2) (2025-03-19)


### Bug Fixes

* remove mac system file and run test ([#9](https://github.com/myperfectstay/tfmod-az-argocd/issues/9)) ([077082d](https://github.com/myperfectstay/tfmod-az-argocd/commit/077082dd7a6e03fb50bdfe667c5f0381923ab34f))

# [1.2.0](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.1.0...1.2.0) (2024-08-22)


### Bug Fixes

* **DEV-173:** set trivy parallelism to 1 ([20db4fb](https://github.com/myperfectstay/tfmod-az-argocd/commit/20db4fb7d4e4e5fa6722c84ca4cb4a7574c49010))


### Features

* **DEV-173:** Add argocd notifications ([bbd96e2](https://github.com/myperfectstay/tfmod-az-argocd/commit/bbd96e286e02b5863fcd09321bdab4d0f3dd1a44))

# [1.1.0](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.0.1...1.1.0) (2024-06-26)


### Features

* **access_tokens:** Switch to github access configuration using github app auth ([#4](https://github.com/myperfectstay/tfmod-az-argocd/issues/4)) ([703239f](https://github.com/myperfectstay/tfmod-az-argocd/commit/703239fa835e32a573775e6646829d736d132c35))

## [1.0.1](https://github.com/myperfectstay/tfmod-az-argocd/compare/1.0.0...1.0.1) (2024-06-26)


### Bug Fixes

* **resources:** Remove high CPU limits for argocd components ([#3](https://github.com/myperfectstay/tfmod-az-argocd/issues/3)) ([07f459a](https://github.com/myperfectstay/tfmod-az-argocd/commit/07f459aa39690919a1250e8c21668f29de568a2c))

# 1.0.0 (2024-06-25)


### Features

* initial implementation ([#2](https://github.com/myperfectstay/tfmod-az-argocd/issues/2)) ([39b6541](https://github.com/myperfectstay/tfmod-az-argocd/commit/39b65415a168f120741a3cd68d8a155d746b2374))
