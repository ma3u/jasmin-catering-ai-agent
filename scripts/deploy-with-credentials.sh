#!/bin/bash

# Deploy LogicApp with Google OAuth Credentials
# Uses credentials from .secret/ directory (never committed to GitHub)

set -e

echo "🚀 Deploying Gmail + HTTPS Slack LogicApp with OAuth credentials..."
echo ""

# Check if credentials exist
CREDS_FILE=".secret/google-oauth-credentials.json"

if [ ! -f "$CREDS_FILE" ]; then
    echo "❌ Error: Google OAuth credentials not found!"
    echo "   Expected: $CREDS_FILE"
    echo ""
    echo "📝 Please create the credentials file:"
    echo "   mkdir -p .secret"
    echo "   # Add your Google OAuth credentials to $CREDS_FILE"
    exit 1
fi

# Read credentials
echo "🔑 Reading Google OAuth credentials..."
CLIENT_ID=$(cat $CREDS_FILE | jq -r '.client_id')
CLIENT_SECRET=$(cat $CREDS_FILE | jq -r '.client_secret')

if [ "$CLIENT_ID" = "null" ] || [ "$CLIENT_SECRET" = "null" ]; then
    echo "❌ Error: Invalid credentials in $CREDS_FILE"
    exit 1
fi

echo "✅ Credentials loaded:"
echo "   Client ID: ${CLIENT_ID:0:20}...${CLIENT_ID: -20}"
echo "   Project: Jasmin Catering LogicApp"
echo ""

# Azure configuration
RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"
SLACK_WEBHOOK="https://hooks.slack.com/services/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"

echo "📧 Email: mabu.mate@gmail.com"
echo "💬 Slack: #gmail-inbox in mabured.slack.com"
echo ""

echo "🔧 Creating Gmail connection with custom authentication..."

# Create Gmail connection
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
  }' || echo "⚠️  Gmail connection already exists"

echo "📝 Creating LogicApp workflow definition..."

# Create the complete workflow
cat > logicapp/final-workflow.json << EOF
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
  --set properties.definition="$(cat logicapp/final-workflow.json)"

echo ""
echo "✅ LogicApp workflow deployed successfully!"
echo ""
echo "🔧 Final manual step: Configure authentication in Azure Portal"
echo ""
echo "1. 🌐 Open LogicApp Designer:"
echo "   https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "2. 🔑 Configure Gmail trigger authentication:"
echo "   - Click on Gmail trigger"
echo "   - Select 'Change connection' or connection settings"
echo "   - Choose 'Add new' or edit existing"
echo "   - Authentication Type: 'Bring your own application'"
echo "   - Client ID: $CLIENT_ID"
echo "   - Client Secret: $CLIENT_SECRET"
echo "   - Sign in with: mabu.mate@gmail.com"
echo ""
echo "3. 🧪 Test the integration:"
echo "   - Send email to: mabu.mate@gmail.com"
echo "   - Check: #gmail-inbox in mabured.slack.com"
echo ""
echo "📊 Expected message format in Slack:"
echo "   📧 New Email for Jasmin Catering"
echo "   From: sender@example.com"
echo "   Subject: Test message"
echo "   Preview: Email content..."
echo "   🤖 Next Steps: AI Agent processing"
echo ""
echo "🎉 Gmail + HTTPS Slack integration ready!"
echo ""
echo "🔒 Security: Credentials stored in .secret/ (excluded from Git)"
echo "🚀 Next phase: Azure AI Foundry integration"
