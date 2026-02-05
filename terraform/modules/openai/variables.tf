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

variable "deployment_name" {
  description = "Name of the OpenAI deployment"
  type        = string
  default     = "gpt-4o-mini"
}

variable "deployment_capacity" {
  description = "Capacity of the OpenAI deployment (TPM in thousands)"
  type        = number
  default     = 10
}

variable "managed_identity_principal_id" {
  description = "Principal ID of the managed identity to grant access"
  type        = string
}
