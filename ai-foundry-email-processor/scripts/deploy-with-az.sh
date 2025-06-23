#!/bin/bash

# Load configuration
source "$(dirname "$0")/load-env-config.sh"

echo "🚀 Deploying with Azure CLI (az)"
echo "================================"

# Login check
echo "Checking Azure login status..."
if ! az account show &>/dev/null; then
    echo "Please login to Azure:"
    az login
fi

# Set subscription
echo "Setting subscription..."
az account set --subscription $AZURE_SUBSCRIPTION_ID

# 1. Create storage account for email drafts (if needed)
echo ""
echo "📦 Setting up Storage Account..."
STORAGE_ACCOUNT_NAME="jasmincateringstorage"
if ! az storage account show --name $STORAGE_ACCOUNT_NAME --resource-group $AZURE_RESOURCE_GROUP &>/dev/null; then
    echo "Creating storage account..."
    az storage account create \
        --name $STORAGE_ACCOUNT_NAME \
        --resource-group $AZURE_RESOURCE_GROUP \
        --location $AZURE_LOCATION \
        --sku Standard_LRS \
        --kind StorageV2
    
    # Create container for email drafts
    az storage container create \
        --name email-drafts \
        --account-name $STORAGE_ACCOUNT_NAME \
        --auth-mode login
else
    echo "✅ Storage account already exists"
fi

# 2. Deploy Logic App (Consumption)
echo ""
echo "🔄 Deploying Logic App..."
LOGIC_APP_NAME="jasmin-order-processor"

# Check if it exists
if ! az logic workflow show --resource-group $AZURE_RESOURCE_GROUP --name $LOGIC_APP_NAME &>/dev/null; then
    echo "Creating new Logic App workflow..."
    
    # Create parameters file with actual values
    cat > temp-parameters.json <<EOF
{
    "workflows_jasmin_order_processor_name": {
        "value": "$LOGIC_APP_NAME"
    },
    "ai_endpoint": {
        "value": "$AZURE_AI_ENDPOINT"
    },
    "ai_api_key": {
        "value": "$AZURE_AI_API_KEY"
    },
    "email_alias": {
        "value": "$WEBDE_EMAIL_ALIAS"
    },
    "email_password": {
        "value": "$WEBDE_APP_PASSWORD"
    }
}
EOF

    # Deploy using ARM template
    az deployment group create \
        --resource-group $AZURE_RESOURCE_GROUP \
        --template-file ../templates/logic-app-template.json \
        --parameters @temp-parameters.json
    
    rm -f temp-parameters.json
else
    echo "✅ Logic App already exists"
fi

# 3. Create API Connections using az rest
echo ""
echo "🔌 Creating API Connections..."

# IMAP Connection
echo "Creating IMAP connection..."
az rest --method put \
    --uri "https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Web/connections/webde-imap-connection?api-version=2016-06-01" \
    --body '{
        "location": "'$AZURE_LOCATION'",
        "properties": {
            "api": {
                "id": "/subscriptions/'$AZURE_SUBSCRIPTION_ID'/providers/Microsoft.Web/locations/'$AZURE_LOCATION'/managedApis/imap"
            },
            "displayName": "Web.de IMAP Connection",
            "parameterValues": {
                "serverAddress": "'$WEBDE_IMAP_SERVER'",
                "serverPort": "'$WEBDE_IMAP_PORT'",
                "enableSsl": true,
                "username": "'$WEBDE_EMAIL_ALIAS'",
                "password": "'$WEBDE_APP_PASSWORD'"
            }
        }
    }'

# Storage Connection
echo "Creating Storage connection..."
STORAGE_KEY=$(az storage account keys list --account-name $STORAGE_ACCOUNT_NAME --resource-group $AZURE_RESOURCE_GROUP --query '[0].value' -o tsv)
az rest --method put \
    --uri "https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Web/connections/storage-connection?api-version=2016-06-01" \
    --body '{
        "location": "'$AZURE_LOCATION'",
        "properties": {
            "api": {
                "id": "/subscriptions/'$AZURE_SUBSCRIPTION_ID'/providers/Microsoft.Web/locations/'$AZURE_LOCATION'/managedApis/azureblob"
            },
            "displayName": "Azure Storage Connection",
            "parameterValues": {
                "accountName": "'$STORAGE_ACCOUNT_NAME'",
                "accessKey": "'$STORAGE_KEY'"
            }
        }
    }'

# 4. Get deployment outputs
echo ""
echo "📋 Deployment Summary:"
echo "====================="
echo "Logic App: $LOGIC_APP_NAME"
echo "Resource Group: $AZURE_RESOURCE_GROUP"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo ""
echo "🔗 Direct Links:"
echo "Logic App Designer: https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME/designer"
echo "API Connections: https://portal.azure.com/#blade/HubsExtension/BrowseResource/resourceType/Microsoft.Web%2Fconnections"
echo ""
echo "✅ Deployment complete! Next steps:"
echo "1. Open Logic App Designer"
echo "2. Update the workflow with your AI endpoint"
echo "3. Authorize connections if needed"
echo "4. Test with an email to $WEBDE_EMAIL_ALIAS"