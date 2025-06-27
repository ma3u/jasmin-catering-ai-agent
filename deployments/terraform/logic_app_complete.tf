# Complete Logic App deployment using ARM template
resource "azurerm_resource_group_template_deployment" "logic_app_complete" {
  name                = "${var.logic_app_name}-deployment"
  resource_group_name = azurerm_resource_group.main.name
  deployment_mode     = "Incremental"
  
  # Read the workflow definition and inject variables
  template_content = jsonencode({
    "$schema" = "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#"
    "contentVersion" = "1.0.0.0"
    "parameters" = {
      "workflows_name" = {
        "type" = "string"
      }
      "location" = {
        "type" = "string"
      }
      "apiKey" = {
        "type" = "securestring"
      }
      "emailAlias" = {
        "type" = "string"
      }
      "aiEndpoint" = {
        "type" = "string"
      }
    }
    "resources" = [
      {
        "type" = "Microsoft.Logic/workflows"
        "apiVersion" = "2019-05-01"
        "name" = "[parameters('workflows_name')]"
        "location" = "[parameters('location')]"
        "properties" = {
          "state" = "Enabled"
          "definition" = local.workflow_definition
        }
      }
    ]
  })
  
  parameters_content = jsonencode({
    "workflows_name" = {
      value = var.logic_app_name
    }
    "location" = {
      value = var.location
    }
    "apiKey" = {
      value = var.ai_api_key
    }
    "emailAlias" = {
      value = var.webde_email_alias
    }
    "aiEndpoint" = {
      value = var.ai_services_endpoint
    }
  })
  
  depends_on = [azurerm_resource_group.main]
}

# Workflow definition
locals {
  workflow_definition = {
    "$schema" = "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#"
    "contentVersion" = "1.0.0.0"
    "triggers" = {
      "Every_5_minutes" = {
        "type" = "Recurrence"
        "recurrence" = {
          "frequency" = "Minute"
          "interval" = var.email_check_interval
        }
      }
    }
    "actions" = {
      "Initialize_Email_Queue" = {
        "type" = "InitializeVariable"
        "inputs" = {
          "variables" = [
            {
              "name" = "emailQueue"
              "type" = "array"
              "value" = local.simulated_emails
            }
          ]
        }
      }
      "Filter_Target_Emails" = {
        "type" = "Query"
        "inputs" = {
          "from" = "@variables('emailQueue')"
          "where" = "@equals(item()['to'], '${var.webde_email_alias}')"
        }
        "runAfter" = {
          "Initialize_Email_Queue" = ["Succeeded"]
        }
      }
      "Process_Filtered_Emails" = {
        "type" = "Foreach"
        "foreach" = "@body('Filter_Target_Emails')"
        "actions" = {
          "Generate_AI_Response" = {
            "type" = "Http"
            "inputs" = {
              "method" = "POST"
              "uri" = "${var.ai_services_endpoint}/openai/deployments/${var.ai_model_deployment}/chat/completions?api-version=${var.ai_api_version}"
              "headers" = {
                "api-key" = "[parameters('apiKey')]"
                "Content-Type" = "application/json"
              }
              "body" = {
                "messages" = [
                  {
                    "role" = "system"
                    "content" = local.system_prompt
                  },
                  {
                    "role" = "user"
                    "content" = "@{items('Process_Filtered_Emails')?['content']}"
                  }
                ]
                "temperature" = var.ai_temperature
                "max_tokens" = var.ai_max_tokens
              }
            }
          }
          "Store_Email_Draft" = {
            "type" = "Compose"
            "inputs" = {
              "to" = "@{items('Process_Filtered_Emails')?['from']}"
              "subject" = "Re: @{items('Process_Filtered_Emails')?['subject']}"
              "body" = "@{body('Generate_AI_Response')?['choices'][0]['message']['content']}"
              "timestamp" = "@{utcNow()}"
            }
            "runAfter" = {
              "Generate_AI_Response" = ["Succeeded"]
            }
          }
        }
        "runAfter" = {
          "Filter_Target_Emails" = ["Succeeded"]
        }
      }
      "Create_Summary" = {
        "type" = "Compose"
        "inputs" = {
          "processed_count" = "@length(body('Filter_Target_Emails'))"
          "total_emails" = "@length(variables('emailQueue'))"
          "timestamp" = "@utcNow()"
        }
        "runAfter" = {
          "Process_Filtered_Emails" = ["Succeeded", "Failed", "Skipped"]
        }
      }
    }
  }
}