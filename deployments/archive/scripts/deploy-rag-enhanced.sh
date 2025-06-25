#!/bin/bash
set -euo pipefail

# Enhanced deployment script for Jasmin Catering AI with RAG
# This script deploys both the vector database and enhanced Logic App

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

# Force Sweden Central region
export AZURE_LOCATION="swedencentral"
export RESOURCE_GROUP="logicapp-jasmin-sweden_group"
export LOGIC_APP_NAME="jasmin-order-processor-rag"

echo "🚀 Jasmin Catering AI with RAG Deployment"
echo "========================================"
echo ""
echo "📍 Configuration:"
echo "- Region: Sweden Central"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- Email Filter: ma3u-test@email.de"
echo "- AI Service: Azure AI Foundry with RAG"
echo "- Search Service: jasmin-catering-search"
echo ""

# Login check
echo "📝 Checking Azure login..."
if ! az account show &>/dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Set subscription
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# Step 1: Setup Vector Database
echo ""
echo "🔍 Step 1: Setting up Vector Database..."
if [ -f "$(dirname "$0")/setup-vector-db.sh" ]; then
    ./setup-vector-db.sh
else
    echo "❌ Error: setup-vector-db.sh not found"
    exit 1
fi

# Get search key
echo ""
echo "🔑 Getting Search Service key..."
SEARCH_KEY=$(az search admin-key show \
    --service-name jasmin-catering-search \
    --resource-group "$RESOURCE_GROUP" \
    --query primaryKey -o tsv 2>/dev/null || echo "")

if [ -z "$SEARCH_KEY" ]; then
    echo "❌ Error: Could not retrieve search key. Please run setup-vector-db.sh first."
    exit 1
fi

echo "✅ Search key retrieved"

# Step 2: Deploy Enhanced Logic App
echo ""
echo "🔄 Step 2: Deploying Enhanced Logic App with RAG..."

# Check if enhanced workflow definition exists
WORKFLOW_FILE="$(dirname "$0")/../logic-apps/email-processor-workflow-rag.json"
if [ ! -f "$WORKFLOW_FILE" ]; then
    echo "❌ Error: Enhanced workflow definition not found at $WORKFLOW_FILE"
    exit 1
fi

# Inject API keys into workflow
sed -e "s|@{parameters('apiKey')}|$AZURE_AI_API_KEY|g" \
    -e "s|@{parameters('searchKey')}|$SEARCH_KEY|g" \
    "$WORKFLOW_FILE" > temp-workflow-rag.json

# Create or update Logic App
az logic workflow create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow-rag.json \
    --location "$AZURE_LOCATION" \
    --output none 2>/dev/null || \
az logic workflow update \
    --resource-group "$RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow-rag.json \
    --output none

# Clean up temp file
rm -f temp-workflow-rag.json

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
echo "- Logic App: $LOGIC_APP_NAME (RAG-enhanced)"
echo "- State: $WORKFLOW_STATE"
echo "- Resource Group: $RESOURCE_GROUP"
echo "- Location: Sweden Central"
echo "- Vector Database: jasmin-catering-search"
echo "- Knowledge Index: jasmin-catering-knowledge"
echo ""

# Test vector database
echo "🧪 Testing Vector Database..."
curl -s -X POST \
    "https://jasmin-catering-search.search.windows.net/indexes/jasmin-catering-knowledge/docs/search?api-version=2023-11-01" \
    -H "Content-Type: application/json" \
    -H "api-key: $SEARCH_KEY" \
    -d '{"search": "fingerfood", "top": 1}' | \
    jq -r '.value[0].title // "No results found"' | \
    xargs -I {} echo "✅ Vector DB Test: {}"

# Show portal links
echo ""
echo "🔗 Azure Portal Links:"
echo "Logic App: https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo "Search Service: https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Search/searchServices/jasmin-catering-search"
echo ""

# Show monitoring command
echo "📊 Monitor with:"
echo "az logic workflow run list --resource-group $RESOURCE_GROUP --workflow-name $LOGIC_APP_NAME --top 5"
echo ""

# Update .env file
echo "💾 Updating .env with new configuration..."
if [ -f "../../.env" ]; then
    # Add search configuration if not exists
    if ! grep -q "AZURE_SEARCH_SERVICE" "../../.env"; then
        echo "" >> "../../.env"
        echo "# Vector Database Configuration" >> "../../.env"
        echo "AZURE_SEARCH_SERVICE=jasmin-catering-search" >> "../../.env"
        echo "AZURE_SEARCH_KEY=$SEARCH_KEY" >> "../../.env"
        echo "AZURE_SEARCH_INDEX=jasmin-catering-knowledge" >> "../../.env"
        echo "✅ Added search configuration to .env"
    fi
fi

echo ""
echo "🎉 RAG-Enhanced System Ready!"
echo ""
echo "The system now includes:"
echo "✅ Vector database with 4 catering documents"
echo "✅ Enhanced AI responses using RAG"
echo "✅ Three-tier offer generation (Basis/Standard/Premium)"
echo "✅ German email templates with authentic Syrian menu items"
echo ""
echo "Test by sending an email to: ma3u-test@email.de"