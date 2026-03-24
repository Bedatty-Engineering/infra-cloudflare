output "project_name" {
  description = "The name of the Cloudflare Pages project"
  value       = cloudflare_pages_project.this.name
}

output "url" {
  description = "Primary URL of the deployed Pages project"
  value       = "https://${cloudflare_pages_project.this.name}.pages.dev"
}

output "custom_domain" {
  description = "Custom domain attached to the project"
  value       = cloudflare_pages_domain.this.domain
}

output "subdomain" {
  description = "Cloudflare Pages default subdomain"
  value       = "${cloudflare_pages_project.this.name}.pages.dev"
}
