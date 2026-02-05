output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password for ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}

output "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "managed_identity_id" {
  description = "Managed identity resource ID"
  value       = azurerm_user_assigned_identity.app_identity.id
}

output "managed_identity_principal_id" {
  description = "Managed identity principal ID"
  value       = azurerm_user_assigned_identity.app_identity.principal_id
}

output "managed_identity_client_id" {
  description = "Managed identity client ID"
  value       = azurerm_user_assigned_identity.app_identity.client_id
}
