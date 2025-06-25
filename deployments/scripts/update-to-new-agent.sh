#!/bin/bash
set -euo pipefail

# Update Logic App to use the newly created Azure AI Agent
# Agent ID: asst_xaWmWbwVkjLslHiRrg9teIP0

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

# Configuration
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-sweden"
export NEW_AGENT_ID="asst_xaWmWbwVkjLslHiRrg9teIP0"
export WORKFLOW_FILE="$(dirname "$0")/../logic-apps/email-processor-assistant-workflow.json"

echo "🤖 Updating Logic App to use NEW Azure AI Agent"
echo "==============================================="
echo ""
echo "📍 Configuration:"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- NEW Agent ID: $NEW_AGENT_ID"
echo "- Region: $AZURE_LOCATION"
echo ""

# Create updated workflow with new agent ID
echo "🔧 Preparing workflow with new Agent ID..."
TEMP_WORKFLOW="/tmp/workflow-new-agent-$(date +%s).json"

# Replace the old assistant ID with the new one and inject API key
sed -e "s/asst_MN5PHipyHYPXyq3fENx7V20j/$NEW_AGENT_ID/g" \
    -e "s/@{parameters('apiKey')}/$AZURE_AI_API_KEY/g" \
    "$WORKFLOW_FILE" > "$TEMP_WORKFLOW"

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
echo "- Now using NEW Agent: $NEW_AGENT_ID"
echo "- State: $STATE"
echo ""
echo "🔗 New Agent Features:"
echo "- Created with Azure AI Projects SDK"
echo "- Configured with Jasmin Catering prompt"
echo "- File search tool enabled"
echo "- Ready for RAG document upload"
echo ""
echo "📊 Monitor with:"
echo "   ./monitor-logic-app.sh"
echo ""
echo "🔍 View in Azure Portal:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "✨ The Logic App is now using the NEW Azure AI Agent!"
echo ""
echo "📝 Agent Details:"
echo "   Old ID: asst_MN5PHipyHYPXyq3fENx7V20j (not found)"
echo "   New ID: $NEW_AGENT_ID (created today)"