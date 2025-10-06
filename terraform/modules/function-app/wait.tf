resource "time_sleep" "wait_for_storage" {
  depends_on = [azurerm_storage_account.func_app_betl]
  create_duration = "30s"
}
