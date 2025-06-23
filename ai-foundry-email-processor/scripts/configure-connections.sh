#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🔌 Configuring API Connections for Order Processing..."
echo "====================================================="

# Set Azure subscription
az account set --subscription $AZURE_SUBSCRIPTION_ID

# Function to create or update API connection
create_api_connection() {
    local CONNECTION_NAME=$1
    local API_ID=$2
    local PARAMETERS=$3
    
    echo "Creating connection: $CONNECTION_NAME"
    
    # Check if connection exists
    if az resource show \
        --resource-group $AZURE_RESOURCE_GROUP \
        --resource-type "Microsoft.Web/connections" \
        --name $CONNECTION_NAME &>/dev/null; then
        echo "Connection $CONNECTION_NAME already exists, updating..."
        ACTION="update"
    else
        echo "Creating new connection $CONNECTION_NAME..."
        ACTION="create"
    fi
    
    # Create/update the connection
    az resource create \
        --resource-group $AZURE_RESOURCE_GROUP \
        --resource-type "Microsoft.Web/connections" \
        --name $CONNECTION_NAME \
        --api-version "2016-06-01" \
        --location $AZURE_LOCATION \
        --properties "{
            \"api\": {
                \"id\": \"$API_ID\"
            },
            \"parameterValues\": $PARAMETERS
        }"
}

# 1. Web.de IMAP Connection
echo ""
echo "1️⃣ Setting up web.de email connection..."
WEBDE_API_ID="/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/imap"

# Use the web.de alias and app password from .env
WEBDE_PARAMS='{
    "serverAddress": "'$WEBDE_IMAP_SERVER'",
    "serverPort": '$WEBDE_IMAP_PORT',
    "enableSsl": true,
    "username": "'$WEBDE_EMAIL_ALIAS'",
    "password": "'$WEBDE_APP_PASSWORD'"
}'

create_api_connection "webde-imap-connection" "$WEBDE_API_ID" "$WEBDE_PARAMS"

# 2. Azure Blob Storage Connection
echo ""
echo "2️⃣ Setting up Azure Storage connection..."
STORAGE_API_ID="/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/azureblob"

# Note: You'll need to provide storage account details
STORAGE_PARAMS='{
    "accountName": "jasmincateringstorage"
}'

create_api_connection "storage-connection" "$STORAGE_API_ID" "$STORAGE_PARAMS"

# 3. Teams Connection
echo ""
echo "3️⃣ Setting up Microsoft Teams connection..."
TEAMS_API_ID="/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/teams"
TEAMS_PARAMS='{}'

create_api_connection "teams-connection" "$TEAMS_API_ID" "$TEAMS_PARAMS"

# 4. Application Insights Connection (optional)
echo ""
echo "4️⃣ Setting up Application Insights connection..."
APPINSIGHTS_API_ID="/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/applicationinsights"
APPINSIGHTS_PARAMS='{}'

create_api_connection "appinsights-connection" "$APPINSIGHTS_API_ID" "$APPINSIGHTS_PARAMS"

echo ""
echo "✅ API connections configured!"
echo ""
echo "⚠️  IMPORTANT: Manual steps required:"
echo "1. Go to Azure Portal > Logic Apps > API Connections"
echo "2. For each connection, click 'Edit API connection'"
echo "3. Authorize with your credentials:"
echo "   - web.de: Enter your app-specific password"
echo "   - Teams: Sign in with your Microsoft account"
echo "   - Storage: Connection should auto-configure with managed identity"
echo ""
echo "Portal link: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fconnections"