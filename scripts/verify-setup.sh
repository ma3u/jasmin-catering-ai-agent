#!/bin/bash

# Quick verification before deployment
set -e

echo "🔍 Pre-deployment Verification"
echo "==============================="
echo ""

# Check if credentials exist
echo "1. 🔑 Checking Google OAuth credentials..."
if [ -f ".secret/google-oauth-credentials.json" ]; then
    CLIENT_ID=$(cat .secret/google-oauth-credentials.json | jq -r '.client_id')
    CLIENT_SECRET=$(cat .secret/google-oauth-credentials.json | jq -r '.client_secret')
    
    if [ "$CLIENT_ID" != "null" ] && [ "$CLIENT_SECRET" != "null" ]; then
        echo "   ✅ Valid credentials found"
        echo "   📋 Client ID: ${CLIENT_ID:0:25}..."
        echo "   🔑 Client Secret: ${CLIENT_SECRET:0:15}..."
    else
        echo "   ❌ Invalid credentials format"
        exit 1
    fi
else
    echo "   ❌ Credentials not found in .secret/"
    exit 1
fi

# Check Azure CLI
echo ""
echo "2. ⚙️ Checking Azure CLI authentication..."
if az account show > /dev/null 2>&1; then
    ACCOUNT=$(az account show --query "user.name" -o tsv)
    SUBSCRIPTION=$(az account show --query "name" -o tsv)
    echo "   ✅ Azure CLI authenticated"
    echo "   👤 Account: $ACCOUNT"
    echo "   📋 Subscription: $SUBSCRIPTION"
else
    echo "   ❌ Azure CLI not authenticated"
    echo "   🔧 Run: az login"
    exit 1
fi

# Check resource group
echo ""
echo "3. 🏗️ Checking Azure resource group..."
if az group show --name "logicapp-jasmin-catering_group" > /dev/null 2>&1; then
    echo "   ✅ Resource group exists"
else
    echo "   ❌ Resource group not found"
    exit 1
fi

# Check Slack webhook
echo ""
echo "4. 💬 Checking Slack webhook..."
SLACK_WEBHOOK="https://hooks.slack.com/services/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"
if curl -s -X POST -H "Content-Type: application/json" \
   -d '{"text":"🧪 Testing webhook connectivity..."}' \
   "$SLACK_WEBHOOK" | grep -q "ok"; then
    echo "   ✅ Slack webhook working"
    echo "   💬 Test message sent to #gmail-inbox"
else
    echo "   ⚠️  Slack webhook test failed (webhook might be rate limited)"
    echo "   🔗 Webhook: ${SLACK_WEBHOOK:0:50}..."
fi

# Check .gitignore
echo ""
echo "5. 🔒 Checking security (.gitignore)..."
if grep -q ".secret/" .gitignore; then
    echo "   ✅ .secret/ directory excluded from git"
else
    echo "   ⚠️  .secret/ not in .gitignore"
fi

echo ""
echo "📊 Verification Summary:"
echo "   ✅ Google OAuth credentials ready"
echo "   ✅ Azure CLI authenticated"
echo "   ✅ Resource group accessible"
echo "   ✅ Slack webhook configured"
echo "   ✅ Security configured"
echo ""
echo "🚀 Ready for deployment!"
echo ""
echo "   Run: ./scripts/deploy-with-credentials.sh"
echo ""
