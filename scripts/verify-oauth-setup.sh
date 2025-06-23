#!/bin/bash

# Verify OAuth Setup and Deploy
# Security check before deployment

set -e

echo "🔍 Verifying OAuth Setup..."
echo "=============================="
echo ""

# Check if credentials exist
if [ ! -f ".secret/google-oauth-credentials.json" ]; then
    echo "❌ Credentials file not found"
    exit 1
fi

# Check .gitignore protection
if ! grep -q ".secret/" .gitignore; then
    echo "❌ .secret/ not protected in .gitignore"
    exit 1
fi

# Verify credentials format
CLIENT_ID=$(cat .secret/google-oauth-credentials.json | jq -r '.client_id' 2>/dev/null || echo "null")
CLIENT_SECRET=$(cat .secret/google-oauth-credentials.json | jq -r '.client_secret' 2>/dev/null || echo "null")

if [ "$CLIENT_ID" = "null" ] || [ "$CLIENT_SECRET" = "null" ]; then
    echo "❌ Invalid credentials format"
    exit 1
fi

echo "✅ Credentials file: .secret/google-oauth-credentials.json"
echo "✅ Client ID: ${CLIENT_ID:0:20}...${CLIENT_ID: -20}"
echo "✅ Client Secret: ${CLIENT_SECRET:0:10}...${CLIENT_SECRET: -10}"
echo "✅ Security: .secret/ protected from Git"
echo ""

# Check Azure CLI
if ! az account show > /dev/null 2>&1; then
    echo "❌ Azure CLI not authenticated"
    echo "🔧 Run: az login"
    exit 1
fi

echo "✅ Azure CLI: Authenticated"

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ jq not installed"
    echo "🔧 Run: brew install jq"
    exit 1
fi

echo "✅ Dependencies: jq available"
echo ""

echo "🎯 Ready for deployment!"
echo ""
echo "🚀 Run deployment:"
echo "   ./scripts/deploy-with-oauth.sh"
echo ""
