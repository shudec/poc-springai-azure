variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "westeurope"
}

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "rate_limit_rpm" {
  description = "Rate limit requests per minute"
  type        = number
  default     = 10
  
  validation {
    condition     = var.rate_limit_rpm > 0 && var.rate_limit_rpm <= 1000
    error_message = "Rate limit must be between 1 and 1000 requests per minute."
  }
}

variable "deployment_type" {
  description = "Deployment type: appservice, containerapp, or both"
  type        = string
  default     = "containerapp"
  
  validation {
    condition     = contains(["appservice", "containerapp", "both"], var.deployment_type)
    error_message = "Deployment type must be 'appservice', 'containerapp', or 'both'."
  }
}

variable "cost_center" {
  description = "Cost center for billing (DEP policy requirement)"
  type        = string
  default     = "CCOE"
}

variable "owner" {
  description = "Resource owner email (DEP policy requirement)"
  type        = string
  default     = "stephane.hudec@soprasteria.com"
}
