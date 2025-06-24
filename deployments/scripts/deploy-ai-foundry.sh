#!/bin/bash
set -euo pipefail

# Deploy Logic App with AI Foundry Integration
# Note: AI Foundry uses the same underlying AI Services resource

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Force Sweden Central region
export AZURE_LOCATION="swedencentral"
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"

echo "🚀 Jasmin Catering AI Email Processor - AI Foundry Deployment"
echo "============================================================="
echo ""
echo "📋 AI Configuration:"
echo "- AI Service: Azure AI Foundry"
echo "- Project: jasmin-catering"
echo "- Resource: jasmin-catering-resource"
echo "- Model: gpt-4o"
echo "- Endpoint Type: AI Services (via AI Foundry project)"
echo ""
echo "ℹ️  Note: AI Foundry project uses the underlying AI Services endpoint"
echo "   for API calls. This is the standard Azure AI architecture."
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

# Deploy Logic App with AI Foundry configuration
echo ""
echo "🔄 Deploying Logic App with AI Foundry integration..."

# Prepare workflow with API key embedded
WORKFLOW_FILE="$(dirname "$0")/../logic-apps/ai-foundry-workflow.json"
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
echo "🤖 AI Foundry Configuration:"
echo "- Project: jasmin-catering"
echo "- Resource: jasmin-catering-resource"
echo "- Endpoint: AI Services (Cognitive Services compatible)"
echo "- Model: gpt-4o"
echo ""

# Show portal links
echo "🔗 Azure Resources:"
echo "Logic App: https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo "AI Project: https://ai.azure.com/project/$AZURE_AI_PROJECT_NAME"
echo ""

# Test AI endpoint
echo "🧪 Testing AI endpoint..."
TEST_RESPONSE=$(curl -s -X POST "https://jasmin-catering-resource.cognitiveservices.azure.com/openai/deployments/gpt-4o/chat/completions?api-version=2024-02-01" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_AI_API_KEY" \
  -d '{
    "messages": [{"role": "user", "content": "Sage Hallo auf Deutsch"}],
    "max_tokens": 50
  }' | jq -r '.choices[0].message.content' 2>/dev/null || echo "Connection test failed")

if [ "$TEST_RESPONSE" != "Connection test failed" ]; then
    echo "✅ AI endpoint test successful"
    echo "Response: $TEST_RESPONSE"
else
    echo "⚠️  AI endpoint test failed - check API key and endpoint"
fi

echo ""
echo "📊 Monitor with:"
echo "./monitor-logic-app.sh"
echo ""

echo "✨ Done! The email processor is deployed with AI Foundry integration."