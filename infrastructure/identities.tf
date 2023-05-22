resource "azurerm_user_assigned_identity" "crossplane_cluster_identity" {
  name                = "${local.crossplane_name}-cluster-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_user_assigned_identity" "crossplane_kubelet_identity" {
  name                = "${local.crossplane_name}-kubelet-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_user_assigned_identity" "crossplane_identity" {
  name                = "${local.crossplane_name}-crossplane-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}

resource "azurerm_federated_identity_credential" "crossplane_identity" {
  name                = "${local.crossplane_name}-crossplane-identity"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.crossplane.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.crossplane_identity.id
  subject             = "system:serviceaccount:${var.namespace}:${local.crossplane_name}-crossplane-identity"
}


/*resource "azuread_application" "crossplane" {
  display_name = "${local.resource_name}-crossplane"
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "crossplane" {
  application_id               = azuread_application.crossplane.application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "crossplane" {
  service_principal_id = azuread_service_principal.crossplane.object_id
}*/