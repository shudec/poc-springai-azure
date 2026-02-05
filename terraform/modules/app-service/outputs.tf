output "app_service_name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.app.name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}
