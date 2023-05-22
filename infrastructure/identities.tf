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
  name                = "${local.crossplane_name}-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
}