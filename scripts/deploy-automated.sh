#!/bin/bash

# Automated Gmail + HTTPS Slack Deployment with Google CLI Credentials
# This script uses credentials from the Google CLI setup

set -e

echo "🔧 Deploying Gmail + Slack with Google CLI Authentication..."
echo ""

# Check if Google credentials exist
GOOGLE_CREDS_FILE="config/google-oauth-credentials.json"

if [ ! -f "$GOOGLE_CREDS_FILE" ]; then
    echo "❌ Google OAuth credentials not found!"
    echo ""
    echo "🔧 Please run the Google CLI setup first:"
    echo "   ./scripts/setup-google-cli.sh"
    echo ""
    exit 1
fi

# Read credentials from JSON file
echo "📋 Reading Google OAuth credentials..."
GOOGLE_CLIENT_ID=$(cat $GOOGLE_CREDS_FILE | jq -r '.client_id')
GOOGLE_CLIENT_SECRET=$(cat $GOOGLE_CREDS_FILE | jq -r '.client_secret')
PROJECT_ID=$(cat $GOOGLE_CREDS_FILE | jq -r '.project_id')

if [ "$GOOGLE_CLIENT_ID" = "null" ] || [ "$GOOGLE_CLIENT_SECRET" = "null" ]; then
    echo "❌ Invalid credentials in $GOOGLE_CREDS_FILE"
    echo "🔧 Please run setup-google-cli.sh again"
    exit 1
fi

echo "✅ Google OAuth Credentials:"
echo "   Project: $PROJECT_ID"
echo "   Client ID: ${GOOGLE_CLIENT_ID:0:20}..."
echo "   Client Secret: ${GOOGLE_CLIENT_SECRET:0:10}..."
echo ""

# Azure configuration
RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"
SLACK_WEBHOOK="https://hooks.slack.com/services/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"

echo "📧 Email: mabu.mate@gmail.com"
echo "💬 Slack: #gmail-inbox"
echo ""

echo "🔧 Creating Gmail connection with custom authentication..."

# Create Gmail connection with custom auth
az resource create \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Web/connections" \
  --name gmail-custom-auth \
  --location westeurope \
  --properties '{
    "displayName": "Gmail - Custom Auth - mabu.mate@gmail.com",
    "customParameterValues": {},
    "api": {
      "id": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/providers/Microsoft.Web/locations/westeurope/managedApis/gmail"
    }
  }' || echo "⚠️  Gmail connection might already exist"

echo "📝 Creating workflow definition..."

# Create the workflow with custom authentication
cat > logicapp/gmail-automated-workflow.json << EOF
{
  "\$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "\$connections": {
      "defaultValue": {
        "gmail": {
          "connectionId": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/gmail-custom-auth",
          "connectionName": "gmail-custom-auth",
          "id": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/providers/Microsoft.Web/locations/westeurope/managedApis/gmail"
        }
      },
      "type": "Object"
    }
  },
  "triggers": {
    "When_a_new_email_arrives_(V3)": {
      "recurrence": {
        "frequency": "Minute",
        "interval": 1
      },
      "evaluatedRecurrence": {
        "frequency": "Minute",
        "interval": 1
      },
      "type": "ApiConnection",
      "inputs": {
        "host": {
          "connection": {
            "name": "@parameters('\$connections')['gmail']['connectionId']"
          }
        },
        "method": "get",
        "path": "/v3/Mail/OnNewEmail",
        "queries": {
          "emailAddress": "mabu.mate@gmail.com",
          "fetchOnlyWithAttachments": false,
          "includeAttachments": false,
          "subjectFilter": "All"
        }
      },
      "splitOn": "@triggerBody()?['value']"
    }
  },
  "actions": {
    "Parse_Email_Content": {
      "runAfter": {},
      "type": "Compose",
      "inputs": {
        "emailId": "@triggerBody()?['id']",
        "subject": "@triggerBody()?['subject']",
        "from": "@triggerBody()?['from']", 
        "body": "@triggerBody()?['body']",
        "receivedDateTime": "@triggerBody()?['receivedDateTime']",
        "bodyPreview": "@triggerBody()?['bodyPreview']"
      }
    },
    "Format_Slack_Message": {
      "runAfter": {
        "Parse_Email_Content": ["Succeeded"]
      },
      "type": "Compose",
      "inputs": {
        "text": "📧 New Email for Jasmin Catering",
        "blocks": [
          {
            "type": "header",
            "text": {
              "type": "plain_text",
              "text": "📧 New Email for Jasmin Catering"
            }
          },
          {
            "type": "section",
            "fields": [
              {
                "type": "mrkdwn",
                "text": "*From:* @{triggerBody()?['from']}"
              },
              {
                "type": "mrkdwn",
                "text": "*Subject:* @{triggerBody()?['subject']}"
              },
              {
                "type": "mrkdwn",
                "text": "*Received:* @{triggerBody()?['receivedDateTime']}"
              },
              {
                "type": "mrkdwn",
                "text": "*Email ID:* @{triggerBody()?['id']}"
              }
            ]
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "*Preview:*\\n@{triggerBody()?['bodyPreview']}"
            }
          },
          {
            "type": "divider"
          },
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "🤖 *Next Steps:* This email will be processed by the Jasmin Catering AI Agent for automatic quote generation."
            }
          }
        ]
      }
    },
    "Send_to_Slack_via_HTTPS": {
      "runAfter": {
        "Format_Slack_Message": ["Succeeded"]
      },
      "type": "Http",
      "inputs": {
        "method": "POST",
        "uri": "$SLACK_WEBHOOK",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": "@outputs('Format_Slack_Message')"
      }
    }
  },
  "outputs": {}
}
EOF

echo "🚀 Deploying workflow to Azure..."

# Deploy the workflow
az resource update \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Logic/workflows" \
  --name $LOGIC_APP_NAME \
  --set properties.definition="$(cat logicapp/gmail-automated-workflow.json)"

echo ""
echo "✅ Workflow deployed successfully!"
echo ""
echo "📋 Final configuration steps:"
echo ""
echo "1. 🔧 Configure Gmail authentication in Azure Portal:"
echo "   https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "2. 🔑 Set authentication in Gmail trigger:"
echo "   - Authentication Type: 'Bring your own application'"
echo "   - Client ID: $GOOGLE_CLIENT_ID"
echo "   - Client Secret: $GOOGLE_CLIENT_SECRET"
echo ""
echo "3. 🧪 Test with email to mabu.mate@gmail.com"
echo ""
echo "📊 Expected result:"
echo "   📧 Email → LogicApp → HTTPS → Slack #gmail-inbox ✅"
echo ""
echo "🎯 This setup has NO restrictions and is fully Microsoft-compliant!"

# Backup credentials securely
echo ""
echo "💾 Backing up configuration..."
./scripts/backup-to-github.sh

echo ""
echo "🎉 Deployment complete! Ready for authentication setup."
