locals {
  worker_custom_domains = [
    {
      hostname = var.domain
      zone_id  = var.cloudflare_zone_id
    }
  ]

  managed_dns_records = var.extra_dns_records
}

module "worker" {
  source = "../../modules/worker"

  account_id            = var.cloudflare_account_id
  worker_name           = var.worker_name
  compatibility_date    = var.compatibility_date
  compatibility_flags   = var.compatibility_flags
  environment_variables = var.environment_variables
  routes                = []
  custom_domains        = local.worker_custom_domains
  logpush_enabled       = var.logpush_enabled
}

module "dns" {
  source = "../../modules/dns"

  zone_id = var.cloudflare_zone_id
  records = local.managed_dns_records
}
