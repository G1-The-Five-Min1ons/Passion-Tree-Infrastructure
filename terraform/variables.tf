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

# ── Location ──
variable "aca_location" {
  description = "Azure region for Container Apps and networking (subscription quota may block some regions)"
  type        = string
  default     = "eastasia"
}

# ── Cloudflare ──
variable "cloudflare_zone_id" {
  description = "Zone ID of the domain in Cloudflare"
  type        = string
}

# ── Database Secrets ──
variable "db_server" {
  description = "Database Server Hostname"
  type        = string
  sensitive   = true
}

variable "db_database" {
  description = "Database Name"
  type        = string
}

variable "db_user" {
  description = "Database User"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database Password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database Port"
  type        = string
  default     = "1433" # Default for Azure SQL
}

# ── SMTP / MailerSend ──
variable "mailersend_api_key" {
  description = "MailerSend API Key"
  type        = string
  sensitive   = true
}

variable "smtp_host" {
  description = "SMTP Host"
  type        = string
}

variable "smtp_port" {
  description = "SMTP Port"
  type        = string
}

variable "smtp_username" {
  description = "SMTP Username"
  type        = string
  sensitive   = true
}

variable "smtp_password" {
  description = "SMTP Password"
  type        = string
  sensitive   = true
}

variable "smtp_from_email" {
  description = "SMTP From Email"
  type        = string
}

# ── Azure Storage ──
variable "azure_storage_account_name" {
  description = "Azure Storage Account Name"
  type        = string
}

variable "azure_storage_account_key" {
  description = "Azure Storage Account Key"
  type        = string
  sensitive   = true
}

variable "azure_storage_connection_string" {
  description = "Azure Storage Connection String"
  type        = string
  sensitive   = true
}

variable "container_learning_path" {
  description = "Storage Container Name for Learning Path"
  type        = string
}

variable "container_profile" {
  description = "Storage Container Name for Profiles"
  type        = string
}

# ── AI Services ──
variable "groq_api_key" {
  description = "Groq API Key"
  type        = string
  sensitive   = true
}

variable "jina_api_key" {
  description = "Jina AI API Key"
  type        = string
  sensitive   = true
}

variable "hf_token" {
  description = "Hugging Face Token"
  type        = string
  sensitive   = true
}

variable "qdrant_url" {
  description = "Qdrant URL"
  type        = string
}

variable "qdrant_api_key" {
  description = "Qdrant API Key"
  type        = string
  sensitive   = true
}
