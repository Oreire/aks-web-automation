
output "kube_config_client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_client_key" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_key
  sensitive = true
}

output "kube_config_cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "kube_config_host" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.host
  sensitive = true
}

output "resource_group_name" {
  description = "Name of the Resource Group for the AKS cluster"
  value       = azurerm_resource_group.aks_rg.name
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_cluster.name
}

output "aks_kube_config" {
  description = "Kube config for connecting to the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive   = true
}