variable "containers" {
  type    = list(string)
  default = ["input-raw", "processed", "archived", "failed"]
}

variable "environment" {
  type = string
}

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Resource group object containing name and location"
}

variable "identity_id" {
  type = string
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
