# ── Azure Container Registry ──
variable "acr_server" {
  description = "FQDN of Azure Container Registry, e.g., passiontreecontainerregistry.azurecr.io"
  type        = string
}

# used when creating Container App for the first time, CI/CD will overwrite later
variable "backend_image" {
  description = "Image name of Go Backend"
  type        = string
}

variable "ai_image" {
  description = "Image name of FastAPI AI Service"
  type        = string
}

# ── Cloudflare ──
variable "cloudflare_zone_id" {
  description = "Zone ID of the domain in Cloudflare"
  type        = string
}
