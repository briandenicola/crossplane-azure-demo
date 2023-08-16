resource "azurerm_kubernetes_cluster_extension" "flux" {
  depends_on = [
    azurerm_kubernetes_cluster.crossplane
  ]
  name           = "flux"
  cluster_id     = azurerm_kubernetes_cluster.this.id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "flux_config" {
  depends_on = [
    azurerm_kubernetes_cluster_extension.flux
  ]

  name       = "aks-flux-extension"
  cluster_id = azurerm_kubernetes_cluster.crossplane.id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = local.flux_repository
    reference_type           = "branch"
    reference_value          = "main"
    timeout_in_seconds       = 600
    sync_interval_in_seconds = 30
  }

  kustomizations {
    name                       = "addons"
    path                       = local.mgmt_cluster_cfg_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on                 = []
  }

  kustomizations {
    name                       = "crossplane-cfg"
    path                       = local.crossplane_cfg_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "addons"
    ]
  }

  kustomizations {
    name                       = "crossplane-compositions"
    path                       = local.crossplane_compositions_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "crossplane-cfg"
    ]
  }

  kustomizations {
    name                       = "crossplane-claims"
    path                       = local.crossplane_claims_path
    timeout_in_seconds         = 600
    sync_interval_in_seconds   = 120
    retry_interval_in_seconds  = 300
    garbage_collection_enabled = true
    depends_on = [
      "crossplane-compositions"
    ]
  }
}