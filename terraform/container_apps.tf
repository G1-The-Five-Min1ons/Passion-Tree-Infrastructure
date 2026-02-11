# 1. Identity & Permissions
resource "azurerm_user_assigned_identity" "aca_identity" {
  name                = "passion-tree-aca-identity"
  resource_group_name = data.azurerm_resource_group.passion_tree.name 
  location            = var.aca_location 
}

data "azurerm_container_registry" "acr" {
  name                = "PassionTreeContainerRegistry"
  resource_group_name = data.azurerm_resource_group.passion_tree.name
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aca_identity.principal_id
}

# 2. Infrastructure Environment
resource "azurerm_container_app_environment" "aca_env" {
  name                       = "passion-tree-environment"
  location                   = var.aca_location
  resource_group_name        = data.azurerm_resource_group.passion_tree.name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.logs.id
  infrastructure_subnet_id   = azurerm_subnet.aca_subnet.id
}

# 3. Go Backend Service
resource "azurerm_container_app" "go_backend" {
  name                         = "backend-go"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.passion_tree.name
  revision_mode                = "Single"

  # บล็อก secret ต้องอยู่ตรงนี้ (ใต้ template แต่ออกมาจาก container)
    secret { 
      name = "db-password"
      value = var.db_password 
    }
    secret { 
      name = "mailersend-key"
      value = var.mailersend_api_key 
    }
    secret { 
      name = "smtp-user"
      value = var.smtp_username 
    }
    secret { 
      name = "smtp-pass"
      value = var.smtp_password 
    }
    secret { 
      name = "storage-conn"
      value = var.azure_storage_connection_string 
    }
    secret { 
      name = "storage-key"
      value = var.azure_storage_account_key 
    }

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

      # --- Database ---
      env { 
        name = "AZURESQL_SERVER" 
        value = var.db_server 
      }
      env { 
        name = "AZURESQL_DATABASE" 
        value = var.db_database 
      }
      env { 
        name = "AZURESQL_USER" 
        value = var.db_user 
      }
      env { 
        name = "AZURESQL_PORT" 
        value = var.db_port 
      }
      env { 
        name = "AZURESQL_PASSWORD"
        secret_name = "db-password" 
      }

      # --- SMTP / MailerSend ---
      env { 
        name = "SMTP_HOST"       
        value = var.smtp_host 
      }
      env { 
        name = "SMTP_PORT"       
        value = var.smtp_port 
      }
      env { 
        name = "SMTP_FROM_EMAIL"
        value = var.smtp_from_email 
        }
      env { 
        name = "MAILERSEND_API_KEY" 
        secret_name = "mailersend-key" 
      }
      env { 
        name = "SMTP_USERNAME"
        secret_name = "smtp-user" 
      }
      env { 
        name = "SMTP_PASSWORD"
        secret_name = "smtp-pass" 
      }

      # --- Azure Storage ---
      env { 
        name = "AZURE_STORAGE_ACCOUNT_NAME" 
        value = var.azure_storage_account_name 
      }
      env { 
        name = "CONTAINER_LEARNING_PATH"
        value = var.container_learning_path 
      }
      env { 
        name = "CONTAINER_PROFILE"           
        value = var.container_profile 
      }
      env { 
        name = "AZURE_STORAGE_CONNECTION_STRING" 
        secret_name = "storage-conn" 
        }
      env { 
        name = "AZURE_STORAGE_ACCOUNT_KEY" 
        secret_name = "storage-key" 
        }

      # --- App Config ---
      env { 
        name = "APP_ENV"
        value = "production" 
      }
      env { 
        name = "APP_URL"
        value = "https://passion-tree.org" 
      }

      env {
        name  = "AI_SERVICE_URL"
        value = "http://passion-tree-ai-service" 
      }
    } # --- END container ---

    min_replicas = 1
    max_replicas = 3
  } # --- END template ---

  ingress {
    external_enabled = true
    target_port      = 5000
    allow_insecure_connections = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}

# 4. FastAPI AI Service
resource "azurerm_container_app" "ai_service" {
  name                         = "passion-tree-ai-service"
  container_app_environment_id = azurerm_container_app_environment.aca_env.id
  resource_group_name          = data.azurerm_resource_group.passion_tree.name
  revision_mode                = "Single"

  # บล็อก secret สำหรับ AI Service
    secret { 
      name = "groq-key"
      value = var.groq_api_key 
    }
    secret { 
      name = "jina-key"
      value = var.jina_api_key 
    }
    secret { 
      name = "qdrant-key"
      value = var.qdrant_api_key 
    }

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

      env { 
        name = "QDRANT_URL"
        value = var.qdrant_url 
      }
      env { 
        name = "GROQ_API_KEY"   
        secret_name = "groq-key" 
      }
      env { 
        name = "JINA_API_KEY"
        secret_name = "jina-key" 
      }
      env { 
        name = "QDRANT_API_KEY"
        secret_name = "qdrant-key" 
      }

      env {
        name  = "AI_SERVICE_URL"
        value = "https://passion-tree-ai-service" 
      }

      env { 
        name  = "APP_URL"
        value = "https://passion-tree.org" 
      }

    } # --- END container ---

    min_replicas = 1
    max_replicas = 2
  } # --- END template ---

  ingress {
    external_enabled = false
    target_port      = 8000
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }
}