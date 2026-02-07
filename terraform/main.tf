provider "azurerm" {
  features {}
}

# ใช้ data source เพื่อดึงข้อมูล Resource Group ที่มีอยู่แล้ว (ชื่อ Passion-Tree)
data "azurerm_resource_group" "passion_tree" {
  name = "Passion-Tree"
}

# สร้างพื้นที่เก็บ Log สำหรับ Container Apps
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "passiontree-log-workspace"
  location            = azurerm_resource_group.passion_tree.location
  resource_group_name = azurerm_resource_group.passion_tree.name
  sku                 = "PerGB2018"
}

output "domain_verification_id" {
  value = azurerm_container_app.go_backend.custom_domain_verification_id
  description = "Bring this value and put it in the TXT record at Cloudflare (Name: asuid)"
}

output "aca_fqdn" {
  value = azurerm_container_app.go_backend.ingress[0].fqdn
  description = "Bring this value and put it in the CNAME record at Cloudflare"
}