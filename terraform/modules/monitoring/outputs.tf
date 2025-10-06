output "instrumentation_key" {
  value     = azurerm_application_insights.apli_betl.instrumentation_key
  sensitive = true
}

output "apli_connection_string" {
  value     = azurerm_application_insights.apli_betl.connection_string
  sensitive = true
}
output "app_id" {
  value = azurerm_application_insights.apli_betl.app_id
}
