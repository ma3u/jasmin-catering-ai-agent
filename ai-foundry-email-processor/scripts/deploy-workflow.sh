#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🚀 Deploying Logic Apps Workflow for Order Processing..."
echo "======================================================="

# Set Azure subscription
az account set --subscription $AZURE_SUBSCRIPTION_ID

# Check if Logic App exists
LOGIC_APP_NAME="jasmin-order-processor"
echo "Checking for existing Logic App: $LOGIC_APP_NAME"

# Create or update the Logic App workflow
if az logic workflow show --resource-group $AZURE_RESOURCE_GROUP --name $LOGIC_APP_NAME &>/dev/null; then
    echo "📝 Updating existing Logic App workflow..."
    ACTION="update"
else
    echo "✨ Creating new Logic App workflow..."
    ACTION="create"
fi

# Prepare parameters file
cat > parameters.json <<EOF
{
    "AIFoundryApiKey": {
        "value": "YOUR_AI_FOUNDRY_API_KEY"
    },
    "TeamsChannelId": {
        "value": "YOUR_TEAMS_CHANNEL_ID"
    },
    "StorageAccountName": {
        "value": "jasmincateringstorage"
    }
}
EOF

# Deploy the workflow
echo "Deploying workflow definition..."
if [ "$ACTION" = "create" ]; then
    az logic workflow create \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $LOGIC_APP_NAME \
        --location $AZURE_LOCATION \
        --definition "$(cat ../logic-app/order-processing-workflow.json)"
else
    az logic workflow update \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $LOGIC_APP_NAME \
        --definition "$(cat ../logic-app/order-processing-workflow.json)"
fi

if [ $? -eq 0 ]; then
    echo "✅ Logic App workflow deployed successfully!"
    
    # Get workflow details
    echo ""
    echo "Workflow Details:"
    az logic workflow show \
        --resource-group $AZURE_RESOURCE_GROUP \
        --name $LOGIC_APP_NAME \
        --query "{Name:name, State:state, Location:location, Id:id}" \
        --output table
else
    echo "❌ Failed to deploy Logic App workflow"
    exit 1
fi

# Clean up
rm -f parameters.json

echo ""
echo "📋 Next Steps:"
echo "1. Configure API connections in Azure Portal"
echo "2. Authorize web.de email connection"
echo "3. Set up Teams channel for notifications"
echo "4. Test with a sample order email"