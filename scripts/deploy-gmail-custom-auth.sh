#!/bin/bash

# Deploy Gmail + HTTP Slack with Custom Google Client App
# This uses "Bring your own application" to bypass ALL Gmail restrictions

set -e

echo "🔧 Deploying Gmail + Slack with Custom Google Authentication..."
echo ""
echo "📋 Prerequisites:"
echo "   1. Google Client App created at: https://console.developers.google.com"
echo "   2. Gmail API enabled"
echo "   3. Client ID and Client Secret ready"
echo ""

# Get Google client credentials
read -p "📝 Enter your Google Client ID: " GOOGLE_CLIENT_ID
read -p "🔑 Enter your Google Client Secret: " GOOGLE_CLIENT_SECRET

if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
    echo "❌ Error: Both Client ID and Client Secret are required"
    exit 1
fi

echo ""
echo "✅ Using Google Client App authentication"
echo "📧 Email: mabu.mate@gmail.com"
echo "💬 Slack webhook: https://hooks.slack.com/services/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"
echo ""

RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"

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
cat > logicapp/gmail-custom-auth-workflow.json << EOF
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
        "uri": "https://hooks.slack.com/services/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",
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

echo "🚀 Deploying updated workflow..."

# Deploy the workflow
az resource update \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Logic/workflows" \
  --name $LOGIC_APP_NAME \
  --set properties.definition="$(cat logicapp/gmail-custom-auth-workflow.json)"

echo ""
echo "✅ Workflow deployed successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Go to LogicApp Designer:"
echo "      https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "   2. Click on Gmail trigger and configure authentication:"
echo "      - Authentication Type: 'Bring your own application'"
echo "      - Client ID: $GOOGLE_CLIENT_ID"
echo "      - Client Secret: $GOOGLE_CLIENT_SECRET"
echo ""
echo "   3. Save and test with email to mabu.mate@gmail.com"
echo ""
echo "🎯 Expected result: Email forwarded to Slack #gmail-inbox with no restrictions!"
