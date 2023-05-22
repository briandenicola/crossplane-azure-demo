output "AKS_RESOURCE_GROUP" {
  value     = azurerm_kubernetes_cluster.crossplane.resource_group_name
  sensitive = false
}

output "crossplane_AKS_CLUSTER_NAME" {
  value     = azurerm_kubernetes_cluster.crossplane.name
  sensitive = false
}

output "AKS_SUBSCRIPTION_ID" {
  value     = data.azurerm_client_config.current.subscription_id
  sensitive = false
}

output "AKS_TENANT_ID" {
  value     = data.azurerm_client_config.current.tenant_id
  sensitive = false
}

output "UMI_CLIENT_ID" {
  value     = azurerm_user_assigned_identity.crossplane_identity.client_id
  sensitive = false
}