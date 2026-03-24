output "record_ids" {
  description = "Map of record label → Cloudflare record ID"
  value       = { for k, r in cloudflare_record.this : k => r.id }
}

output "record_hostnames" {
  description = "Map of record label → fully-qualified hostname"
  value       = { for k, r in cloudflare_record.this : k => r.hostname }
}
