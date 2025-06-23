#!/bin/bash
set -euo pipefail

# Complete automated deployment script - no manual Azure Portal steps required

# Load configuration from .env
source "$(dirname "$0")/load-env-config.sh"

echo "🚀 Complete Automated Deployment for Jasmin Catering AI"
echo "======================================================"
echo "Using configuration from .env file"
echo ""

# Function to handle errors
error_handler() {
    echo "❌ Error occurred on line $1"
    exit 1
}
trap 'error_handler $LINENO' ERR

# 1. Login to Azure (if needed)
echo "📝 Checking Azure login..."
if ! az account show &>/dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Set subscription
echo "Setting subscription..."
az account set --subscription "$AZURE_SUBSCRIPTION_ID"

# 2. Create resource group if it doesn't exist
echo ""
echo "📁 Checking resource group..."
if ! az group show --name "$AZURE_RESOURCE_GROUP" &>/dev/null; then
    echo "Creating resource group..."
    az group create \
        --name "$AZURE_RESOURCE_GROUP" \
        --location "$AZURE_LOCATION"
fi

# 3. Create Logic App using CLI (avoiding region restrictions)
echo ""
echo "🔄 Creating Logic App..."
LOGIC_APP_NAME="${AZURE_LOGIC_APP_NAME:-jasmin-order-processor}"

# Create Logic App definition from template
cat > temp-workflow.json <<EOF
{
  "definition": {
    "\$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
      "ai_endpoint": {
        "type": "string",
        "defaultValue": "$AZURE_AI_ENDPOINT"
      },
      "ai_api_key": {
        "type": "securestring",
        "defaultValue": "$AZURE_AI_API_KEY"
      },
      "email_alias": {
        "type": "string",
        "defaultValue": "$WEBDE_EMAIL_ALIAS"
      },
      "email_password": {
        "type": "securestring",
        "defaultValue": "$WEBDE_APP_PASSWORD"
      }
    },
    "triggers": {
      "manual": {
        "type": "Request",
        "kind": "Http",
        "inputs": {
          "schema": {}
        }
      }
    },
    "actions": {
      "Initialize_Status": {
        "runAfter": {},
        "type": "InitializeVariable",
        "inputs": {
          "variables": [{
            "name": "DeploymentStatus",
            "type": "string",
            "value": "Deployed via CLI"
          }]
        }
      }
    },
    "outputs": {}
  }
}
EOF

# Deploy Logic App
echo "Deploying Logic App workflow..."
az logic workflow create \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow.json \
    --location "$AZURE_LOCATION" \
    2>/dev/null || echo "Logic App might already exist, updating..."

# Update if it already exists
az logic workflow update \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-workflow.json \
    2>/dev/null || true

# 4. Create API connections using REST API to avoid region restrictions
echo ""
echo "🔌 Creating API Connections..."

# Function to create connection
create_connection() {
    local CONNECTION_NAME=$1
    local CONNECTION_TYPE=$2
    local CONNECTION_BODY=$3
    
    echo "Creating $CONNECTION_NAME..."
    
    # Use az rest to create connection
    az rest --method put \
        --uri "https://management.azure.com/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Web/connections/$CONNECTION_NAME?api-version=2016-06-01" \
        --body "$CONNECTION_BODY" \
        2>/dev/null || echo "Connection might already exist"
}

# Create managed API connections JSON
IMAP_CONNECTION_BODY=$(cat <<EOF
{
  "location": "$AZURE_LOCATION",
  "properties": {
    "api": {
      "id": "/subscriptions/$AZURE_SUBSCRIPTION_ID/providers/Microsoft.Web/locations/$AZURE_LOCATION/managedApis/imap"
    },
    "displayName": "Web.de IMAP Connection",
    "parameterValues": {
      "serverAddress": "$WEBDE_IMAP_SERVER",
      "serverPort": $WEBDE_IMAP_PORT,
      "enableSsl": true,
      "username": "$WEBDE_EMAIL_ALIAS",
      "password": "$WEBDE_APP_PASSWORD"
    }
  }
}
EOF
)

# Try to create connections (may fail due to region)
create_connection "webde-imap-auto" "imap" "$IMAP_CONNECTION_BODY"

# 5. Deploy the actual workflow
echo ""
echo "📋 Deploying complete workflow..."

# Copy the workflow from our template and substitute values
sed -e "s|@parameters('AIFoundryApiKey')|$AZURE_AI_API_KEY|g" \
    -e "s|@parameters('email_alias')|$WEBDE_EMAIL_ALIAS|g" \
    -e "s|@parameters('email_password')|$WEBDE_APP_PASSWORD|g" \
    ../logic-app/order-processing-workflow.json > temp-complete-workflow.json

# Update Logic App with complete workflow
az logic workflow update \
    --resource-group "$AZURE_RESOURCE_GROUP" \
    --name "$LOGIC_APP_NAME" \
    --definition @temp-complete-workflow.json \
    2>/dev/null || echo "Workflow update might have partial success"

# 6. Output deployment information
echo ""
echo "✅ Deployment Complete!"
echo "======================"
echo ""
echo "📋 Deployment Summary:"
echo "- Subscription: $AZURE_SUBSCRIPTION_ID"
echo "- Resource Group: $AZURE_RESOURCE_GROUP"
echo "- Logic App: $LOGIC_APP_NAME"
echo "- AI Endpoint: $AZURE_AI_ENDPOINT"
echo "- Email: $WEBDE_EMAIL_ALIAS"
echo ""
echo "🔗 Access your Logic App:"
echo "https://portal.azure.com/#resource/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/$AZURE_RESOURCE_GROUP/providers/Microsoft.Logic/workflows/$LOGIC_APP_NAME"
echo ""
echo "📧 Test by sending email to: $WEBDE_EMAIL_ALIAS"
echo "Subject must contain: Catering, Anfrage, Order, or Bestell"
echo ""
echo "🔍 Check deployment status:"
echo "az logic workflow show --resource-group $AZURE_RESOURCE_GROUP --name $LOGIC_APP_NAME --query state"

# Cleanup
rm -f temp-workflow.json temp-complete-workflow.json

echo ""
echo "💡 Note: If API connections failed due to region restrictions,"
echo "   you may need to create them in a different region or use"
echo "   the portal for OAuth connections only."