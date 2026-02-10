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
# รอ DNS propagate ก่อน bind domain (Azure ต้องเจอ TXT record ก่อน)
resource "time_sleep" "wait_for_dns" {
  depends_on      = [cloudflare_record.domain_verification, cloudflare_record.backend_cname]
  create_duration = "180s" # รอ 3 นาทีให้ DNS propagate
}

resource "azurerm_container_app_custom_domain" "backend_domain" {
  name             = "passion-tree.org"
  container_app_id = azurerm_container_app.go_backend.id
  depends_on       = [time_sleep.wait_for_dns]

  # TLS Managed Certificate (uncomment หลัง custom domain สร้างสำเร็จครั้งแรก):
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