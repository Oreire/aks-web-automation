output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true
}

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
  description = "The name of the Azure Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "aks_name" {
  description = "The name of the AKS Cluster"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value       = azurerm_resource_group.aks_rg.name
  description = "The name of the Azure Resource Group for AKS"
}

output "aks_name" {
  value       = azurerm_kubernetes_cluster.aks_cluster.name
  description = "The name of the AKS cluster"
}
