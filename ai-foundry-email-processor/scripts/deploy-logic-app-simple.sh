#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🚀 Deploying Logic Apps Workflow"
echo "================================"

# Check if we're using existing Logic App or creating new
EXISTING_LOGIC_APP="$AZURE_LOGIC_APP_NAME"
NEW_LOGIC_APP="jasmin-order-processor"

echo "Checking existing Logic Apps..."
if az logic workflow show --resource-group $AZURE_RESOURCE_GROUP --name $EXISTING_LOGIC_APP &>/dev/null; then
    echo "✅ Found existing Logic App: $EXISTING_LOGIC_APP"
    echo "We'll add a new workflow to this Logic App."
    LOGIC_APP_NAME=$EXISTING_LOGIC_APP
else
    echo "Creating new Logic App: $NEW_LOGIC_APP"
    LOGIC_APP_NAME=$NEW_LOGIC_APP
fi

# Since the Azure CLI has issues with complex JSON, let's use a different approach
echo ""
echo "📋 Manual Deployment Steps:"
echo ""
echo "1. Go to Azure Portal: https://portal.azure.com"
echo "2. Navigate to Resource Group: $AZURE_RESOURCE_GROUP"
echo "3. Create or open Logic App: $LOGIC_APP_NAME"
echo "4. In Logic App Designer, switch to 'Code view'"
echo "5. Copy the workflow definition from:"
echo "   $(pwd)/../logic-app/order-processing-workflow.json"
echo ""
echo "6. Update these parameters in the workflow:"
echo "   - AI Foundry Endpoint: https://$AZURE_AI_SERVICES_ACCOUNT.cognitiveservices.azure.com/"
echo "   - Email: $WEBDE_EMAIL_ALIAS"
echo ""

# Create a deployment summary
cat > ../config/deployment-summary.json <<EOF
{
  "logicApp": {
    "name": "$LOGIC_APP_NAME",
    "resourceGroup": "$AZURE_RESOURCE_GROUP",
    "location": "$AZURE_LOCATION"
  },
  "connections": {
    "email": {
      "type": "IMAP",
      "server": "$WEBDE_IMAP_SERVER",
      "username": "$WEBDE_EMAIL_ALIAS",
      "toFilter": "$WEBDE_EMAIL_ALIAS"
    },
    "aiServices": {
      "endpoint": "https://$AZURE_AI_SERVICES_ACCOUNT.cognitiveservices.azure.com/",
      "project": "$AZURE_AI_PROJECT_NAME"
    }
  },
  "workflow": {
    "triggerInterval": "5 minutes",
    "emailKeywords": ["order", "bestell", "anfrage", "catering", "event"]
  }
}
EOF

echo "✅ Deployment configuration saved to: config/deployment-summary.json"
echo ""
echo "🔗 Direct link to Logic Apps:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"