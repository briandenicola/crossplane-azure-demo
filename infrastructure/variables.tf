variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "namespace" {
  description = "The namespace to deploy Crossplane to"
  default = "upbound-system"
}

variable "vm_sku" {
  description = "The VM type for the system node pool"
  default     = "Standard_D4ads_v5"
}
