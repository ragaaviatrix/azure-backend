terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.8.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.0"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate a random storage name
resource "random_string" "tf-name" {
  length  = 8
  upper   = false
  number  = true
  lower   = true
  special = false
}
# Create a Resource Group for the Terraform State File
resource "azurerm_resource_group" "state-rg" {
  name     = "azweu-avia-deploy-resources"
  location = var.location
  lifecycle {
    prevent_destroy = true
  }
  tags = {
    environment = var.environment
  }
}
# Create a Storage Account for the Terraform State File
resource "azurerm_storage_account" "state-sta" {
  depends_on = [azurerm_resource_group.state-rg]

  name                      = "azweuaviadeploystg"
  resource_group_name       = azurerm_resource_group.state-rg.name
  location                  = azurerm_resource_group.state-rg.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  access_tier               = "Hot"
  account_replication_type  = "ZRS"
  enable_https_traffic_only = true
  min_tls_version           = "TLS1_2"
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    environment = var.environment
  }
}
# Create a Storage Container for the Core State File
resource "azurerm_storage_container" "core-container" {
  depends_on = [azurerm_storage_account.state-sta]

  name                 = "core-tfstate"
  storage_account_name = azurerm_storage_account.state-sta.name
}
