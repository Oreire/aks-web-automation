variable "resource_group_name" {
  description = "The name of the resource group for AKS."
  type        = string
  default     = "aks-resource-group"
}

variable "location" {
  description = "The Azure region to deploy resources."
  type        = string
  default     = "UK South"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default     = "aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
  default     = "akscluster"
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for the default node pool."
  type        = string
  default     = "Standard_DS2_v2"
}

variable "environment" {
  description = "Environment tag for resources."
  type        = string
  default     = "Dev"
}