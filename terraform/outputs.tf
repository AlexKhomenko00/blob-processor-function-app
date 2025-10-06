output "function_app_names" {
  value = {
    for env, func_app in module.function_app : env => func_app.function_app_name
  }
  description = "Map of environment names to function app names"
}

output "function_app_hostnames" {
  value = {
    for env, func_app in module.function_app : env => func_app.function_app_default_hostname
  }
  description = "Map of environment names to function app hostnames"
}

output "storage_account_names" {
  value = {
    for env, storage in module.storage_account : env => storage.storage_account_name
  }
  description = "Map of environment names to storage account names"
}

output "resource_group_names" {
  value = {
    for env, rg in azurerm_resource_group.rg_blob_etl : env => rg.name
  }
  description = "Map of environment names to resource group names"
}
