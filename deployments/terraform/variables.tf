variable "azure_subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "logicapp-jasmin-sweden_group"
}

variable "location" {
  description = "Azure region for resources (Sweden Central due to West Europe restrictions)"
  type        = string
  default     = "swedencentral"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"
}

# Logic App Configuration
variable "logic_app_name" {
  description = "Name of the Logic App Workflow"
  type        = string
  default     = "jasmin-order-processor-sweden"
}

# AI Services Configuration
variable "ai_services_endpoint" {
  description = "Azure Cognitive Services endpoint URL"
  type        = string
  default     = "https://jasmin-catering-resource.cognitiveservices.azure.com"
}

variable "ai_api_key" {
  description = "API Key for Azure Cognitive Services"
  type        = string
  sensitive   = true
}

variable "ai_model_deployment" {
  description = "AI model deployment name"
  type        = string
  default     = "gpt-4o"
}

variable "ai_api_version" {
  description = "Azure OpenAI API version"
  type        = string
  default     = "2024-02-01"
}

variable "ai_temperature" {
  description = "Temperature setting for AI responses (0-1, lower = more consistent)"
  type        = number
  default     = 0.3
}

variable "ai_max_tokens" {
  description = "Maximum tokens for AI response"
  type        = number
  default     = 1500
}

# Email Configuration
variable "webde_email_alias" {
  description = "Email alias for filtering incoming messages"
  type        = string
  default     = "ma3u-test@email.de"
}

variable "webde_app_password" {
  description = "App password for Web.de email service"
  type        = string
  sensitive   = true
}

# Business Configuration
variable "business_name" {
  description = "Name of the catering business"
  type        = string
  default     = "Jasmin Catering"
}

variable "business_location" {
  description = "Location of the business"
  type        = string
  default     = "Berlin, Germany"
}

variable "min_guests" {
  description = "Minimum number of guests for catering"
  type        = number
  default     = 15
}

variable "max_guests" {
  description = "Maximum number of guests for catering"
  type        = number
  default     = 500
}

variable "price_per_person_min" {
  description = "Minimum price per person in EUR"
  type        = number
  default     = 35
}

variable "price_per_person_max" {
  description = "Maximum price per person in EUR"
  type        = number
  default     = 45
}

# Monitoring Configuration
variable "email_check_interval" {
  description = "Interval in minutes between email checks"
  type        = number
  default     = 5
}

variable "email_retention_days" {
  description = "Number of days to retain processed emails"
  type        = number
  default     = 30
}