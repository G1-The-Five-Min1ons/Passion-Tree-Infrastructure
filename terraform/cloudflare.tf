# ─── Email/MailerSend DNS Records ───
# MX records จัดการโดย Cloudflare Email Routing โดยตรง (ไม่สามารถสร้างผ่าน API ได้)
# DKIM, SPF, MailerSend CNAME records สร้างไว้แล้วที่ Cloudflare Dashboard
# ไม่ต้องจัดการผ่าน Terraform เพราะจะชนกับ records ที่มีอยู่แล้ว

# ─── Azure Container Apps DNS ───

# CNAME ชี้ passion-tree.org → Azure Container App FQDN
# Cloudflare Proxy (เมฆส้ม) จัดการ TLS termination ให้
resource "cloudflare_record" "backend_cname" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = azurerm_container_app.go_backend.ingress[0].fqdn
  type    = "CNAME"
  proxied = true # Cloudflare จัดการ SSL/TLS ให้
}

# TXT Record สำหรับ Azure Domain Verification
# Azure ต้องการ record นี้เพื่อยืนยันว่าเราเป็นเจ้าของ domain
resource "cloudflare_record" "domain_verification" {
  zone_id = var.cloudflare_zone_id
  name    = "asuid"
  content = azurerm_container_app.go_backend.custom_domain_verification_id
  type    = "TXT"
}