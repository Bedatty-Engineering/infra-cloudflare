variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "worker_name" {
  description = "Unique name / script name for the Cloudflare Worker"
  type        = string
}

variable "script_content" {
  description = "JavaScript/WASM source content of the Worker script. Defaults to a 503 bootstrap placeholder used during initial provisioning before the real application is deployed via Wrangler."
  type        = string
  default     = <<-EOT
    addEventListener("fetch", event => {
      event.respondWith(handleRequest());
    });

    async function handleRequest() {
      return new Response("Worker is being provisioned. The application will be deployed shortly.", {
        status: 503,
        headers: {
          "content-type": "text/plain; charset=UTF-8",
          "cache-control": "no-store",
          "retry-after": "60"
        }
      });
    }
  EOT
}

variable "compatibility_date" {
  description = "Cloudflare Workers compatibility date (YYYY-MM-DD)"
  type        = string
  default     = "2024-01-01"
}

variable "compatibility_flags" {
  description = "Additional compatibility flags for the Worker runtime"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Plain-text environment variables injected into the Worker"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Secret environment variables (encrypted, not visible in state)"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "kv_namespace_bindings" {
  description = "KV namespace bindings: map of binding name → namespace ID"
  type        = map(string)
  default     = {}
}

variable "routes" {
  description = "List of route patterns to bind to this Worker"
  type = list(object({
    pattern = string
    zone_id = string
  }))
  default = []
}

variable "custom_domains" {
  description = <<-EOT
    Workers Custom Domains: hostnames attached directly to this Worker.
    Cloudflare manages DNS + TLS for these names inside the zone (recommended
    instead of combining workers_route + a proxied dummy DNS record).
    Use either custom_domains OR routes for the same hostname — not both.
  EOT
  type = list(object({
    hostname = string
    zone_id  = string
  }))
  default = []
}

variable "logpush_enabled" {
  description = "Whether to enable Logpush for the Worker"
  type        = bool
  default     = false
}
