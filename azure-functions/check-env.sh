#!/bin/bash

# Check .env file status
echo "🔍 Checking .env file configuration"
echo "==================================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo ""
    echo "Creating .env from template..."
    cp .env.template .env
    echo "✅ Created .env file. Please edit it with your values."
    exit 1
fi

# Load and check variables
source .env

echo "📋 Environment Variables Status:"
echo ""

# Gmail credentials
if [ -n "$GMAIL_CLIENT_ID" ] && [ "$GMAIL_CLIENT_ID" != "your-client-id-here" ]; then
    echo "✅ GMAIL_CLIENT_ID: ${GMAIL_CLIENT_ID:0:20}..."
else
    echo "❌ GMAIL_CLIENT_ID: Not set"
fi

if [ -n "$GMAIL_CLIENT_SECRET" ] && [ "$GMAIL_CLIENT_SECRET" != "your-client-secret-here" ]; then
    echo "✅ GMAIL_CLIENT_SECRET: ${GMAIL_CLIENT_SECRET:0:10}..."
else
    echo "❌ GMAIL_CLIENT_SECRET: Not set"
fi

if [ -n "$GMAIL_REFRESH_TOKEN" ] && [ "$GMAIL_REFRESH_TOKEN" != "your-refresh-token-here" ]; then
    echo "✅ GMAIL_REFRESH_TOKEN: ${GMAIL_REFRESH_TOKEN:0:10}..."
else
    echo "⚠️  GMAIL_REFRESH_TOKEN: Not set (get from OAuth playground)"
fi

echo "✅ GMAIL_USER_EMAIL: $GMAIL_USER_EMAIL"

# Slack configuration
if [ -n "$SLACK_TOKEN" ] && [ "$SLACK_TOKEN" != "xoxb-your-slack-bot-token" ]; then
    echo "✅ SLACK_TOKEN: ${SLACK_TOKEN:0:15}..."
else
    echo "⚠️  SLACK_TOKEN: Not set (get from Slack API)"
fi

echo "✅ SLACK_CHANNEL: $SLACK_CHANNEL"

# Azure Storage (optional)
if [ -n "$AZURE_STORAGE_CONNECTION_STRING" ]; then
    echo "✅ AZURE_STORAGE_CONNECTION_STRING: Configured"
else
    echo "ℹ️  AZURE_STORAGE_CONNECTION_STRING: Not set (optional - will use in-memory state)"
fi

echo ""
echo "📝 Next Steps:"
echo ""

if [ -z "$GMAIL_REFRESH_TOKEN" ] || [ "$GMAIL_REFRESH_TOKEN" == "your-refresh-token-here" ]; then
    echo "1. Get Gmail Refresh Token:"
    echo "   ./setup-gmail-oauth.sh"
    echo ""
fi

if [ -z "$SLACK_TOKEN" ] || [ "$SLACK_TOKEN" == "xoxb-your-slack-bot-token" ]; then
    echo "2. Get Slack Token:"
    echo "   ./setup-slack-quickstart.sh"
    echo ""
fi

echo "3. Deploy to Azure:"
echo "   ./deploy-with-env.sh"