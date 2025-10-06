output "storage_account_id" {
  value       = azurerm_storage_account.betl_sa.id
  description = "ID of the storage account"
}

output "storage_account_name" {
  value       = azurerm_storage_account.betl_sa.name
  description = "Name of the storage account"
}

output "primary_blob_endpoint" {
  value       = azurerm_storage_account.betl_sa.primary_blob_endpoint
  description = "Primary blob endpoint URL"
}

output "primary_connection_string" {
  value       = azurerm_storage_account.betl_sa.primary_connection_string
  sensitive   = true
  description = "Primary connection string"
}

output "container_names" {
  value       = [for c in azurerm_storage_container.betl_containers : c.name]
  description = "List of container names"
}
