output "container_app_name" {
  description = "Name of the Container App"
  value       = azurerm_container_app.app.name
}

output "container_app_fqdn" {
  description = "FQDN of the Container App"
  value       = azurerm_container_app.app.ingress[0].fqdn
}

output "container_app_url" {
  description = "URL of the Container App"
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}"
}
