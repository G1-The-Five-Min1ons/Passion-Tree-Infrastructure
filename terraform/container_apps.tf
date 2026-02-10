# สร้าง Identity ประจำตัวให้แอป (เพื่อให้แอปไปหยิบ Image จาก ACR ได้โดยไม่ต้องใช้รหัสผ่าน)
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "passion-tree-aca-identity"
  resource_group_name = data.azurerm_resource_group.passion_tree.name 
  location            = var.aca_location 
}

# ดึงข้อมูล ACR ที่มีอยู่แล้ว (แทนการ hardcode subscription ID)
data "azurerm_container_registry" "acr" {
  name                = "PassionTreeContainerRegistry"
  resource_group_name = data.azurerm_resource_group.passion_tree.name
}

# มอบสิทธิ์ (Role Assignment)
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# สภาพแวดล้อมสำหรับรัน Container (VNet-Injected)
resource "azurerm_container_app_environment" "aca_env" {
  name                       = "passion-tree-environment"
  location                   = var.aca_location
  resource_group_name        = data.azurerm_resource_group.passion_tree.name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id   = azurerm_subnet.aca_subnet.id
}

# Go Backend (External Ingress)
resource "azurerm_container_app" "go_backend" {
  name                         = "backend-go"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.passion_tree.name
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

      # env vars จัดการโดย CI/CD ของ Backend repo
      env {
        name  = "DB_HOST"
        value = var.db_server
      }
      env {
        name  = "DB_NAME"
        value = var.db_database
      }
      env {
        name  = "DB_USER"
        value = var.db_user
      }
      env {
        name  = "DB_PASSWORD"
        value = var.db_password
      }
      env {
        name  = "DB_PORT"
        value = var.db_port
      }
      # SMTP / MailerSend
      env {
        name  = "MAILERSEND_API_KEY"
        value = var.mailersend_api_key
      }
      env {
        name  = "SMTP_HOST"
        value = var.smtp_host
      }
      env {
        name  = "SMTP_PORT"
        value = var.smtp_port
      }
      env {
        name  = "SMTP_USERNAME"
        value = var.smtp_username
      }
      env {
        name  = "SMTP_PASSWORD"
        value = var.smtp_password
      }
      env {
        name  = "SMTP_FROM_EMAIL"
        value = var.smtp_from_email
      }
      # Azure Storage
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = var.azure_storage_account_name
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_KEY"
        value = var.azure_storage_account_key
      }
      env {
        name  = "AZURE_STORAGE_CONNECTION_STRING"
        value = var.azure_storage_connection_string
      }
      env {
        name  = "CONTAINER_LEARNING_PATH"
        value = var.container_learning_path
      }
      env {
        name  = "CONTAINER_PROFILE"
        value = var.container_profile
      }
      # Service Config
      env {
        name = "APP_ENV"
        value = "production"
      }
      env {
         name = "APP_URL"
         value = "https://passion-tree.org"
      }
      # SMTP / MailerSend
      env {
        name  = "MAILERSEND_API_KEY"
        value = var.mailersend_api_key
      }
      env {
        name  = "SMTP_HOST"
        value = var.smtp_host
      }
      env {
        name  = "SMTP_PORT"
        value = var.smtp_port
      }
      env {
        name  = "SMTP_USERNAME"
        value = var.smtp_username
      }
      env {
        name  = "SMTP_PASSWORD"
        value = var.smtp_password
      }
      env {
        name  = "SMTP_FROM_EMAIL"
        value = var.smtp_from_email
      }
      # Azure Storage
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = var.azure_storage_account_name
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_KEY"
        value = var.azure_storage_account_key
      }
      env {
        name  = "AZURE_STORAGE_CONNECTION_STRING"
        value = var.azure_storage_connection_string
      }
      env {
        name  = "CONTAINER_LEARNING_PATH"
        value = var.container_learning_path
      }
      env {
        name  = "CONTAINER_PROFILE"
        value = var.container_profile
      }
      # Service Config
      env {
        name = "APP_ENV"
        value = "production"
      }
      env {
         name = "APP_URL"
         value = "https://passion-tree.org"
      }
      # SMTP / MailerSend
      env {
        name  = "MAILERSEND_API_KEY"
        value = var.mailersend_api_key
      }
      env {
        name  = "SMTP_HOST"
        value = var.smtp_host
      }
      env {
        name  = "SMTP_PORT"
        value = var.smtp_port
      }
      env {
        name  = "SMTP_USERNAME"
        value = var.smtp_username
      }
      env {
        name  = "SMTP_PASSWORD"
        value = var.smtp_password
      }
      env {
        name  = "SMTP_FROM_EMAIL"
        value = var.smtp_from_email
      }
      # Azure Storage
      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = var.azure_storage_account_name
      }
      env {
        name  = "AZURE_STORAGE_ACCOUNT_KEY"
        value = var.azure_storage_account_key
      }
      env {
        name  = "AZURE_STORAGE_CONNECTION_STRING"
        value = var.azure_storage_connection_string
      }
      env {
        name  = "CONTAINER_LEARNING_PATH"
        value = var.container_learning_path
      }
      env {
        name  = "CONTAINER_PROFILE"
        value = var.container_profile
      }
      # Service Config
      env {
        name = "APP_ENV"
        value = "production"
      }
      env {
         name = "APP_URL"
         value = "https://passion-tree.org"
      }


      readiness_probe {
        transport = "HTTP"
        port      = 5000
        path      = "/api/v1/health"
      }
    }
    # ตั้งค่าการขยายตัว (Scaling)
    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled = true
    target_port      = 5000
    allow_insecure_connections = true  # Cloudflare Flexible SSL → HTTP to origin
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  # ป้องกัน Terraform revert image ที่ CI/CD deploy ไปแล้ว
  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}

# ─── Custom Domain ───
# จัดการ custom domain ผ่าน CLI แทน Terraform
# เนื่องจาก Cloudflare proxy + Azure domain verification ชนกัน
# หลัง terraform apply สำเร็จ → ใช้ az containerapp hostname add / bind

# resource "time_sleep" "wait_for_dns" {
#   depends_on      = [cloudflare_record.domain_verification, cloudflare_record.backend_cname]
#   create_duration = "180s"
# }

# resource "azurerm_container_app_custom_domain" "backend_domain" {
#   name             = "passion-tree.org"
#   container_app_id = azurerm_container_app.go_backend.id
#   depends_on       = [time_sleep.wait_for_dns]
# }

# FastAPI AI Service (Internal Ingress)
resource "azurerm_container_app" "ai_service" {
  name                         = "passion-tree-ai-service"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.passion_tree.name
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
      name   = "fastapi-app"
      image  = var.ai_image
      cpu    = 0.5
      memory = "1Gi"

      # env vars & secrets จัดการโดย CI/CD ของ AI repo
      env {
        name  = "GROQ_API_KEY"
        value = var.groq_api_key
      }
      env {
        name  = "JINA_API_KEY"
        value = var.jina_api_key
      }
      env {
        name  = "HF_TOKEN"
        value = var.hf_token
      }
      env {
        name  = "QDRANT_URL"
        value = var.qdrant_url
      }
      env {
        name  = "QDRANT_API_KEY"
        value = var.qdrant_api_key
      }

      env {
        name  = "GROQ_API_KEY"
        value = var.groq_api_key
      }
      env {
        name  = "JINA_API_KEY"
        value = var.jina_api_key
      }
      env {
        name  = "HF_TOKEN"
        value = var.hf_token
      }
      env {
        name  = "QDRANT_URL"
        value = var.qdrant_url
      }
      env {
        name  = "QDRANT_API_KEY"
        value = var.qdrant_api_key
      }

      readiness_probe {
        transport = "HTTP"
        port      = 8000
        path      = "/api/v1/health"
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

  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}