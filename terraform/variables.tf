variable "environments" { # Fixed typo
  type = map(object({
    location            = string
    asp_tier            = string
    asp_size            = string
    account_tier        = string
    account_replication = string
    logs_retention_days = string
  }))
  description = "Map of environments with their configurations"
}
