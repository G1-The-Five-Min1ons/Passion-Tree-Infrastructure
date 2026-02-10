# MX Records สำหรับ Email Routing
resource "cloudflare_record" "mx_route_1" {
  zone_id  = var.cloudflare_zone_id 
  name     = "@"
  content  = "route1.mx.cloudflare.net"
  type     = "MX"
  priority = 50
}

resource "cloudflare_record" "mx_route_2" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  content  = "route2.mx.cloudflare.net"
  type     = "MX"
  priority = 82
}

resource "cloudflare_record" "mx_route_3" {
  zone_id  = var.cloudflare_zone_id
  name     = "@"
  content  = "route3.mx.cloudflare.net"
  type     = "MX"
  priority = 5
}

# TXT Record สำหรับ DKIM (ยืนยันตัวตนเมล)
resource "cloudflare_record" "txt_dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "cf2024-1._domainkey" 
  content = "v=DKIM1; h=sha256; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAiweykoi+o48IOGuP7GR3X0MOExCUDY/BCRHoWBnh3rChl7WhdyCxW3jgq1daEjPPqoi7sJvdg5hEQVsgVRQP4DcnQDVjgMBASQtry4WmB1VebF+RPJB2ECPsEDTpeiI5ZyUAWJaVX7r6bznU67g7LvFq35yIo4sdlmtZGV+i0H4cpYH9+3JJ78km4KXwaf9xUJCWF6nxeD+qG6Fyruw1Qlbds2r85U9dkNDVAS3gioCvELryh1TxKGiVTkg4wqHTyHfWsp7KD3WQHYJn0RyfJJu6YEmL77zonn7p2SRmVTMP3ZEXibnC9gz3nnhR6wcYL8Q7zXypKTMD58bTixDSJwIDAQAB"
  type    = "TXT"
}

# TXT Record สำหรับ SPF (ป้องกัน Spam)
resource "cloudflare_record" "txt_spf" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  content = "v=spf1 include:_spf.mx.cloudflare.net include:_spf.mailersend.net ~all"
  type    = "TXT"
}

# CNAME สำหรับระบบ Tracking ของ MailerSend
resource "cloudflare_record" "ml_cname_email" {
  zone_id = var.cloudflare_zone_id
  name    = "email"
  content = "links.mailersend.net"
  type    = "CNAME"
  proxied = false # ต้องปิด Proxy (เมฆสีเทา) เพื่อให้ระบบเมลตรวจสอบได้
}

# CNAME สำหรับ DKIM ของ MailerSend
resource "cloudflare_record" "ml_cname_dkim" {
  zone_id = var.cloudflare_zone_id
  name    = "mlsend2._domainkey"
  content = "mlsend2._domainkey.mailersend.net"
  type    = "CNAME"
  proxied = false
}

# CNAME สำหรับ MTA (Mail Transfer Agent)
resource "cloudflare_record" "ml_cname_mta" {
  zone_id = var.cloudflare_zone_id
  name    = "mta.passion-tree.org"
  content = "mailersend.net"
  type    = "CNAME"
  proxied = false
}

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