variable "region" {
  description = "Region to deploy resources to"
  default     =  "southcentralus"
}

variable "vm_sku" {
  description = "The VM type for the system node pool"
  default     = "Standard_D4ads_v5"
}
