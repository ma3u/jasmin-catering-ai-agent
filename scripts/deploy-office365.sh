#!/bin/bash

# Deploy Office 365 + Slack Webhook Workflow
# This bypasses ALL Gmail connector restrictions

set -e

echo "🔧 Deploying Office 365 + Slack webhook workflow..."
echo ""
echo "⚠️  IMPORTANT: This will replace the Gmail trigger with Office 365"
echo "📧 You'll need an Office 365/Outlook email address to monitor"
echo ""

# Confirm deployment
read -p "Continue with Office 365 deployment? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

RESOURCE_GROUP="logicapp-jasmin-catering_group"
LOGIC_APP_NAME="mabu-logicapps"

echo "🔧 Creating Office 365 connection..."

# Create Office 365 connection
az resource create \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Web/connections" \
  --name office365-jasmin \
  --location westeurope \
  --properties '{
    "displayName": "Office 365 - Jasmin Catering",
    "customParameterValues": {},
    "api": {
      "id": "/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/providers/Microsoft.Web/locations/westeurope/managedApis/office365"
    }
  }' || echo "⚠️  Office 365 connection might already exist"

echo "🚀 Deploying Office 365 workflow..."

# Deploy the workflow
az resource update \
  --resource-group $RESOURCE_GROUP \
  --resource-type "Microsoft.Logic/workflows" \
  --name $LOGIC_APP_NAME \
  --set properties.definition="$(cat logicapp/office365-slack-workflow.json)"

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Go to Azure Portal and authorize Office 365 connection:"
echo "      https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/connections/office365-jasmin"
echo ""
echo "   2. Open LogicApp Designer and configure email address:"
echo "      https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "   3. Test with Office 365 email"
echo ""
echo "🎯 Alternative: Keep Gmail with Azure Functions approach"
echo "   Run: ./scripts/setup-gmail-functions.sh"
