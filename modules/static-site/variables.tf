variable "project_name" {
  description = "Name of the Cloudflare Pages project"
  type        = string
}

variable "domain" {
  description = "Custom domain to associate with the project (e.g. example.com)"
  type        = string
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare DNS zone ID for the domain"
  type        = string
  sensitive   = true
}

variable "production_branch" {
  description = "Git branch to use as the production deployment"
  type        = string
  default     = "main"
}

variable "build_command" {
  description = "Build command for the Pages project (leave empty if pre-built)"
  type        = string
  default     = ""
}

variable "destination_dir" {
  description = "Output directory after build (e.g. dist, public)"
  type        = string
  default     = "dist"
}

variable "environment_variables" {
  description = "Environment variables to inject at build time"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret environment variables (encrypted at rest)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "create_dns_record" {
  description = "Whether to create a CNAME DNS record pointing to the Pages domain"
  type        = bool
  default     = true
}

variable "dns_subdomain" {
  description = "Subdomain prefix for the DNS record (empty string = apex record)"
  type        = string
  default     = ""
}
