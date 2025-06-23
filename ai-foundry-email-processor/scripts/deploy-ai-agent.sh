#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🤖 Deploying AI Agent to Existing Azure AI Foundry Project"
echo "========================================================="
echo "Project: $AZURE_AI_PROJECT_NAME"
echo "Resource Group: $AZURE_AI_RESOURCE_GROUP"
echo ""

# Get the AI services endpoint
AI_ENDPOINT="https://$AZURE_AI_SERVICES_ACCOUNT.cognitiveservices.azure.com/"
echo "AI Services Endpoint: $AI_ENDPOINT"

# Since Azure AI Foundry agent deployment via CLI is still evolving,
# we'll provide the manual steps and configuration

echo ""
echo "📋 Manual Steps Required in Azure AI Studio:"
echo "1. Go to: https://ai.azure.com"
echo "2. Select your project: $AZURE_AI_PROJECT_NAME"
echo "3. Navigate to 'Build' > 'Agents' (or 'Deployments')"
echo "4. Create a new agent with these settings:"
echo ""
echo "   Agent Name: order-processing-agent"
echo "   Model: gpt-4o"
echo "   Temperature: 0.3"
echo "   Max Tokens: 2000"
echo ""
echo "5. Copy and paste the agent instructions from:"
echo "   $(pwd)/../ai-foundry/agent-instructions.txt"
echo ""
echo "6. Upload knowledge base files from:"
echo "   $(pwd)/../ai-foundry/knowledge-base/"
echo ""
echo "7. After creation, note the agent endpoint URL"
echo ""

# Create a configuration file for reference
cat > ../config/ai-agent-config.json <<EOF
{
  "projectName": "$AZURE_AI_PROJECT_NAME",
  "resourceGroup": "$AZURE_AI_RESOURCE_GROUP",
  "endpoint": "$AI_ENDPOINT",
  "agentName": "order-processing-agent",
  "model": "gpt-4o",
  "configuration": {
    "temperature": 0.3,
    "topP": 1.0,
    "maxTokens": 2000
  },
  "knowledgeBase": [
    "order-templates.md",
    "response-examples.md",
    "company-policies.md"
  ]
}
EOF

echo "✅ Configuration saved to: config/ai-agent-config.json"
echo ""
echo "🔗 Direct link to Azure AI Studio:"
echo "https://ai.azure.com/build/project/$AZURE_AI_PROJECT_NAME?tenantId=$AZURE_TENANT_ID"