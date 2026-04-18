output "worker_name" {
  description = "Cloudflare Worker script name"
  value       = module.worker.worker_name
}

output "worker_id" {
  description = "Cloudflare Worker internal ID"
  value       = module.worker.worker_id
}

output "custom_domain" {
  description = "Primary hostname (Workers Custom Domain)"
  value       = var.domain
}

output "workers_custom_domain_ids" {
  description = "Cloudflare Workers Custom Domain resource IDs"
  value       = module.worker.custom_domain_ids
}

output "dns_records" {
  description = "DNS hostnames managed by this stack"
  value       = module.dns.record_hostnames
}

