#!/bin/bash
set -euo pipefail

# Main deployment script for Jasmin Catering AI Email Processor
# Default deployment target: Sweden Central (due to Azure region restrictions)

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Force Sweden Central region
export AZURE_LOCATION="swedencentral"
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"

echo "🚀 Jasmin Catering AI Email Processor Deployment"
echo "==============================================="
echo ""
echo "📍 Configuration:"
echo "- Region: Sweden Central (default)"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Email Filter: ma3u-test@email.de"
echo "- AI Service: Azure Cognitive Services (GPT-4)"
echo ""

# Login check
echo "📝 Checking Azure login..."
if ! az account show &>/dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Set subscription
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Create resource group
echo ""
echo "📁 Creating resource group..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$AZURE_LOCATION" \
    --output none || echo "Resource group already exists"

# Deploy Logic App
echo ""
echo "🔄 Deploying Logic App workflow..."

# Check if workflow definition exists
WORKFLOW_FILE="$(dirname "$0")/../logic-apps/email-processor-workflow.json"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Error: Workflow definition not found at $WORKFLOW_FILE"
    exit 1
fi

# Inject API key into workflow
sed "s|@{parameters('apiKey')}|$AZURE_AI_API_KEY|g" "$WORKFLOW_FILE" > temp-workflow.json

# Create or update Logic App
az logic workflow create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow.json \
    --location "$AZURE_LOCATION" \
    --output none 2>/dev/null || \
az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow.json \
    --output none

# Clean up temp file
rm -f temp-workflow.json

# Get deployment status
echo ""
echo "✅ Deployment Complete!"
echo ""

# Show deployment info
WORKFLOW_STATE=$(az logic workflow show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --query state -o tsv)

echo "📋 Deployment Summary:"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- State: $WORKFLOW_STATE"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Location: Sweden Central"
echo ""

# Show portal link
echo "🔗 Azure Portal:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""

# Show monitoring command
echo "📊 Monitor with:"
echo "./monitor-logic-app.sh"
echo ""

echo "✨ Done! The email processor is deployed and ready."