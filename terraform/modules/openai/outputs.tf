output "endpoint" {
  description = "Azure OpenAI endpoint"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "id" {
  description = "Azure OpenAI resource ID"
  value       = azurerm_cognitive_account.openai.id
}

output "deployment_name" {
  description = "Name of the GPT-4o-mini deployment"
  value       = azurerm_cognitive_deployment.gpt4o_mini.name
}

output "api_key" {
  description = "Primary API key for Azure OpenAI (use for dev only)"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}
