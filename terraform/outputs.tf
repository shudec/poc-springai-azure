output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = module.openai.endpoint
}

output "openai_deployment_name" {
  description = "Azure OpenAI deployment name"
  value       = module.openai.deployment_name
}

output "openai_api_key" {
  description = "Azure OpenAI API key (for dev use only)"
  value       = module.openai.api_key
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.shared.acr_login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = module.shared.acr_admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = module.shared.acr_admin_password
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.shared.app_insights_connection_string
  sensitive   = true
}

output "app_service_url" {
  description = "App Service URL"
  value       = var.deployment_type == "appservice" || var.deployment_type == "both" ? module.app_service[0].app_service_url : null
}

output "container_app_url" {
  description = "Container App URL"
  value       = var.deployment_type == "containerapp" || var.deployment_type == "both" ? module.container_apps[0].container_app_url : null
}

output "app_service_name" {
  description = "App Service name"
  value       = var.deployment_type == "appservice" || var.deployment_type == "both" ? module.app_service[0].app_service_name : null
}

output "container_app_name" {
  description = "Container App name"
  value       = var.deployment_type == "containerapp" || var.deployment_type == "both" ? module.container_apps[0].container_app_name : null
}

# GitHub Secrets output for easy CI/CD setup
output "github_secrets" {
  description = "GitHub Secrets configuration (use script to set these)"
  value = {
    AZURE_OPENAI_ENDPOINT        = module.openai.endpoint
    AZURE_OPENAI_API_KEY         = module.openai.api_key
    AZURE_OPENAI_DEPLOYMENT_NAME = module.openai.deployment_name
    ACR_LOGIN_SERVER             = module.shared.acr_login_server
    ACR_USERNAME                 = module.shared.acr_admin_username
    ACR_PASSWORD                 = module.shared.acr_admin_password
    APP_SERVICE_NAME             = var.deployment_type == "appservice" || var.deployment_type == "both" ? module.app_service[0].app_service_name : ""
    CONTAINER_APP_NAME           = var.deployment_type == "containerapp" || var.deployment_type == "both" ? module.container_apps[0].container_app_name : ""
    RESOURCE_GROUP_NAME          = azurerm_resource_group.rg.name
  }
  sensitive = true
}
