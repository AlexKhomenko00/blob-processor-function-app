variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Resource group object containing name and location"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier"
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Storage account replication type"
  default     = "LRS"
}

variable "asp_tier" {
  type        = string
  description = "App Service Plan tier"
}

variable "asp_size" {
  type        = string
  description = "App Service Plan size"
}

variable "app_insights_conn_str" {
  type        = string
  description = "Application Insights connection string"
}

variable "app_insights_key" {
  type        = string
  description = "Applicaiton Insights key"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account for business blob handling"
}

variable "user_assigned_identity_id" {
  type        = string
  description = "ID of the user-assigned managed identity"
}

variable "user_assigned_identity_client_id" {
  type        = string
  description = "Client ID of the user-assigned managed identity"
}
