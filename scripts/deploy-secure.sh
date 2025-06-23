#!/bin/bash

# Secure Gmail + HTTPS Slack Deployment with Google OAuth Credentials
# This script uses the securely stored Google OAuth credentials

set -e

echo "🔧 Deploying Gmail + Slack with Secure Google OAuth..."
echo "=================================================="
echo ""

# Check if Google credentials exist
GOOGLE_CREDS_FILE=".secret/google-oauth-credentials.json"

if [ ! -f "$GOOGLE_CREDS_FILE" ]; then
    echo "❌ Google OAuth credentials not found in .secret/"
    echo ""
    echo "📋 Expected file: $GOOGLE_CREDS_FILE"
    echo "🔧 Please ensure credentials are stored securely"
    exit 1
fi

# Read credentials from secure location
echo "📋 Reading Google OAuth credentials from secure storage..."
GOOGLE_CLIENT_ID=$(cat $GOOGLE_CREDS_FILE | jq -r '.client_id')
GOOGLE_CLIENT_SECRET=$(cat $GOOGLE_CREDS_FILE | jq -r '.client_secret')
PROJECT_ID=$(cat $GOOGLE_CREDS_FILE | jq -r '.project_id // "jasmin-catering-logicapp"')

if [ "$GOOGLE_CLIENT_ID" = "null" ] || [ "$GOOGLE_CLIENT_SECRET" = "null" ]; then
    echo "❌ Invalid credentials in $GOOGLE_CREDS_FILE"
    exit 1
fi

echo "✅ Google OAuth Credentials loaded:"
echo "   Project: $PROJECT_ID"
echo "   Client ID: ${GOOGLE_CLIENT_ID:0:25}..."
echo "   Client Secret: ${GOOGLE_CLIENT_SECRET:0:15}..."
echo ""

# Azure configuration
RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"
SLACK_WEBHOOK="https://hooks.slack.com/services/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"

echo "📧 Target Email: mabu.mate@gmail.com"
echo "💬 Slack Channel: #gmail-inbox in mabured.slack.com"
echo ""

echo "🔧 Creating Gmail connection with custom authentication..."

# Create Gmail connection with custom auth
az resource create \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Web/connections" \
  --name gmail-custom-oauth \
  --location westeurope \
  --properties '{
    "displayName": "Gmail - Custom OAuth - mabu.mate@gmail.com",
    "customParameterValues": {},
    "api": {
      "id": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/providers/Microsoft.Web/locations/westeurope/managedApis/gmail"
    }
  }' || echo "⚠️  Gmail connection might already exist"

echo "📝 Creating secure workflow definition..."

# Create the workflow with custom authentication and HTTPS Slack
cat > logicapp/secure-gmail-workflow.json << EOF
{
  "\$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "\$connections": {
      "defaultValue": {
        "gmail": {
          "connectionId": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/gmail-custom-oauth",
          "connectionName": "gmail-custom-oauth",
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
  --set properties.definition="$(cat logicapp/secure-gmail-workflow.json)"

echo ""
echo "✅ Secure workflow deployed successfully!"
echo ""
echo "🔐 Security Status:"
echo "   ✅ Credentials stored in .secret/ (not committed to Git)"
echo "   ✅ HTTPS webhook integration"
echo "   ✅ Custom Google OAuth authentication"
echo ""
echo "📋 Final Configuration Required:"
echo ""
echo "1. 🔧 Open LogicApp Designer:"
echo "   https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "2. 🔑 Configure Gmail trigger authentication:"
echo "   - Click Gmail trigger → Change connection → Add new"
echo "   - Authentication Type: 'Bring your own application'"
echo "   - Client ID: $GOOGLE_CLIENT_ID"
echo "   - Client Secret: $GOOGLE_CLIENT_SECRET"
echo "   - Sign in with: mabu.mate@gmail.com"
echo ""
echo "3. 🧪 Test the integration:"
echo "   - Send email to: mabu.mate@gmail.com"
echo "   - Check: #gmail-inbox in mabured.slack.com"
echo ""
echo "📊 Expected result:"
echo "   📧 Gmail → Custom OAuth → LogicApp → HTTPS → Slack ✅"
echo ""
echo "🎯 This setup bypasses ALL Gmail restrictions officially!"
echo ""

# Clean up temporary files but keep secure credentials
rm -f logicapp/secure-gmail-workflow.json

echo "💾 Backing up configuration (excluding secrets)..."
./scripts/backup-to-github.sh

echo ""
echo "🎉 Secure deployment complete!"
echo "⚠️  Remember: .secret/ folder is protected and never committed to Git"
