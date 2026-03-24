terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_pages_project" "this" {
  account_id        = var.account_id
  name              = var.project_name
  production_branch = var.production_branch

  build_config {
    build_command   = var.build_command
    destination_dir = var.destination_dir
  }

  deployment_configs {
    production {
      environment_variables = var.environment_variables
      secrets               = var.secrets
    }
  }
}

resource "cloudflare_pages_domain" "this" {
  account_id   = var.account_id
  project_name = cloudflare_pages_project.this.name
  domain       = var.domain
}

locals {
  dns_record_name = var.dns_subdomain == "" ? var.domain : "${var.dns_subdomain}.${var.domain}"
  pages_hostname  = "${cloudflare_pages_project.this.name}.pages.dev"
}

resource "cloudflare_record" "pages_cname" {
  count = var.create_dns_record ? 1 : 0

  zone_id = var.zone_id
  name    = local.dns_record_name
  content = local.pages_hostname
  type    = "CNAME"
  proxied = true

  comment = "Managed by Terraform – points to Cloudflare Pages"
}
