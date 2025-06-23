#!/bin/bash

# Azure Functions Deployment Script for Jasmin Catering Gmail Integration
# This bypasses LogicApps restrictions by using direct Gmail API access

set -e

echo "🚀 Deploying Azure Functions for Jasmin Catering Gmail Integration"
echo "=================================================="

# Configuration
RESOURCE_GROUP="jasmin-catering-functions-rg"
LOCATION="westeurope"
# Storage account name must be globally unique and lowercase
STORAGE_ACCOUNT="jasmincatering$(date +%s)"
FUNCTION_APP_NAME="jasmin-catering-functions"
APP_INSIGHTS_NAME="jasmin-catering-insights"
SUBSCRIPTION_ID="b58b1820-35f0-4271-99be-7c84d4dd40f3"

# Check if logged in to Azure
echo "🔐 Checking Azure login status..."
if ! az account show &>/dev/null; then
    echo "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

# Set the subscription
echo "📋 Setting subscription..."
az account set --subscription $SUBSCRIPTION_ID

# Create Resource Group
echo "📦 Creating resource group..."
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

# Create Storage Account
echo "💾 Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --sku Standard_LRS

# Create Application Insights
echo "📊 Creating Application Insights..."
az monitor app-insights component create \
  --app $APP_INSIGHTS_NAME \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP

# Get Application Insights key
INSIGHTS_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS_NAME \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Create Function App
echo "⚡ Creating Function App..."
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name $FUNCTION_APP_NAME \
  --storage-account $STORAGE_ACCOUNT \
  --app-insights $APP_INSIGHTS_NAME \
  --app-insights-key $INSIGHTS_KEY

# Configure Function App settings
echo "⚙️ Configuring Function App settings..."
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    GMAIL_CLIENT_ID="" \
    GMAIL_CLIENT_SECRET="" \
    GMAIL_REFRESH_TOKEN="" \
    GMAIL_USER_EMAIL="mabu.mate@gmail.com" \
    SLACK_TOKEN="" \
    SLACK_CHANNEL="gmail-inbox" \
    WEBSITE_NODE_DEFAULT_VERSION="~18"

# Check if Azure Functions Core Tools is installed
if ! command -v func &> /dev/null; then
    echo "⚠️  Azure Functions Core Tools not found."
    echo "   Please install it first:"
    echo "   brew tap azure/functions"
    echo "   brew install azure-functions-core-tools@4"
    echo "   Or: npm install -g azure-functions-core-tools@4"
    echo ""
    echo "   Skipping function deployment. You can deploy later with:"
    echo "   cd azure-functions && func azure functionapp publish $FUNCTION_APP_NAME"
else
    # Build and deploy the functions
    echo "🔨 Building Azure Functions..."
    cd azure-functions
    npm install

    echo "📤 Deploying to Azure..."
    func azure functionapp publish $FUNCTION_APP_NAME
    cd ..
fi

# Get Function App URL
FUNCTION_URL=$(az functionapp show \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --query defaultHostName -o tsv)

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Set up Gmail OAuth credentials:"
echo "      - Visit: https://$FUNCTION_URL/api/getAuthUrl"
echo "      - Follow the instructions to get OAuth tokens"
echo "   2. Update Function App settings with:"
echo "      - GMAIL_CLIENT_ID"
echo "      - GMAIL_CLIENT_SECRET" 
echo "      - GMAIL_REFRESH_TOKEN"
echo "      - SLACK_TOKEN"
echo "   3. Test the connection:"
echo "      - Visit: https://$FUNCTION_URL/api/testGmailConnection"
echo ""
echo "🔗 Azure Portal:"
echo "   https://portal.azure.com/#resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_APP_NAME"
echo ""
echo "📊 Monitor logs:"
echo "   func azure functionapp logstream $FUNCTION_APP_NAME"