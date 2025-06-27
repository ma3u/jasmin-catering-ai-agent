#!/bin/bash
set -euo pipefail

# Deploy Logic App with Chat Completions API (no Assistant needed)
# Uses a summarized prompt that fits in the workflow

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Configuration
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"
export WORKFLOW_FILE="$(dirname "$0")/../logic-apps/email-processor-workflow.json"

echo "🚀 Deploying Logic App with Chat Completions API"
echo "==============================================="
echo ""
echo "📍 Configuration:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Endpoint: https://jasmin-catering-resource.cognitiveservices.azure.com"
echo "- Model: gpt-4o"
echo ""

# Update the original workflow
echo "🔄 Updating Logic App..."
TEMP_WORKFLOW="/tmp/workflow-$(date +%s).json"
sed "s/@{parameters('apiKey')}/$AZURE_AI_API_KEY/g" "$WORKFLOW_FILE" > "$TEMP_WORKFLOW"

az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition "@$TEMP_WORKFLOW" \
    --output none

rm -f "$TEMP_WORKFLOW"

# Check status
STATE=$(az logic workflow show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --query state --output tsv)

echo ""
echo "✅ Deployment Complete!"
echo ""
echo "📋 Summary:"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- State: $STATE"
echo "- API: Chat Completions (Direct)"
echo "- Model: gpt-4o"
echo ""
echo "📊 Monitor with: ./monitor-logic-app.sh"
echo ""
echo "✨ The Logic App is now using Chat Completions API!"