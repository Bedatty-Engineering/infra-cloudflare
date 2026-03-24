locals {
  effective_route_patterns = length(var.route_patterns) > 0 ? var.route_patterns : ["${var.domain}/*"]

  # Legacy: zone route + optional proxied DNS placeholder (192.0.2.1).
  worker_routes = var.use_workers_custom_domain ? [] : [
    for pattern in local.effective_route_patterns : {
      pattern = pattern
      zone_id = var.cloudflare_zone_id
    }
  ]

  worker_dns_records = var.use_workers_custom_domain ? {} : (
    var.create_worker_dns_record ? {
      worker_entrypoint = {
        name    = var.domain
        type    = var.worker_dns_record_type
        content = var.worker_dns_record_content
        proxied = true
        ttl     = 1
        comment = "Managed by Terraform – proxied DNS entrypoint for Cloudflare Worker routes"
      }
    } : {}
  )

  worker_custom_domains = var.use_workers_custom_domain ? [
    {
      hostname = var.domain
      zone_id  = var.cloudflare_zone_id
    }
  ] : []

  managed_dns_records = merge(local.worker_dns_records, var.extra_dns_records)
}

module "worker" {
  source = "../../modules/worker"

  account_id            = var.cloudflare_account_id
  worker_name           = var.worker_name
  compatibility_date    = var.compatibility_date
  compatibility_flags   = var.compatibility_flags
  environment_variables = var.environment_variables
  routes                = local.worker_routes
  custom_domains        = local.worker_custom_domains
  logpush_enabled       = var.logpush_enabled
}

module "dns" {
  source = "../../modules/dns"

  zone_id = var.cloudflare_zone_id
  records = local.managed_dns_records
}
