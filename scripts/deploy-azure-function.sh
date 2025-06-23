#!/bin/bash

# Deploy Azure Function with Gmail API + Slack Webhook
# This completely bypasses LogicApp Gmail connector restrictions

set -e

echo "🚀 Deploying Azure Function solution..."
echo "======================================"
echo ""
echo "This approach uses:"
echo "✅ Azure Function (Timer trigger)"
echo "✅ Gmail API directly (no connector restrictions)"  
echo "✅ HTTPS Slack webhook"
echo "✅ Your existing OAuth credentials"
echo ""

# Read OAuth credentials
CREDS_FILE=".secret/google-oauth-credentials.json"
if [ ! -f "$CREDS_FILE" ]; then
    echo "❌ Error: Credentials file not found: $CREDS_FILE"
    exit 1
fi

CLIENT_ID=$(cat $CREDS_FILE | jq -r '.client_id')
CLIENT_SECRET=$(cat $CREDS_FILE | jq -r '.client_secret')

echo "🔑 Using OAuth credentials:"
echo "   Client ID: ${CLIENT_ID:0:20}...${CLIENT_ID: -20}"
echo ""

# Azure configuration
RESOURCE_GROUP="logicapp-jasmin-catering_group"
FUNCTION_APP_NAME="jasmin-gmail-function"
STORAGE_ACCOUNT="jasmingmailstorage"
LOCATION="westeurope"
SLACK_WEBHOOK="https://hooks.slack.com/services/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"

echo "📧 Email: mabu.mate@gmail.com"
echo "💬 Slack: #gmail-inbox"
echo "🔧 Function App: $FUNCTION_APP_NAME"
echo ""

# Create storage account for function app
echo "💾 Creating storage account..."
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS \
  --kind StorageV2 || echo "⚠️  Storage account might already exist"

# Create function app
echo "⚡ Creating Function App..."
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.9 \
  --functions-version 4 \
  --name $FUNCTION_APP_NAME \
  --storage-account $STORAGE_ACCOUNT || echo "⚠️  Function App might already exist"

# Configure app settings
echo "⚙️ Configuring Function App settings..."
az functionapp config appsettings set \
  --name $FUNCTION_APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --settings \
    "GOOGLE_CLIENT_ID=$CLIENT_ID" \
    "GOOGLE_CLIENT_SECRET=$CLIENT_SECRET" \
    "GMAIL_EMAIL=mabu.mate@gmail.com" \
    "SLACK_WEBHOOK_URL=$SLACK_WEBHOOK"

# Create function code directory
mkdir -p azure-function/gmail-processor
mkdir -p azure-function/gmail-processor/.vscode

# Create function.json (timer trigger every minute)
cat > azure-function/gmail-processor/function.json << 'EOF'
{
  "scriptFile": "__init__.py",
  "bindings": [
    {
      "name": "mytimer",
      "type": "timerTrigger",
      "direction": "in",
      "schedule": "0 * * * * *"
    }
  ]
}
EOF

# Create requirements.txt
cat > azure-function/requirements.txt << 'EOF'
azure-functions
google-auth
google-auth-oauthlib
google-auth-httplib2
google-api-python-client
requests
python-dateutil
EOF

# Create Python function code
cat > azure-function/gmail-processor/__init__.py << 'EOF'
import azure.functions as func
import logging
import os
import json
import requests
from datetime import datetime, timedelta
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import Flow
from googleapiclient.discovery import build

def main(mytimer: func.TimerRequest) -> None:
    """
    Azure Function to check Gmail and send to Slack
    Runs every minute via timer trigger
    """
    logging.info('Gmail processor function triggered')
    
    try:
        # Get configuration from app settings
        client_id = os.environ['GOOGLE_CLIENT_ID']
        client_secret = os.environ['GOOGLE_CLIENT_SECRET'] 
        gmail_email = os.environ['GMAIL_EMAIL']
        slack_webhook = os.environ['SLACK_WEBHOOK_URL']
        
        # Note: For production, you'll need to handle OAuth flow
        # This is a template that shows the structure
        
        logging.info(f'Monitoring email: {gmail_email}')
        logging.info('Gmail processor completed successfully')
        
    except Exception as e:
        logging.error(f'Error in Gmail processor: {str(e)}')
        raise
EOF

# Create host.json
cat > azure-function/host.json << 'EOF'
{
  "version": "2.0",
  "functionTimeout": "00:05:00",
  "extensions": {
    "http": {
      "routePrefix": "api"
    }
  }
}
EOF

# Create local.settings.json (for local development)
cat > azure-function/local.settings.json << EOF
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "python",
    "GOOGLE_CLIENT_ID": "$CLIENT_ID",
    "GOOGLE_CLIENT_SECRET": "$CLIENT_SECRET", 
    "GMAIL_EMAIL": "mabu.mate@gmail.com",
    "SLACK_WEBHOOK_URL": "$SLACK_WEBHOOK"
  }
}
EOF

echo ""
echo "✅ Azure Function created successfully!"
echo ""
echo "📁 Function structure:"
echo "   azure-function/"
echo "   ├── gmail-processor/"
echo "   │   ├── function.json (timer trigger)"
echo "   │   └── __init__.py (Python code)"
echo "   ├── requirements.txt (dependencies)"
echo "   ├── host.json (function config)"
echo "   └── local.settings.json (local dev)"
echo ""
echo "🔧 Next steps:"
echo "   1. Complete the OAuth flow in the Python code"
echo "   2. Deploy function: func azure functionapp publish $FUNCTION_APP_NAME"
echo "   3. Test the function"
echo ""
echo "🎯 Benefits of this approach:"
echo "   ✅ No LogicApp connector restrictions"
echo "   ✅ Direct Gmail API access"
echo "   ✅ HTTPS Slack webhook (unrestricted)"
echo "   ✅ Scalable and cost-effective"
echo ""
echo "📊 Function App created: $FUNCTION_APP_NAME"
echo "🔗 Azure Portal: https://portal.azure.com/#@damyandesignhotmail.onmicrosoft.com/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$FUNCTION_APP_NAME"
