resource "random_string" "name" {
  length  = 12
  special = false
  lower   = true
  upper   = false
  numeric = false
}

resource "azuread_application" "this" {
  display_name = "tf_test_app_${random_string.name.result}"
}

resource "azuread_service_principal" "this" {
  client_id = azuread_application.this.client_id
}

resource "azuread_service_principal_password" "this" {
  service_principal_id = azuread_service_principal.this.object_id
}

resource "azurerm_resource_group" "this" {
  name     = "tf_test_rg_${random_string.name.result}"
  location = "germanywestcentral"
}

#trivy:ignore:AVD-AZU-0040
#trivy:ignore:AVD-AZU-0041
#trivy:ignore:AVD-AZU-0042
#trivy:ignore:AVD-AZU-0043
#trivy:ignore:AVD-AZU-0065
#trivy:ignore:AVD-AZU-0066
#trivy:ignore:AVD-AZU-0067
resource "azurerm_kubernetes_cluster" "this" {
  #checkov:skip=CKV_AZURE_170: Not needed on test setup
  #checkov:skip=CKV_AZURE_172: Not needed on test setup
  #checkov:skip=CKV_AZURE_141: Not needed on test setup
  #checkov:skip=CKV_AZURE_115: Not needed on test setup
  #checkov:skip=CKV_AZURE_117: Not needed on test setup
  #checkov:skip=CKV_AZURE_7: Not needed on test setup
  #checkov:skip=CKV_AZURE_232: Not needed on test setup
  #checkov:skip=CKV_AZURE_226: Not needed on test setup
  #checkov:skip=CKV_AZURE_116: Not needed on test setup
  #checkov:skip=CKV_AZURE_6: Not needed on test setup
  #checkov:skip=CKV_AZURE_171: Not needed on test setup
  #checkov:skip=CKV_AZURE_168: Not needed on test setup
  #checkov:skip=CKV_AZURE_4: Not needed on test setup
  #checkov:skip=CKV_AZURE_227: Not needed on test setup
  #checkov:skip=CKV2_AZURE_29: Not needed on test setup

  name                = "tf_test_aks_${random_string.name.result}"
  location            = "germanywestcentral"
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = "tftestaks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Install Gateway API CRDs required for HTTPRoute support in argo-cd chart 9.x
resource "null_resource" "gateway_api_crds" {
  depends_on = [azurerm_kubernetes_cluster.this]

  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/${var.gateway_api_version}/standard-install.yaml"
    environment = {
      KUBECONFIG = local_file.kubeconfig.filename
    }
  }
}

resource "local_file" "kubeconfig" {
  content  = azurerm_kubernetes_cluster.this.kube_config_raw
  filename = "${path.module}/kubeconfig"
}
