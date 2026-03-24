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
  default     = "profile"
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


variable "use_workers_custom_domain" {
  description = <<-EOT
    When true, attaches var.domain via Cloudflare Workers Custom Domains (DNS + cert
    managed by Cloudflare). No workers_route or proxied dummy DNS record is used for
    that hostname. Set false to use the legacy pattern: workers_route + proxied A/CNAME.
  EOT
  type        = bool
  default     = true
}

variable "route_patterns" {
  description = "Optional explicit Worker route patterns (only used when use_workers_custom_domain is false)"
  type        = list(string)
  default     = []
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

variable "create_worker_dns_record" {
  description = "Whether to create the proxied DNS record"
  type        = bool
  default     = true
}

variable "worker_dns_record_type" {
  description = "DNS record type"
  type        = string
  default     = "A"
}

variable "worker_dns_record_content" {
  description = "Placeholder DNS record content"
  type        = string
  default     = "192.0.2.1"
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
