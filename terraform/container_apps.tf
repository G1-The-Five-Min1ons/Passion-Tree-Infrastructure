# สร้าง Identity ประจำตัวให้แอป (เพื่อให้แอปไปหยิบ Image จาก ACR ได้โดยไม่ต้องใช้รหัสผ่าน)
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "passion-tree-aca-identity"
  resource_group_name = data.azurerm_resource_group.passion_tree.name 
  location            = data.azurerm_resource_group.passion_tree.location 
}

# มอบสิทธิ์ (Role Assignment)
resource "azurerm_role_assignment" "acr_pull" {
  scope                = "/subscriptions/37a4a9ac-d61a-48ce-a165-92e989e945f3/resourceGroups/Passion-Tree/providers/Microsoft.ContainerRegistry/registries/PassionTreeContainerRegistry"
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# สภาพแวดล้อมสำหรับรัน Container (VNet-Injected)
resource "azurerm_container_app_environment" "aca_env" {
  name                       = "passion-tree-environment"
  location                   = azurerm_resource_group.passion_tree.location
  resource_group_name        = azurerm_resource_group.passion_tree.name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id   = azurerm_subnet.aca_subnet.id
}

# Go Backend (External Ingress)
resource "azurerm_container_app" "go_backend" {
  name                         = "backend-go"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.passion_tree.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = var.acr_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  template {
    container {
      name   = "go-app"
      image  = var.backend_image
      cpu    = 0.5
      memory = "1Gi"

      env { name = "PORT"; value = "5000" }
      env { name = "DB_URL"; value = var.backend_db_url }
      env { name = "AI_SERVICE_URL"; value = "http://passion-tree-ai-service" } # คุยภายในผ่านชื่อแอป

      readiness_probe {
        transport = "HTTP"
        port      = 5000
        path      = "/health"
      }
    }
    # ตั้งค่าการขยายตัว (Scaling)
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port      = 5000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}

# ผูกโดเมน the-passiontree.org เข้ากับ Backend
resource "azurerm_container_app_custom_domain" "backend_domain" {
  name             = "the-passiontree.org"
  container_app_id = azurerm_container_app.go_backend.id
}

# FastAPI AI Service (Internal Ingress)
resource "azurerm_container_app" "ai_service" {
  name                         = "passion-tree-ai-service"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = azurerm_resource_group.passion_tree.name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aca_identity.id]
  }

  registry {
    server   = var.acr_server
    identity = azurerm_user_assigned_identity.aca_identity.id
  }

  secret {
    name  = "groq-api-key"
    value = var.groq_api_key
  }

  template {
    container {
      name   = "fastapi-app"
      image  = var.ai_image
      cpu    = 0.5
      memory = "1Gi"

      env { name = "PORT"; value = "8000" }
      env { name = "REDIS_URL"; value = var.redis_url }
      env { name = "GROQ_API_KEY"; secret_name = "groq_api_key" }

      readiness_probe {
        transport = "HTTP"
        port      = 8000
        path      = "/health"
      }
    }
    min_replicas = 1
    max_replicas = 2
  }

  ingress {
    external_enabled = false # ปิดตายคนนอก เข้าได้เฉพาะ Go Backend
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
}