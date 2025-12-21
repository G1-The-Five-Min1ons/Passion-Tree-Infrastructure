provider "azurerm" {
  features {}
}

# สร้างกลุ่มทรัพยากรสำหรับโปรเจกต์
resource "azurerm_resource_group" "project_rg" {
  name     = "my-project-resources"
  location = "East US" # คุณสามารถเปลี่ยนเป็น Southeast Asia ได้ถ้าต้องการ
}

# สร้างพื้นที่เก็บ Log สำหรับ Container Apps
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "project-log-workspace"
  location            = azurerm_resource_group.project_rg.location
  resource_group_name = azurerm_resource_group.project_rg.name
  sku                 = "PerGB2018"
}