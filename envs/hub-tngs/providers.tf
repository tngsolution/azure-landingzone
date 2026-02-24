terraform {
  required_version = ">= 1.4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}

}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id != "" ? var.subscription_id : null
  storage_use_azuread = true
}
