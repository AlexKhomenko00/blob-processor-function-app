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

variable "workspace_sku" {
  type        = string
  description = "SKU of log analitycs workspace"
  default     = "PerGB2018"
}

variable "logs_retention_days" {
  type        = number
  description = "Retention days of logs in analitycs workspace"
  default     = 30
}
