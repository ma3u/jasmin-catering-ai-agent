#!/bin/bash
set -euo pipefail

# Deploy the actual workflow definition to the Logic App created by azd

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "📋 Deploying workflow to Logic App..."

# Get the Logic App name from azd environment
LOGIC_APP_NAME=$(azd env get-values | grep LOGIC_APP_NAME | cut -d'=' -f2 | tr -d '"')
RESOURCE_GROUP=$(azd env get-values | grep AZURE_RESOURCE_GROUP | cut -d'=' -f2 | tr -d '"')

if [ -z "$LOGIC_APP_NAME" ] || [ -z "$RESOURCE_GROUP" ]; then
    echo "Error: Could not get Logic App details from azd environment"
    exit 1
fi

echo "Deploying to Logic App: $LOGIC_APP_NAME in $RESOURCE_GROUP"

# Create workflow with environment variables substituted
cat ../logic-app/order-processing-workflow.json | \
    sed "s|@parameters('AIFoundryApiKey')|$AZURE_AI_API_KEY|g" | \
    sed "s|@parameters('email_alias')|$WEBDE_EMAIL_ALIAS|g" | \
    sed "s|@parameters('email_password')|$WEBDE_APP_PASSWORD|g" | \
    sed "s|https://jasmin-catering-resource.services.ai.azure.com/api/projects/jasmin-catering|$AZURE_AI_ENDPOINT|g" > temp-workflow.json

# Update the Logic App with the complete workflow
az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow.json

# Cleanup
rm -f temp-workflow.json

echo "✅ Workflow deployed successfully!"