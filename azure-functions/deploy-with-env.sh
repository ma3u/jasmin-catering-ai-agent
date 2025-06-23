#!/bin/bash

# Deploy Azure Functions with environment variables
echo "🚀 Deploying Azure Functions with Environment Variables"
echo "===================================================="

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please create a .env file with your credentials."
    exit 1
fi

# Load environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check required variables
if [ -z "$GMAIL_CLIENT_ID" ] || [ -z "$GMAIL_CLIENT_SECRET" ]; then
    echo "❌ Error: Gmail credentials not found in .env file!"
    exit 1
fi

echo "📋 Found credentials:"
echo "   Gmail Client ID: ${GMAIL_CLIENT_ID:0:20}..."
echo "   Slack Token: ${SLACK_TOKEN:+[CONFIGURED]}"
echo "   Refresh Token: ${GMAIL_REFRESH_TOKEN:+[CONFIGURED]}"

# Update Azure Function App Settings
echo ""
echo "⚙️ Updating Azure Function settings..."
az functionapp config appsettings set \
  --name jasmin-gmail-functions \
  --resource-group jasmin-functions-rg \
  --settings \
    "GMAIL_CLIENT_ID=$GMAIL_CLIENT_ID" \
    "GMAIL_CLIENT_SECRET=$GMAIL_CLIENT_SECRET" \
    "GMAIL_REFRESH_TOKEN=$GMAIL_REFRESH_TOKEN" \
    "GMAIL_USER_EMAIL=$GMAIL_USER_EMAIL" \
    "SLACK_TOKEN=$SLACK_TOKEN" \
    "SLACK_CHANNEL=$SLACK_CHANNEL" \
  --output none

echo "✅ Settings updated!"

# Check if Azure Functions Core Tools is installed
if ! command -v func &> /dev/null; then
    echo ""
    echo "⚠️  Azure Functions Core Tools not installed!"
    echo "Install with: brew install azure-functions-core-tools@4"
    echo ""
    echo "Skipping code deployment. To deploy manually:"
    echo "  npm install"
    echo "  func azure functionapp publish jasmin-gmail-functions"
    exit 0
fi

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Deploy the function app
echo ""
echo "📤 Deploying function code..."
func azure functionapp publish jasmin-gmail-functions

echo ""
echo "✅ Deployment complete!"
echo ""
echo "🔗 Test your functions:"
echo "   Auth URL: https://jasmin-gmail-functions.azurewebsites.net/api/getAuthUrl"
echo "   Test Connection: https://jasmin-gmail-functions.azurewebsites.net/api/testGmailConnection"
echo ""

# Check if refresh token is missing
if [ -z "$GMAIL_REFRESH_TOKEN" ]; then
    echo "⚠️  GMAIL_REFRESH_TOKEN is not set!"
    echo "   1. Visit the Auth URL above"
    echo "   2. Follow the OAuth flow to get a refresh token"
    echo "   3. Add it to your .env file"
    echo "   4. Run this script again"
fi

# Check if Slack token is missing  
if [ -z "$SLACK_TOKEN" ]; then
    echo ""
    echo "⚠️  SLACK_TOKEN is not set!"
    echo "   1. Create a Slack app at: https://api.slack.com/apps"
    echo "   2. Get the Bot User OAuth Token"
    echo "   3. Add it to your .env file"
    echo "   4. Run this script again"
fi