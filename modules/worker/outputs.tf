output "worker_name" {
  description = "Name of the deployed Cloudflare Worker script"
  value       = cloudflare_workers_script.this.name
}

output "worker_id" {
  description = "Internal ID of the Worker script resource"
  value       = cloudflare_workers_script.this.id
}

output "route_ids" {
  description = "Map of route index → Cloudflare route ID"
  value       = { for k, r in cloudflare_workers_route.this : k => r.id }
}

output "custom_domain_ids" {
  description = "Map of hostname -> Workers domain ID"
  value       = { for h, d in cloudflare_workers_domain.this : h => d.id }
}

output "worker_url" {
  description = "Workers.dev subdomain URL for the script (requires workers.dev enabled)"
  value       = "https://${var.worker_name}.${var.account_id}.workers.dev"
}
