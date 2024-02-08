data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.this.location
}

locals {
  kubernetes_version = data.azurerm_kubernetes_service_versions.current.versions[length(data.azurerm_kubernetes_service_versions.current.versions) - 2]
  allowed_ip_range   = ["${chomp(data.http.myip.response_body)}/32"]
  zones              = var.region == "northcentralus" ? null : ["1", "2", "3"]
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "crossplane" {
  lifecycle {
    ignore_changes = [
      default_node_pool.0.node_count,
    ]
  }

  name                              = local.crossplane_name
  resource_group_name               = azurerm_resource_group.this.name
  location                          = azurerm_resource_group.this.location
  node_resource_group               = "${local.resource_name}_crossplane_nodes_rg"
  dns_prefix                        = local.crossplane_name
  sku_tier                          = "Standard"
  automatic_channel_upgrade         = "patch"
  node_os_channel_upgrade           = "NodeImage"
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  open_service_mesh_enabled         = false
  azure_policy_enabled              = true
  local_account_disabled            = true
  role_based_access_control_enabled = true
  kubernetes_version                = local.kubernetes_version
  image_cleaner_enabled             = true
  image_cleaner_interval_hours      = 48

  api_server_access_profile {
    vnet_integration_enabled = true
    subnet_id                = azurerm_subnet.api.id
    authorized_ip_ranges     = local.allowed_ip_range
  }

  linux_profile {
    admin_username = "manager"
    ssh_key {
      key_data = tls_private_key.rsa.public_key_openssh
    }
  }

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.crossplane_identity.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.crossplane_kubelet_identity.client_id
    object_id                 = azurerm_user_assigned_identity.crossplane_kubelet_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.crossplane_kubelet_identity.id
  }

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = var.vm_sku
    zones               = local.zones
    os_disk_size_gb     = 100
    vnet_subnet_id      = azurerm_subnet.crossplane.id
    os_sku              = "Mariner"
    os_disk_type        = "Ephemeral"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 9
    max_pods            = 90
    upgrade_settings {
      max_surge = "33%"
    }
  }

  network_profile {
    dns_service_ip      = "100.${random_integer.crossplane_services_cidr.id}.0.10"
    service_cidr        = "100.${random_integer.crossplane_services_cidr.id}.0.0/16"
    pod_cidr            = "100.${random_integer.crossplane_pod_cidr.id}.0.0/16"
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    load_balancer_sku   = "standard"
  }

  maintenance_window_auto_upgrade {
    frequency = "Weekly"
    interval  = 1
    duration  = 4
    day_of_week = "Friday"
    utc_offset = "-06:00"
    start_time = "20:00"
  }

  maintenance_window_node_os {
    frequency = "Weekly"
    interval  = 1
    duration  = 4
    day_of_week = "Saturday"
    utc_offset = "-06:00"
    start_time = "20:00"
  }

  auto_scaler_profile {
    max_unready_nodes = "1"
  }

  workload_autoscaler_profile {
    keda_enabled = true
  }

  storage_profile {
    blob_driver_enabled = true
    disk_driver_enabled = true
    disk_driver_version = "v2"
    file_driver_enabled = true
  }

  oms_agent {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
    msi_auth_for_monitoring_enabled = true
  }

  microsoft_defender {
    log_analytics_workspace_id      = azurerm_log_analytics_workspace.this.id
  }

  monitor_metrics {
  }
  
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

}

data "azurerm_public_ip" "crossplane" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.crossplane.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.crossplane.node_resource_group
}
