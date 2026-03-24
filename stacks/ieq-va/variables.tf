variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
  sensitive   = true
}

variable "worker_name" {
  description = "Cloudflare Worker script name"
  type        = string
  default     = "ieq-va"
}

variable "domain" {
  description = "Custom domain"
  type        = string
}

variable "compatibility_date" {
  description = "Cloudflare Workers compatibility date"
  type        = string
  default     = "2025-09-27"
}

variable "compatibility_flags" {
  description = "Compatibility flags"
  type        = list(string)
  default     = ["nodejs_compat"]
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "logpush_enabled" {
  description = "Whether to enable Logpush"
  type        = bool
  default     = false
}

variable "extra_dns_records" {
  description = "Additional DNS records"
  type = map(object({
    name     = string
    type     = string
    content  = string
    proxied  = optional(bool, false)
    ttl      = optional(number, 1)
    comment  = optional(string, "Managed by Terraform")
    priority = optional(number, null)
  }))
  default = {}
}
