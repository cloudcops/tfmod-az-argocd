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
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}
