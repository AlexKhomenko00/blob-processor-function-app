resource "azurerm_log_analytics_workspace" "law_betl" {
  name                = "betl-workspace-${var.environment}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = var.workspace_sku
  retention_in_days   = var.logs_retention_days
}

resource "azurerm_application_insights" "apli_betl" {
  name                = "betl-apli-${var.environment}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  workspace_id        = azurerm_log_analytics_workspace.law_betl.id
  application_type    = "web"
}
