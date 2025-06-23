#!/bin/bash

echo "🔍 Jasmin Catering Azure Functions Configuration Status"
echo "===================================================="
echo ""

# Load environment variables
source .env 2>/dev/null || true

# Function to check if a value is set and not a placeholder
check_var() {
    local var_name=$1
    local var_value=$2
    local is_optional=$3
    
    if [ -z "$var_value" ] || [[ "$var_value" == *"your-"* ]] || [[ "$var_value" == *"YOUR_"* ]]; then
        if [ "$is_optional" == "true" ]; then
            echo "ℹ️  $var_name: Not set (optional)"
        else
            echo "❌ $var_name: Not set (required)"
        fi
        return 1
    else
        echo "✅ $var_name: ${var_value:0:20}..."
        return 0
    fi
}

echo "📧 Gmail Configuration:"
check_var "GMAIL_CLIENT_ID" "$GMAIL_CLIENT_ID"
check_var "GMAIL_CLIENT_SECRET" "$GMAIL_CLIENT_SECRET"
check_var "GMAIL_REFRESH_TOKEN" "$GMAIL_REFRESH_TOKEN"
gmail_token_set=$?
check_var "GMAIL_USER_EMAIL" "$GMAIL_USER_EMAIL"

echo ""
echo "💬 Slack Configuration:"
check_var "SLACK_TOKEN" "$SLACK_TOKEN"
slack_token_set=$?
check_var "SLACK_CHANNEL" "$SLACK_CHANNEL"

echo ""
echo "☁️  Azure Configuration:"
check_var "AZURE_STORAGE_CONNECTION_STRING" "$AZURE_STORAGE_CONNECTION_STRING" true

echo ""
echo "📋 Summary:"
echo "-----------"

if [ $gmail_token_set -ne 0 ] || [ $slack_token_set -ne 0 ]; then
    echo "⚠️  Some required configurations are missing!"
    echo ""
    
    if [ $gmail_token_set -ne 0 ]; then
        echo "🔐 To get Gmail Refresh Token:"
        echo "   1. Go to: https://developers.google.com/oauthplayground"
        echo "   2. Configure OAuth with your credentials"
        echo "   3. Select Gmail API scopes"
        echo "   4. Get the refresh token"
        echo "   5. Add to .env: GMAIL_REFRESH_TOKEN=your_token"
        echo ""
    fi
    
    if [ $slack_token_set -ne 0 ]; then
        echo "💬 To get Slack Token:"
        echo "   1. Go to: https://api.slack.com/apps"
        echo "   2. Create new app for workspace: mabured.slack.com"
        echo "   3. Add bot scopes: chat:write, chat:write.public"
        echo "   4. Install to workspace"
        echo "   5. Copy Bot User OAuth Token (xoxb-...)"
        echo "   6. Add to .env: SLACK_TOKEN=xoxb-your-token"
        echo ""
    fi
    
    echo "📝 After adding tokens, run: ./deploy-with-env.sh"
else
    echo "✅ All required configurations are set!"
    echo ""
    echo "🚀 Ready to deploy! Run: ./deploy-with-env.sh"
fi

echo ""
echo "🔗 Useful Links:"
echo "   OAuth Playground: https://developers.google.com/oauthplayground"
echo "   Slack Apps: https://api.slack.com/apps"
echo "   Azure Portal: https://portal.azure.com/#@/resource/subscriptions/b58b1820-35f0-4271-99be-7c84d4dd40f3/resourceGroups/jasmin-functions-rg/providers/Microsoft.Web/sites/jasmin-gmail-functions/configuration"