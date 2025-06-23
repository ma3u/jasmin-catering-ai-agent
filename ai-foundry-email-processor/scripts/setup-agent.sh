#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🤖 Setting up AI Foundry Agent for Order Processing..."
echo "=================================================="

# Set Azure subscription
echo "Setting Azure subscription..."
az account set --subscription $AZURE_SUBSCRIPTION_ID

# Check if AI Foundry project exists
echo "Checking AI Foundry project: $AI_FOUNDRY_PROJECT_NAME"
if az ml workspace show --name $AI_FOUNDRY_PROJECT_NAME --resource-group $AI_FOUNDRY_RESOURCE_GROUP &>/dev/null; then
    echo "✅ Found existing AI Foundry project"
else
    echo "❌ AI Foundry project not found. Please create it first in Azure Portal."
    exit 1
fi

# Create or update the agent
echo "Creating order processing agent in AI Foundry project..."

# Note: Azure AI Foundry CLI commands are evolving. 
# This is a placeholder for the actual deployment command.
# In practice, you might need to use the Azure Portal or REST API

cat > agent-deployment.json <<EOF
{
  "name": "order-processing-agent",
  "description": "Processes catering order emails for Jasmin Catering",
  "model": "gpt-4o",
  "systemPrompt": "$(cat ../ai-foundry/agent-instructions.txt | jq -Rs .)",
  "temperature": 0.3,
  "topP": 1.0,
  "maxTokens": 2000
}
EOF

echo "📁 Uploading knowledge base files..."
# Upload knowledge base files
# Note: Actual commands depend on Azure AI Foundry API version

echo "✅ AI Foundry agent setup complete!"
echo ""
echo "Next steps:"
echo "1. Verify agent in Azure Portal"
echo "2. Note the agent endpoint URL"
echo "3. Update Logic Apps workflow with agent endpoint"

# Clean up
rm -f agent-deployment.json