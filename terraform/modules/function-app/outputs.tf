output "storage_account_name" {
  value       = azurerm_storage_account.func_app_betl.name
  description = "Name of the storage account"
}

output "storage_account_primary_connection_string" {
  value       = azurerm_storage_account.func_app_betl.primary_connection_string
  sensitive   = true
  description = "Primary connection string for storage account"
}

output "app_service_plan_id" {
  value       = azurerm_app_service_plan.app_sa_betl.id
  description = "ID of the App Service Plan"
}

output "identity_id" {
  value       = var.user_assigned_identity_id
  description = "User-assigned identity ID"
}

output "function_app_name" {
  value       = azurerm_windows_function_app.fa_betl.name
  description = "Name of the Function App"
}

output "function_app_default_hostname" {
  value       = azurerm_windows_function_app.fa_betl.default_hostname
  description = "Default hostname of the Function App"
}
