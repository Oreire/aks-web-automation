
terraform {
  backend "azurerm" {
    resource_group_name  = "aks-resource-group"
    storage_account_name = "k8scloudtfstateuks"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
