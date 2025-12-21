# สร้างสภาพแวดล้อมสำหรับรัน Container ภายใน VNet
resource "azurerm_container_app_environment" "aca_env" {
  name                           = "project-environment"
  location                       = azurerm_resource_group.project_rg.location
  resource_group_name            = azurerm_resource_group.project_rg.name
  log_analytics_workspace_id      = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id       = azurerm_subnet.aca_subnet.id # เชื่อมเข้า VNet
}

# 1. Go Backend (External Ingress - ประตูหน้าบ้าน)
resource "azurerm_container_app" "go_backend" {
  name                         = "backend-go"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.project_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "go-app"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest" # ใส่ Image จริงของคุณทีหลัง
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = true # เปิดให้คนทั่วไปเข้าถึงได้
    target_port      = 8080
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# 2. FastAPI AI Service (Internal Ingress - เฉพาะภายใน VNet)
resource "azurerm_container_app" "ai_service" {
  name                         = "ai-fastapi"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.project_rg.name
  revision_mode                = "Single"

  template {
    container {
      name   = "fastapi-app"
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  ingress {
    external_enabled = false # บล็อกคนภายนอก เข้าถึงได้เฉพาะ Go ภายใน VNet
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}