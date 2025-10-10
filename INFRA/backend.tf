
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "aks-resource-group"
#     storage_account_name = "k8scloudtfstateuks"
#     container_name       = "tfstate"
#     key                  = "terraform.tfstate"
#   }
# }

terraform {
  backend "azurerm" {
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = ""
    access_key           = ""
  }
}

# To use this backend configuration, create a file named `backend.tfvars` in the same directory