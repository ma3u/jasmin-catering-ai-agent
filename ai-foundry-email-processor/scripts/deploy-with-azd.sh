#!/bin/bash
set -euo pipefail

# Complete deployment using Azure Developer CLI (azd)

echo "🚀 Deploying with Azure Developer CLI (azd)"
echo "=========================================="

# Change to the ai-foundry-email-processor directory
cd "$(dirname "$0")/.."

# Check if azd is installed
if ! command -v azd &> /dev/null; then
    echo "❌ Azure Developer CLI (azd) is not installed"
    echo "Install with: brew install azure-dev-cli"
    exit 1
fi

# Load configuration from parent .env
if [ ! -f "../.env" ]; then
    echo "❌ Parent .env file not found!"
    exit 1
fi

echo "📝 Loading configuration from .env..."
export $(cat ../.env | grep -E '^[A-Z_]+=.*' | grep -v '^#' | xargs)

# Initialize azd environment if needed
if [ ! -f ".azure/production/config.json" ]; then
    echo "🔧 Initializing azd environment..."
    azd init --environment production --no-prompt
fi

# Set environment variables from .env
echo "Setting environment variables..."
azd env set AZURE_AI_API_KEY "$AZURE_AI_API_KEY" --environment production
azd env set WEBDE_APP_PASSWORD "$WEBDE_APP_PASSWORD" --environment production
azd env set WEBDE_EMAIL_ALIAS "$WEBDE_EMAIL_ALIAS" --environment production
azd env set AZURE_AI_ENDPOINT "$AZURE_AI_ENDPOINT" --environment production
azd env set AZURE_LOCATION "${AZURE_LOCATION:-westeurope}" --environment production

# Set subscription if provided
if [ ! -z "$AZURE_SUBSCRIPTION_ID" ]; then
    azd env set AZURE_SUBSCRIPTION_ID "$AZURE_SUBSCRIPTION_ID" --environment production
fi

# Deploy everything
echo ""
echo "🚀 Starting deployment..."
azd up --environment production

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📋 What was deployed:"
echo "- Resource Group: $(azd env get-values --environment production | grep AZURE_RESOURCE_GROUP | cut -d'=' -f2)"
echo "- Logic App: $(azd env get-values --environment production | grep LOGIC_APP_NAME | cut -d'=' -f2)"
echo "- Storage Account: $(azd env get-values --environment production | grep STORAGE_ACCOUNT_NAME | cut -d'=' -f2)"
echo ""
echo "📧 Test by sending email to: $WEBDE_EMAIL_ALIAS"
echo "Subject must contain: Catering, Anfrage, Order, or Bestell"