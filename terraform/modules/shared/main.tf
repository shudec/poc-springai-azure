resource "azurerm_container_registry" "acr" {
  name                = "acr${var.environment}springai${substr(md5(var.resource_group_name), 0, 6)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}

resource "azurerm_log_analytics_workspace" "workspace" {
  name                = "logs-${var.environment}-springai"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}

resource "azurerm_application_insights" "app_insights" {
  name                = "appi-${var.environment}-springai"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.workspace.id
  application_type    = "java"

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}

resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "id-${var.environment}-springai"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}

# Grant AcrPull role to managed identity
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}

# Grant Monitoring Metrics Publisher role to managed identity
resource "azurerm_role_assignment" "monitoring_publisher" {
  scope                = azurerm_application_insights.app_insights.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_user_assigned_identity.app_identity.principal_id
}
