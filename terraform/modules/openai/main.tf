resource "azurerm_cognitive_account" "openai" {
  name                = "openai-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = "S0"

  tags = {
    Environment = var.environment
    Project     = "SpringAI-Demo"
  }
}

resource "azurerm_cognitive_deployment" "gpt4o_mini" {
  name                 = var.deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4o-mini"
    version = "2024-07-18"
  }

  scale {
    type = "GlobalStandard"
  }
}

# Grant Cognitive Services OpenAI User role to managed identity
resource "azurerm_role_assignment" "openai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = var.managed_identity_principal_id
}
