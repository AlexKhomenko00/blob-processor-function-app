resource "azurerm_storage_account" "func_app_betl" {
  name                     = "funcblobetl${var.environment}${substr(var.resource_group.location, 0, 3)}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
}

resource "azurerm_app_service_plan" "app_sa_betl" {
  name                = "asp-blob-etl-${var.environment}-${var.resource_group.location}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  kind                = "FunctionApp"

  sku {
    tier = var.asp_tier
    size = var.asp_size
  }
}

resource "azurerm_windows_function_app" "fa_betl" {
  name                = "fa-blob-etl-${var.environment}-${var.resource_group.location}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  service_plan_id     = azurerm_app_service_plan.app_sa_betl.id

  storage_account_name       = azurerm_storage_account.func_app_betl.name
  storage_account_access_key = azurerm_storage_account.func_app_betl.primary_access_key


  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  site_config {
    application_stack {
      node_version = "~20"
    }


    application_insights_connection_string = var.app_insights_conn_str
    application_insights_key               = var.app_insights_key
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"                        = "node"
    "STORAGE_ACCOUNT_NAME"                            = var.storage_account_name
    "DATA_STORAGE_CONNECTION__blobServiceUri"         = "https://${var.storage_account_name}.blob.core.windows.net"
    "DATA_STORAGE_CONNECTION__queueServiceUri"        = "https://${var.storage_account_name}.queue.core.windows.net"
    "DATA_STORAGE_CONNECTION__credential"             = "managedidentity"
    "DATA_STORAGE_CONNECTION__clientId"               = var.user_assigned_identity_client_id
  }
}
