data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

resource "random_id" "this" {
  byte_length = 2
}

resource "random_pet" "this" {
  length    = 1
  separator = ""
}

resource "random_password" "password" {
  length  = 25
  special = true
}

resource "random_integer" "vnet_cidr" {
  min = 10
  max = 250
}

resource "random_integer" "crossplane_services_cidr" {
  min = 64
  max = 99
}

resource "random_integer" "crossplane_pod_cidr" {
  min = 100
  max = 127
}

locals {
  location                     = var.region
  resource_name                = "${random_pet.this.id}-${random_id.this.dec}"
  crossplane_name              = "${local.resource_name}-crossplane"
  aks_name                     = "${local.resource_name}-workload"
  flux_repository              = "https://github.com/briandenicola/crossplane-azure-demo"
  mgmt_cluster_cfg_path        = "./cluster-configs/management"
  crossplane_cfg_path          = "./cluster-configs/management/upbound-providers"
  crossplane_compositions_path = "./cluster-configs/management/upbound-providers-config"
  crossplane_claims_path       = "./cluster-configs/management/upbound-providers-claims"
  vnet_cidr                    = cidrsubnet("10.0.0.0/8", 8, random_integer.vnet_cidr.result)
  crossplane_nodes_subnet_cidr = cidrsubnet(local.vnet_cidr, 8, 2)
  crossplane_api_subnet_cidir  = cidrsubnet(local.vnet_cidr, 12, 1)
  tags                         = "Crossplane Demo Application"
}

resource "azurerm_resource_group" "this" {
  name     = "${local.resource_name}_rg"
  location = local.location

  tags = {
    Application =  local.tags
    Components  = "aks; kubevela; crossplane; upbound"
    DeployedOn  = timestamp()
    Deployer    = data.azurerm_client_config.current.object_id
  }
}