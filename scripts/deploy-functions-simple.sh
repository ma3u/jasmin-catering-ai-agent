#!/bin/bash

# Simple Azure Functions Deployment Script
set -e

echo "🚀 Deploying Azure Functions for Jasmin Catering"
echo "=============================================="

# Configuration
RESOURCE_GROUP="jasmin-functions-rg"
LOCATION="northeurope"  # Changed from westeurope due to capacity issues
STORAGE_ACCOUNT="jasminfunc$(date +%s | tail -c 5)"
FUNCTION_APP_NAME="jasmin-gmail-functions"

# Ensure providers are registered
echo "📋 Registering Azure providers..."
az provider register --namespace Microsoft.Storage --wait
az provider register --namespace Microsoft.Web --wait
az provider register --namespace Microsoft.Insights --wait

# Create resource group
echo "📦 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
echo "💾 Creating storage account: $STORAGE_ACCOUNT..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS \
  --kind StorageV2

# Create function app
echo "⚡ Creating function app..."
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --runtime node \
  --runtime-version 20 \
  --functions-version 4 \
  --name $FUNCTION_APP_NAME \
  --storage-account $STORAGE_ACCOUNT

# Configure app settings
echo "⚙️ Configuring app settings..."
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    "GMAIL_CLIENT_ID=" \
    "GMAIL_CLIENT_SECRET=" \
    "GMAIL_REFRESH_TOKEN=" \
    "GMAIL_USER_EMAIL=mabu.mate@gmail.com" \
    "SLACK_TOKEN=" \
    "SLACK_CHANNEL=gmail-inbox"

# Get function URL
FUNCTION_URL=$(az functionapp show \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName -o tsv)

echo ""
echo "✅ Azure resources created successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Install Azure Functions Core Tools:"
echo "      brew tap azure/functions"
echo "      brew install azure-functions-core-tools@4"
echo ""
echo "   2. Deploy the function code:"
echo "      cd azure-functions"
echo "      npm install"
echo "      func azure functionapp publish $FUNCTION_APP_NAME"
echo ""
echo "   3. Set up Gmail OAuth:"
echo "      https://$FUNCTION_URL/api/getAuthUrl"
echo ""
echo "   4. Configure app settings in Azure Portal:"
echo "      - GMAIL_CLIENT_ID"
echo "      - GMAIL_CLIENT_SECRET"
echo "      - GMAIL_REFRESH_TOKEN"
echo "      - SLACK_TOKEN"
echo ""
echo "🔗 Azure Portal:"
echo "   https://portal.azure.com/#@/resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_APP_NAME"