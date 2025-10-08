terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
  }

  backend "azurerm" {
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg_blob_etl" {
  for_each = var.environments

  name     = "rg-betl-${each.key}"
  location = each.value.location
}

resource "azurerm_user_assigned_identity" "betl_identity" {
  for_each = var.environments

  name                = "id-betl-${each.key}"
  resource_group_name = azurerm_resource_group.rg_blob_etl[each.key].name
  location            = azurerm_resource_group.rg_blob_etl[each.key].location
}

module "monitoring" {
  for_each = var.environments
  source   = "./modules/monitoring"

  resource_group = {
    name     = azurerm_resource_group.rg_blob_etl[each.key].name
    location = azurerm_resource_group.rg_blob_etl[each.key].location
  }

  logs_retention_days = each.value.logs_retention_days
  environment         = each.key
}

module "storage_account" {
  source   = "./modules/storage-account"
  for_each = var.environments

  environment = each.key
  resource_group = {
    name     = azurerm_resource_group.rg_blob_etl[each.key].name
    location = azurerm_resource_group.rg_blob_etl[each.key].location
  }
  identity_id              = azurerm_user_assigned_identity.betl_identity[each.key].principal_id
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication
}

module "function_app" {
  source   = "./modules/function-app"
  for_each = var.environments

  environment = each.key
  resource_group = {
    name     = azurerm_resource_group.rg_blob_etl[each.key].name
    location = azurerm_resource_group.rg_blob_etl[each.key].location
  }
  asp_size                         = each.value.asp_size
  asp_tier                         = each.value.asp_tier
  app_insights_conn_str            = module.monitoring[each.key].apli_connection_string
  app_insights_key                 = module.monitoring[each.key].instrumentation_key
  storage_account_name             = module.storage_account[each.key].storage_account_name
  user_assigned_identity_id        = azurerm_user_assigned_identity.betl_identity[each.key].id
  user_assigned_identity_client_id = azurerm_user_assigned_identity.betl_identity[each.key].client_id
}
