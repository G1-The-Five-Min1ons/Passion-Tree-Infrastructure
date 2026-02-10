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

  # ป้องกัน Terraform revert image ที่ CI/CD deploy ไปแล้ว
  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}

# ผูกโดเมน passion-tree.org เข้ากับ Backend
# หมายเหตุ: ต้อง apply DNS records (CNAME + TXT) ก่อน แล้วค่อย uncomment certificate binding
resource "azurerm_container_app_custom_domain" "backend_domain" {
  name             = "passion-tree.org"
  container_app_id = azurerm_container_app.go_backend.id

  # ─── TLS Managed Certificate ───
  # ขั้นตอน:
  #   1. ครั้งแรก: terraform apply เพื่อสร้าง DNS records + custom domain (comment certificate ไว้ก่อน)
  #   2. รอ DNS propagate (~1-5 นาที)
  #   3. Uncomment 2 บรรทัดข้างล่าง แล้ว terraform apply อีกครั้ง
  #
  # container_app_environment_certificate_id = azurerm_container_app_environment_certificate.managed_cert.id
  # certificate_binding_type                 = "SniEnabled"
}

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

  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
    ]
  }
}