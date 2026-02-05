variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "managed_identity_id" {
  description = "Managed identity resource ID"
  type        = string
}

variable "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  type        = string
}

variable "openai_deployment_name" {
  description = "Azure OpenAI deployment name"
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
}

variable "rate_limit_rpm" {
  description = "Rate limit requests per minute"
  type        = number
  default     = 10
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "CCOE"
}

variable "owner" {
  description = "Resource owner email"
  type        = string
  default     = "team@example.com"
}
