variable "zone_id" {
  description = "Cloudflare DNS zone ID"
  type        = string
  sensitive   = true
}

variable "records" {
  description = "Map of DNS records to create. Key is a unique label used as the Terraform resource name."
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
