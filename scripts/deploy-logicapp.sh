#!/bin/bash

# Jasmin Catering LogicApp Deployment Script
# This script deploys the LogicApp with Gmail to Slack forwarding

set -e

# Variables
SUBSCRIPTION_ID="b58b1820-35f0-4271-99be-7c84d4dd40f3"
RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOCATION="westeurope"
LOGIC_APP_NAME="mabu-logicapps"
GMAIL_CONNECTION_NAME="gmail-mabu-mate"
SLACK_CONNECTION_NAME="slack-mabured"

echo "🚀 Starting Jasmin Catering LogicApp deployment..."
echo "📂 Working directory: $(pwd)"

# Check if workflow definition exists
if [ ! -f "logicapp/workflow-definition.json" ]; then
    echo "❌ Error: workflow-definition.json not found in logicapp/ directory"
    exit 1
fi

# Set the subscription
echo "🔧 Setting Azure subscription..."
az account set --subscription $SUBSCRIPTION_ID

# Create Gmail API Connection
echo "📧 Creating Gmail connection..."
az resource create \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Web/connections" \
  --name $GMAIL_CONNECTION_NAME \
  --location $LOCATION \
  --properties '{
    "displayName": "Gmail - mabu.mate@gmail.com",
    "customParameterValues": {},
    "api": {
      "id": "/subscriptions/'$SUBSCRIPTION_ID'/providers/Microsoft.Web/locations/'$LOCATION'/managedApis/gmail"
    }
  }' || echo "⚠️  Gmail connection might already exist"
# Create Slack API Connection  
echo "💬 Creating Slack connection..."
az resource create \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Web/connections" \
  --name $SLACK_CONNECTION_NAME \
  --location $LOCATION \
  --properties '{
    "displayName": "Slack - mabured.slack.com",
    "customParameterValues": {},
    "api": {
      "id": "/subscriptions/'$SUBSCRIPTION_ID'/providers/Microsoft.Web/locations/'$LOCATION'/managedApis/slack"
    }
  }' || echo "⚠️  Slack connection might already exist"

# Create parameters file
echo "📝 Creating workflow parameters..."
cat > logicapp/workflow-parameters.json << EOF
{
  "\$connections": {
    "value": {
      "gmail": {
        "connectionId": "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$GMAIL_CONNECTION_NAME",
        "connectionName": "$GMAIL_CONNECTION_NAME",
        "id": "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$LOCATION/managedApis/gmail"
      },
      "slack": {
        "connectionId": "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$SLACK_CONNECTION_NAME",
        "connectionName": "$SLACK_CONNECTION_NAME",
        "id": "/subscriptions/$SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$LOCATION/managedApis/slack"
      }
    }
  }
}
EOF

# Update the LogicApp workflow
echo "⚙️ Updating LogicApp workflow..."

# Create the complete workflow definition with parameters
jq --argjson connections "$(cat logicapp/workflow-parameters.json | jq '."\$connections".value')" \
   '.parameters."\$connections".defaultValue = $connections' \
   logicapp/workflow-definition.json > logicapp/complete-workflow.json

# Update the LogicApp using az resource update
az resource update \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Logic/workflows" \
  --name $LOGIC_APP_NAME \
  --set properties.definition="$(cat logicapp/complete-workflow.json)"
echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Go to Azure Portal: https://portal.azure.com"
echo "   2. Navigate to Resource Group: $RESOURCE_GROUP"
echo "   3. Open API connections and authorize:"
echo "      - $GMAIL_CONNECTION_NAME (Gmail OAuth)"
echo "      - $SLACK_CONNECTION_NAME (Slack OAuth)"
echo "   4. Test by sending email to mabu.mate@gmail.com"
echo "   5. Check #gmail-inbox channel in mabured.slack.com"
echo ""
echo "🔗 Direct links:"
echo "   LogicApp: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo "   Gmail Connection: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$GMAIL_CONNECTION_NAME"
echo "   Slack Connection: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/$SLACK_CONNECTION_NAME"

# Backup to GitHub
echo ""
echo "💾 Backing up configuration to GitHub..."
if [ -f "scripts/backup-to-github.sh" ]; then
    chmod +x scripts/backup-to-github.sh
    ./scripts/backup-to-github.sh
else
    echo "⚠️  backup-to-github.sh not found. Creating it now..."
fi

echo ""
echo "🎉 Setup complete! Check the links above to authorize connections."