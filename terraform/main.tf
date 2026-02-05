data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.environment}-springai"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
    CostCenter  = var.cost_center
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

# Shared resources module (ACR, Log Analytics, App Insights, Managed Identity)
module "shared" {
  source = "./modules/shared"

  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  environment         = var.environment
}

# OpenAI module
module "openai" {
  source = "./modules/openai"

  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  environment                   = var.environment
  managed_identity_principal_id = module.shared.managed_identity_principal_id

  depends_on = [module.shared]
}

# App Service module (conditional)
module "app_service" {
  source = "./modules/app-service"
  count  = var.deployment_type == "appservice" || var.deployment_type == "both" ? 1 : 0

  resource_group_name           = azurerm_resource_group.rg.name
  location                      = var.location
  environment                   = var.environment
  managed_identity_id           = module.shared.managed_identity_id
  openai_endpoint               = module.openai.endpoint
  openai_deployment_name        = module.openai.deployment_name
  app_insights_connection_string = module.shared.app_insights_connection_string
  rate_limit_rpm                = var.rate_limit_rpm
  cost_center                   = var.cost_center
  owner                         = var.owner

  depends_on = [module.shared, module.openai]
}

# Container Apps module (conditional)
module "container_apps" {
  source = "./modules/container-apps"
  count  = var.deployment_type == "containerapp" || var.deployment_type == "both" ? 1 : 0

  resource_group_name            = azurerm_resource_group.rg.name
  location                       = var.location
  environment                    = var.environment
  managed_identity_id            = module.shared.managed_identity_id
  acr_login_server               = module.shared.acr_login_server
  log_analytics_workspace_id     = module.shared.log_analytics_workspace_id
  openai_endpoint                = module.openai.endpoint
  openai_deployment_name         = module.openai.deployment_name
  app_insights_connection_string = module.shared.app_insights_connection_string
  rate_limit_rpm                 = var.rate_limit_rpm

  depends_on = [module.shared, module.openai]
}
