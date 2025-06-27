terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  
  tags = {
    Environment = var.environment
    Project     = "Jasmin Catering AI Agent"
    ManagedBy   = "Terraform"
  }
}

# Logic App Workflow
resource "azurerm_logic_app_workflow" "email_processor" {
  name                = var.logic_app_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  
  tags = {
    Environment = var.environment
    Purpose     = "Email Processing"
  }
}

# Logic App Trigger (Recurrence)
resource "azurerm_logic_app_trigger_recurrence" "timer" {
  name         = "Every_5_minutes"
  logic_app_id = azurerm_logic_app_workflow.email_processor.id
  frequency    = "Minute"
  interval     = 5
}

# Logic App Action - HTTP Request to AI Service
resource "azurerm_logic_app_action_http" "ai_request" {
  name         = "Generate_AI_Response"
  logic_app_id = azurerm_logic_app_workflow.email_processor.id
  
  method = "POST"
  uri    = "${var.ai_services_endpoint}/openai/deployments/${var.ai_model_deployment}/chat/completions?api-version=${var.ai_api_version}"
  
  headers = {
    "api-key"      = var.ai_api_key
    "Content-Type" = "application/json"
  }
  
  body = jsonencode({
    messages = [
      {
        role    = "system"
        content = local.system_prompt
      },
      {
        role    = "user"
        content = "@{items('Process_Filtered_Emails')?['content']}"
      }
    ]
    temperature = var.ai_temperature
    max_tokens  = var.ai_max_tokens
  })
  
  run_after = {
    "Initialize_Email_Queue" = ["Succeeded"]
  }
}

# Local values for complex configurations
locals {
  system_prompt = <<-EOT
    Du bist ein professioneller Catering-Berater für Jasmin Catering, ein syrisches Fusion-Restaurant in Berlin.
    
    Deine Aufgabe ist es, auf Catering-Anfragen zu antworten und Angebote zu erstellen.
    
    Wichtige Informationen:
    - Preise: 35-45€ pro Person (abhängig von Menüauswahl und Gruppengröße)
    - Mindestbestellmenge: 15 Personen
    - Maximale Kapazität: 500 Personen
    - Spezialisierung: Syrische und mediterrane Fusion-Küche
    - Vegetarische und vegane Optionen verfügbar
    
    Antworte immer professionell, freundlich und auf Deutsch.
    Erstelle konkrete Angebote mit Preisangaben basierend auf der Anfrage.
  EOT
  
  simulated_emails = [
    {
      to      = var.webde_email_alias
      from    = "kunde1@example.com"
      subject = "Catering Anfrage - Firmenfeier"
      content = "Sehr geehrtes Jasmin Catering Team, wir planen eine Firmenfeier für 45 Personen am 15. Juli 2025. Wir interessieren uns für Ihr syrisches Catering-Angebot. Könnten Sie uns bitte ein Angebot zusenden? Mit freundlichen Grüßen"
    },
    {
      to      = var.webde_email_alias
      from    = "event@beispiel.de"
      subject = "Anfrage Hochzeit - 120 Gäste"
      content = "Hallo, wir heiraten im August und suchen ein Catering für 120 Personen. Uns gefällt Ihre syrisch-mediterrane Küche sehr gut. Bitte senden Sie uns ein Angebot mit vegetarischen Optionen."
    },
    {
      to      = "other@email.de"
      from    = "spam@test.com"
      subject = "Not relevant"
      content = "This should be filtered out"
    }
  ]
}

# Note: The complete Logic App workflow definition would be imported from the JSON file
# For a full implementation, we would use azurerm_resource_group_template_deployment
# or convert the entire workflow JSON to Terraform resources