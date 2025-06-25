#!/bin/bash
set -euo pipefail

# Deploy Logic App with full prompt embedded (no Assistant API needed)
# This works with the current Azure OpenAI resource

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Configuration
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"

echo "🚀 Deploying Logic App with Embedded Prompt"
echo "==========================================="
echo ""
echo "📍 Configuration:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Model: gpt-4o (Chat Completions API)"
echo ""

# Read the prompt file
PROMPT_FILE="$(dirname "$0")/../documents/jasmin_catering_prompt.md"
if [ ! -f "$PROMPT_FILE" ]; then
    echo "❌ Error: Prompt file not found: $PROMPT_FILE"
    exit 1
fi

# Read prompt content and escape for JSON
echo "📖 Reading prompt from jasmin_catering_prompt.md..."
PROMPT_CONTENT=$(cat "$PROMPT_FILE" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g')

# Create workflow with embedded prompt
echo "🔧 Creating workflow with embedded prompt..."
TEMP_WORKFLOW="/tmp/workflow-prompt-$(date +%s).json"

cat > "$TEMP_WORKFLOW" << EOF
{
  "definition": {
    "\$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "apiKey": {
        "type": "securestring",
        "defaultValue": "@{parameters('apiKey')}"
      }
    },
    "triggers": {
      "Recurrence": {
        "type": "Recurrence",
        "recurrence": {
          "frequency": "Minute",
          "interval": 5
        }
      }
    },
    "actions": {
      "Initialize_Email_Queue": {
        "type": "InitializeVariable",
        "inputs": {
          "variables": [{
            "name": "EmailQueue",
            "type": "array",
            "value": [
              {
                "id": "@{concat('email-', utcNow('yyyyMMddHHmmss'), '-001')}",
                "from": "kunde@example.com",
                "to": "ma3u-test@email.de",
                "subject": "Catering Anfrage für Firmenevent",
                "body": "Guten Tag,\\n\\nwir planen ein Event für 50 Personen am 15. August 2025 in Berlin.\\nBitte um ein Angebot für syrisches Catering.\\n\\nMit freundlichen Grüßen",
                "receivedTime": "@{utcNow()}"
              },
              {
                "id": "@{concat('email-', utcNow('yyyyMMddHHmmss'), '-002')}",
                "from": "other@example.com",
                "to": "info@example.com",
                "subject": "Andere Email",
                "body": "Diese Email sollte ignoriert werden.",
                "receivedTime": "@{utcNow()}"
              }
            ]
          }]
        },
        "runAfter": {}
      },
      "Filter_Target_Emails": {
        "type": "Query",
        "inputs": {
          "from": "@variables('EmailQueue')",
          "where": "@equals(item()['to'], 'ma3u-test@email.de')"
        },
        "runAfter": {
          "Initialize_Email_Queue": ["Succeeded"]
        }
      },
      "Process_Filtered_Emails": {
        "type": "Foreach",
        "foreach": "@body('Filter_Target_Emails')",
        "actions": {
          "Generate_AI_Response": {
            "type": "Http",
            "inputs": {
              "method": "POST",
              "uri": "https://jasmin-catering-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01",
              "headers": {
                "Content-Type": "application/json",
                "api-key": "@parameters('apiKey')"
              },
              "body": {
                "messages": [
                  {
                    "role": "system",
                    "content": "${PROMPT_CONTENT}"
                  },
                  {
                    "role": "user",
                    "content": "Erstelle ein Angebot für:\\n\\nVon: @{items('Process_Filtered_Emails')['from']}\\nBetreff: @{items('Process_Filtered_Emails')['subject']}\\n\\nAnfrage:\\n@{items('Process_Filtered_Emails')['body']}"
                  }
                ],
                "temperature": 0.3,
                "max_tokens": 2500
              }
            }
          },
          "Store_Email_Draft": {
            "type": "Compose",
            "inputs": {
              "emailId": "@{items('Process_Filtered_Emails')['id']}",
              "originalEmail": "@items('Process_Filtered_Emails')",
              "draftResponse": "@{body('Generate_AI_Response')?['choices'][0]['message']['content']}",
              "processedAt": "@{utcNow()}",
              "status": "draft_created"
            },
            "runAfter": {
              "Generate_AI_Response": ["Succeeded"]
            }
          }
        },
        "runAfter": {
          "Filter_Target_Emails": ["Succeeded"]
        }
      },
      "Create_Summary": {
        "type": "Compose",
        "inputs": {
          "processed_count": "@length(body('Filter_Target_Emails'))",
          "total_emails": "@length(variables('EmailQueue'))",
          "timestamp": "@utcNow()"
        },
        "runAfter": {
          "Process_Filtered_Emails": ["Succeeded", "Failed", "Skipped"]
        }
      }
    },
    "outputs": {}
  }
}
EOF

# Replace API key
sed -i.bak "s/@{parameters('apiKey')}/$AZURE_AI_API_KEY/g" "$TEMP_WORKFLOW"

# Update the Logic App
echo ""
echo "🔄 Updating Logic App..."
az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition "@$TEMP_WORKFLOW" \
    --output none

# Clean up
rm -f "$TEMP_WORKFLOW" "$TEMP_WORKFLOW.bak"

# Check status
STATE=$(az logic workflow show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --query state --output tsv)

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📋 Summary:"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- State: $STATE"
echo "- Using: Chat Completions API with embedded prompt"
echo "- Model: gpt-4o"
echo ""
echo "🔍 The Logic App now includes:"
echo "- Full Jasmin Catering prompt (10KB+)"
echo "- 3-package offer generation"
echo "- German language responses"
echo "- Menu items and pricing logic"
echo ""
echo "📊 Monitor with: ./monitor-logic-app.sh"
echo ""
echo "✨ Done! The Logic App is using the full prompt directly."