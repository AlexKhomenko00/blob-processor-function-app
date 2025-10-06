resource "azurerm_storage_account" "betl_sa" {
  name                     = "sabetl${var.environment}${substr(var.resource_group.location, 0, 3)}"
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = {
    environment = var.environment
  }
}

resource "azurerm_storage_container" "betl_containers" {
  for_each              = toset(var.containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.betl_sa.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "betl_sa_contr" {
  scope                = azurerm_storage_account.betl_sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.identity_id
}

