#!/bin/bash
set -euo pipefail

# Update existing Logic App to use OpenAI Assistant API
# This script updates the jasmin-order-processor-sweden to use assistant ID: asst_MN5PHipyHYPXyq3fENx7V20j

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Configuration
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"
export ASSISTANT_ID="asst_MN5PHipyHYPXyq3fENx7V20j"
export WORKFLOW_FILE="$(dirname "$0")/../logic-apps/email-processor-assistant-workflow.json"

echo "🤖 Updating Logic App to use OpenAI Assistant API"
echo "================================================"
echo ""
echo "📍 Configuration:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Assistant ID: $ASSISTANT_ID"
echo "- Region: $AZURE_LOCATION"
echo ""

# Check if workflow file exists
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Error: Assistant workflow file not found: $WORKFLOW_FILE"
    exit 1
fi

# Prepare workflow definition with API key injected
echo "🔧 Preparing workflow with Assistant API configuration..."
TEMP_WORKFLOW="/tmp/workflow-assistant-$(date +%s).json"
sed "s/@{parameters('apiKey')}/$AZURE_AI_API_KEY/g" "$WORKFLOW_FILE" > "$TEMP_WORKFLOW"

# Update the Logic App
echo ""
echo "🔄 Updating Logic App workflow..."
az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition "@$TEMP_WORKFLOW" \
    --output none

# Clean up temp file
rm -f "$TEMP_WORKFLOW"

# Get workflow state
echo ""
echo "📊 Checking deployment status..."
STATE=$(az logic workflow show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --query state --output tsv)

echo "✅ Logic App State: $STATE"

# Display summary
echo ""
echo "✅ Update Complete!"
echo ""
echo "📋 Summary:"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Now using Assistant: $ASSISTANT_ID"
echo "- State: $STATE"
echo ""
echo "🔗 Assistant API Features:"
echo "- Creates conversation threads for each email"
echo "- Uses pre-configured assistant knowledge"
echo "- Maintains conversation context"
echo "- Provides consistent responses"
echo ""
echo "📊 Monitor with:"
echo "   ./monitor-logic-app.sh"
echo ""
echo "🔍 View in Azure Portal:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "✨ The Logic App is now using the OpenAI Assistant API!"