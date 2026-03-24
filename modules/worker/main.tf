terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "cloudflare_workers_script" "this" {
  account_id          = var.account_id
  name                = var.worker_name
  content             = var.script_content
  compatibility_date  = var.compatibility_date
  compatibility_flags = var.compatibility_flags

  # Bootstrap with Terraform once; subsequent code deployments are owned by Wrangler.
  lifecycle {
    ignore_changes = [content]
  }

  dynamic "plain_text_binding" {
    for_each = var.environment_variables
    content {
      name = plain_text_binding.key
      text = plain_text_binding.value
    }
  }

  dynamic "secret_text_binding" {
    for_each = var.secrets
    content {
      name = secret_text_binding.key
      text = secret_text_binding.value
    }
  }

  dynamic "kv_namespace_binding" {
    for_each = var.kv_namespace_bindings
    content {
      name         = kv_namespace_binding.key
      namespace_id = kv_namespace_binding.value
    }
  }

  logpush = var.logpush_enabled
}

resource "cloudflare_workers_route" "this" {
  for_each = {
    for idx, r in var.routes : tostring(idx) => r
  }

  zone_id     = each.value.zone_id
  pattern     = each.value.pattern
  script_name = cloudflare_workers_script.this.name
}

resource "cloudflare_workers_domain" "this" {
  for_each = {
    for d in var.custom_domains : d.hostname => d
  }

  account_id = var.account_id
  hostname   = each.value.hostname
  service    = var.worker_name
  zone_id    = each.value.zone_id

  depends_on = [cloudflare_workers_script.this]
}
