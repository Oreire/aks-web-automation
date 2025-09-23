terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

#   subscription_id = "ff4b0f27-bd73-4dbf-a413-78b31e6d283e"
#   tenant_id       = "cd1f86d6-1102-4c2a-b885-60cc94cf9e23"
}
