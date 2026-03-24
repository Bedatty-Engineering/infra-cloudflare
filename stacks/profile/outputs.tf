output "worker_name" {
  description = "Cloudflare Worker script name"
  value       = module.worker.worker_name
}

output "worker_id" {
  description = "Cloudflare Worker internal ID"
  value       = module.worker.worker_id
}

output "worker_routes" {
  description = "Cloudflare Worker route IDs"
  value       = module.worker.route_ids
}

output "custom_domain" {
  description = "Primary hostname (Workers Custom Domain when use_workers_custom_domain is true)"
  value       = var.domain
}

output "workers_custom_domain_ids" {
  description = "Cloudflare Workers Custom Domain resource IDs (empty when use_workers_custom_domain is false)"
  value       = module.worker.custom_domain_ids
}

output "dns_records" {
  description = "DNS hostnames managed by this stack"
  value       = module.dns.record_hostnames
}
