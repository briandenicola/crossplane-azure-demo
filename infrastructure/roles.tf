resource "azurerm_role_assignment" "cluster_owner" {
  scope                = azurerm_resource_group.this.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "crossplane_cluster_role_assignment_network_contributor" {
  scope                            = azurerm_virtual_network.this.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.crossplane_cluster_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "crossplane_cluster_role_assignment_msi_owner" {
  scope                            = azurerm_user_assigned_identity.crossplane_kubelet_identity.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = azurerm_user_assigned_identity.crossplane_cluster_identity.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "crossplane_role_assignment_msi" {
  scope                            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  role_definition_name             = "Contributor"
  principal_id                     = azurerm_user_assigned_identity.crossplane_identity.principal_id
  skip_service_principal_aad_check = true
}