terraform {
  backend "azurerm" {
    resource_group_name  = "k8s-cloud_group"
    storage_account_name = "k8scloudtfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}