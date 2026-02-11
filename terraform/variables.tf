# ── Azure Container Registry ──
variable "acr_server" {
  type        = string
  description = "FQDN of Azure Container Registry"
}

variable "backend_image" {
  type        = string
  description = "Image name of Go Backend"
}

variable "ai_image" {
  type        = string
  description = "Image name of FastAPI AI Service"
}

# ── Location ──
variable "aca_location" {
  type    = string
  default = "eastasia"
}

# ── Cloudflare ──
variable "cloudflare_zone_id" {
  type = string
}

# ── Database Secrets ──
variable "db_server" {
  type      = string
  sensitive = true
}

variable "db_database" {
  type = string
}

variable "db_user" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_port" {
  type    = string
  default = "1433"
}

# ── SMTP / MailerSend ──
variable "mailersend_api_key" {
  type      = string
  sensitive = true
}

variable "smtp_host" {
  type = string
}

variable "smtp_port" {
  type = string
}

variable "smtp_username" {
  type      = string
  sensitive = true
}

variable "smtp_password" {
  type      = string
  sensitive = true
}

variable "smtp_from_email" {
  type = string
}

# ── Azure Storage ──
variable "azure_storage_account_name" {
  type = string
}

variable "azure_storage_account_key" {
  type      = string
  sensitive = true
}

variable "azure_storage_connection_string" {
  type      = string
  sensitive = true
}

variable "container_learning_path" {
  type = string
}

variable "container_profile" {
  type = string
}

# ── AI Services ──
variable "groq_api_key" {
  type      = string
  sensitive = true
}

variable "jina_api_key" {
  type      = string
  sensitive = true
}

variable "hf_token" {
  type      = string
  sensitive = true
}

variable "qdrant_url" {
  type = string
}

variable "qdrant_api_key" {
  type      = string
  sensitive = true
}