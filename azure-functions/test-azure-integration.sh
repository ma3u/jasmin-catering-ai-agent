#!/bin/bash

# Test Azure Functions Integration for Jasmin Catering
echo "🧪 Testing Azure Functions Integration"
echo "====================================="

# Configuration
FUNCTION_APP_URL="https://jasmin-gmail-functions.azurewebsites.net"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function test_endpoint() {
    local endpoint=$1
    local description=$2
    
    echo -e "\n📡 Testing: $description"
    echo "URL: $FUNCTION_APP_URL$endpoint"
    
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$FUNCTION_APP_URL$endpoint")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
    
    if [ "$http_code" -eq 200 ]; then
        echo -e "${GREEN}✅ Success (HTTP $http_code)${NC}"
        echo "Response: $body" | jq '.' 2>/dev/null || echo "Response: $body"
    elif [ "$http_code" -eq 401 ] || [ "$http_code" -eq 403 ]; then
        echo -e "${YELLOW}⚠️  Authentication needed (HTTP $http_code)${NC}"
        echo "Response: $body"
    else
        echo -e "${RED}❌ Failed (HTTP $http_code)${NC}"
        echo "Response: $body"
    fi
}

function test_gmail_connection() {
    echo -e "\n📧 Testing Gmail Connection..."
    test_endpoint "/api/testGmailConnection" "Gmail API Connection"
}

function test_auth_setup() {
    echo -e "\n🔐 Testing OAuth Setup..."
    test_endpoint "/api/getAuthUrl" "OAuth Authorization URL"
}

function trigger_gmail_monitor() {
    echo -e "\n⏰ Testing Gmail Monitor Function..."
    echo "Attempting to trigger gmailMonitor function manually..."
    
    # This requires the master key - for testing, we'll just check if the function exists
    response=$(curl -s -w "HTTPSTATUS:%{http_code}" "$FUNCTION_APP_URL/api/gmailMonitor")
    http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    
    if [ "$http_code" -eq 405 ]; then
        echo -e "${GREEN}✅ Function exists (HTTP $http_code - Method not allowed is expected)${NC}"
    elif [ "$http_code" -eq 404 ]; then
        echo -e "${RED}❌ Function not found (HTTP $http_code)${NC}"
    else
        echo -e "${YELLOW}⚠️  Unexpected response (HTTP $http_code)${NC}"
    fi
}

function test_slack_credentials() {
    echo -e "\n📱 Testing Slack Credentials..."
    
    if [ -z "$SLACK_TOKEN" ]; then
        echo -e "${RED}❌ SLACK_TOKEN environment variable not set${NC}"
        echo "Please set: export SLACK_TOKEN=xoxb-your-token"
        return 1
    fi
    
    if [[ $SLACK_TOKEN == xoxb-* ]]; then
        echo -e "${GREEN}✅ SLACK_TOKEN format looks correct${NC}"
        echo "Token: ${SLACK_TOKEN:0:15}..."
    else
        echo -e "${RED}❌ SLACK_TOKEN should start with 'xoxb-'${NC}"
        return 1
    fi
    
    # Test Slack API directly
    echo "Testing Slack API connection..."
    slack_response=$(curl -s -H "Authorization: Bearer $SLACK_TOKEN" \
                          -H "Content-Type: application/json" \
                          "https://slack.com/api/auth.test")
    
    if echo "$slack_response" | jq -e '.ok == true' > /dev/null 2>&1; then
        team_name=$(echo "$slack_response" | jq -r '.team // "Unknown"')
        user_name=$(echo "$slack_response" | jq -r '.user // "Unknown"')
        echo -e "${GREEN}✅ Slack API connection successful${NC}"
        echo "Team: $team_name, Bot: $user_name"
    else
        echo -e "${RED}❌ Slack API connection failed${NC}"
        echo "Response: $slack_response"
    fi
}

function send_test_slack_message() {
    echo -e "\n💬 Testing Slack Message Sending..."
    
    if [ -z "$SLACK_TOKEN" ]; then
        echo -e "${RED}❌ SLACK_TOKEN not set - skipping Slack message test${NC}"
        return 1
    fi
    
    channel="${SLACK_CHANNEL:-gmail-inbox}"
    message="🧪 Test from Azure Functions Integration Test - $(date)"
    
    slack_response=$(curl -s -X POST \
                          -H "Authorization: Bearer $SLACK_TOKEN" \
                          -H "Content-Type: application/json" \
                          -d "{\"channel\":\"$channel\",\"text\":\"$message\"}" \
                          "https://slack.com/api/chat.postMessage")
    
    if echo "$slack_response" | jq -e '.ok == true' > /dev/null 2>&1; then
        message_ts=$(echo "$slack_response" | jq -r '.ts // "Unknown"')
        echo -e "${GREEN}✅ Test message sent successfully${NC}"
        echo "Message timestamp: $message_ts"
        echo "Check #$channel in your Slack workspace"
    else
        error=$(echo "$slack_response" | jq -r '.error // "Unknown error"')
        echo -e "${RED}❌ Failed to send test message${NC}"
        echo "Error: $error"
        
        if [ "$error" = "channel_not_found" ]; then
            echo -e "${YELLOW}💡 Make sure bot is added to #$channel channel${NC}"
            echo "In Slack, type: /invite @YasminCatering"
        fi
    fi
}

function check_azure_function_logs() {
    echo -e "\n📊 Checking Azure Function Status..."
    
    # Check if Azure CLI is installed
    if ! command -v az &> /dev/null; then
        echo -e "${YELLOW}⚠️  Azure CLI not installed - skipping log check${NC}"
        echo "Install with: brew install azure-cli"
        return 1
    fi
    
    # Check if logged in
    if ! az account show &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not logged into Azure CLI - skipping log check${NC}"
        echo "Login with: az login"
        return 1
    fi
    
    echo "Checking function app status..."
    az functionapp show \
        --name jasmin-gmail-functions \
        --resource-group jasmin-functions-rg \
        --query '{name:name,state:state,location:location,kind:kind}' \
        --output table 2>/dev/null || echo "Function app not found or access denied"
}

# Main test execution
echo "Starting comprehensive Azure Functions integration test..."
echo "Function App: $FUNCTION_APP_URL"
echo "Slack Channel: ${SLACK_CHANNEL:-gmail-inbox}"
echo "Current Time: $(date)"

# Run all tests
test_gmail_connection
test_auth_setup
trigger_gmail_monitor
test_slack_credentials
send_test_slack_message
check_azure_function_logs

echo -e "\n🎯 Test Summary"
echo "==============="
echo "1. Gmail Connection: Check the response above"
echo "2. OAuth Setup: Should return authorization URL"
echo "3. Function Deployment: Functions should exist (405 is OK)"
echo "4. Slack Integration: Should send test message to #gmail-inbox"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "1. Set SLACK_TOKEN: export SLACK_TOKEN=xoxb-your-token"
echo "2. Ensure bot is in #gmail-inbox channel"
echo "3. Test with real email to mabu.mate@gmail.com"
echo ""
echo -e "${YELLOW}🔗 Useful Links:${NC}"
echo "- Function App: $FUNCTION_APP_URL"
echo "- Slack App: https://api.slack.com/apps/A0931KMSEEL"
echo "- Azure Portal: https://portal.azure.com"
