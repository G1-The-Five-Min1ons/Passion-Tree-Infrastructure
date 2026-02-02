# สร้างสภาพแวดล้อมสำหรับรัน Container ภายใน VNet
resource "azurerm_container_app_environment" "aca_env" {
  name                           = "passion-tree-environment"
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
      image  = var.backend_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "PORT"
        value = "8080"
      }
      env {
        name  = "DB_URL"
        value = var.backend_db_url
      }
      env {
        name  = "AI_SERVICE_URL"
        value = var.ai_service_url
      }

      readiness_probe {
        transport                 = "HTTP"
        port                      = 8080
        path                      = "/health"
        interval_seconds          = 10
        timeout                   = 2
        success_count_threshold   = 1
        failure_count_threshold   = 3
      }

      liveness_probe {
        transport           = "HTTP"
        port                = 8080
        path                = "/health"
        initial_delay       = 5
        interval_seconds    = 10
        timeout             = 2
        failure_count_threshold = 3
      }
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

  # ดึงอิมเมจจาก ACR ตามแผนใน Diagram ผ่าน Application Gateway
  registry {
    server                = var.acr_server
    username              = var.acr_username
    password_secret_name  = "acr_password"
  }

  secret {
    name  = "acr_password"
    value = var.acr_password
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
      image  = var.ai_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "PORT"
        value = "8000"
      }
      env {
        name  = "REDIS_URL"
        value = var.redis_url
      }
      env {
        name        = "GROQ_API_KEY"
        secret_name = "groq_api_key"
      }
      env {
        name  = "DB_URL"
        value = var.backend_db_url
      }

      readiness_probe {
        transport                 = "HTTP"
        port                      = 8000
        path                      = "/health"
        interval_seconds          = 10
        timeout                   = 2
        success_count_threshold   = 1
        failure_count_threshold   = 3
      }

      liveness_probe {
        transport           = "HTTP"
        port                = 8000
        path                = "/health"
        initial_delay       = 5
        interval_seconds    = 10
        timeout             = 2
        failure_count_threshold = 3
      }
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

  registry {
    server                = var.acr_server
    username              = var.acr_username
    password_secret_name  = "acr_password"
  }

  secret {
    name  = "acr_password"
    value = var.acr_password
  }

  secret {
    name  = "groq_api_key"
    value = var.groq_api_key
  }
}