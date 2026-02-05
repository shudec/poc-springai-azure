resource "azurerm_service_plan" "plan" {
  name                = "plan-${var.environment}-springai"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "P1v2"

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
    CostCenter  = var.cost_center
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${var.environment}-springai-${substr(md5(var.resource_group_name), 0, 6)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.managed_identity_id]
  }

  site_config {
    always_on = true
    
    application_stack {
      java_server         = "JAVA"
      java_server_version = "17"
      java_version        = "17"
    }

    health_check_path = "/api/chat/health"
  }

  app_settings = {
    "AZURE_OPENAI_ENDPOINT"              = var.openai_endpoint
    "AZURE_OPENAI_DEPLOYMENT_NAME"       = var.openai_deployment_name
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "SPRING_PROFILES_ACTIVE"             = "prod"
    "RATE_LIMIT_RPM"                     = tostring(var.rate_limit_rpm)
    "WEBSITE_RUN_FROM_PACKAGE"           = "1"
  }

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}
