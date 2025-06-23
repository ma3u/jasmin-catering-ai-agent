#!/bin/bash

# Quick Setup Verification for Jasmin Catering AI Agent
echo "🔍 Jasmin Catering Setup Verification"
echo "====================================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

function check_status() {
    local description=$1
    local status=$2
    local message=$3
    
    if [ "$status" -eq 0 ]; then
        echo -e "${GREEN}✅ $description${NC}"
        [ -n "$message" ] && echo "   $message"
    else
        echo -e "${RED}❌ $description${NC}"
        [ -n "$message" ] && echo "   $message"
        ERRORS=$((ERRORS + 1))
    fi
}

function check_warning() {
    local description=$1
    local message=$2
    
    echo -e "${YELLOW}⚠️  $description${NC}"
    [ -n "$message" ] && echo "   $message"
    WARNINGS=$((WARNINGS + 1))
}

function check_info() {
    local description=$1
    local message=$2
    
    echo -e "${BLUE}ℹ️  $description${NC}"
    [ -n "$message" ] && echo "   $message"
}

echo -e "\n📧 Email Configuration"
echo "----------------------"

# Check Gmail target
check_info "Gmail Target" "mabu.mate@gmail.com"

# Check if Azure Functions are accessible
echo -e "\n🔧 Azure Functions"
echo "-------------------"

FUNCTION_URL="https://jasmin-gmail-functions.azurewebsites.net"
if curl -s --max-time 10 "$FUNCTION_URL/api/testGmailConnection" > /dev/null 2>&1; then
    check_status "Azure Functions Accessible" 0 "$FUNCTION_URL"
else
    check_status "Azure Functions Accessible" 1 "Cannot reach $FUNCTION_URL"
fi

# Check Azure Functions deployment
if curl -s --max-time 10 "$FUNCTION_URL/api/getAuthUrl" > /dev/null 2>&1; then
    check_status "OAuth Setup Endpoint" 0 "getAuthUrl endpoint responding"
else
    check_status "OAuth Setup Endpoint" 1 "getAuthUrl endpoint not accessible"
fi

echo -e "\n📱 Slack Configuration"
echo "----------------------"

# Check Slack app details
check_info "Slack App ID" "A0931KMSEEL"
check_info "Slack Workspace" "mabured.slack.com"
check_info "Slack Channel" "#gmail-inbox"

# Check Slack token
if [ -n "$SLACK_TOKEN" ]; then
    if [[ $SLACK_TOKEN == xoxb-* ]]; then
        check_status "Slack Token Format" 0 "Token format correct: ${SLACK_TOKEN:0:15}..."
        
        # Test Slack API
        slack_response=$(curl -s -H "Authorization: Bearer $SLACK_TOKEN" \
                              "https://slack.com/api/auth.test")
        if echo "$slack_response" | jq -e '.ok == true' > /dev/null 2>&1; then
            team_name=$(echo "$slack_response" | jq -r '.team // "Unknown"')
            check_status "Slack API Connection" 0 "Connected to: $team_name"
        else
            error=$(echo "$slack_response" | jq -r '.error // "Unknown"')
            check_status "Slack API Connection" 1 "API Error: $error"
        fi
    else
        check_status "Slack Token Format" 1 "Token should start with 'xoxb-'"
    fi
else
    check_warning "Slack Token Missing" "Set: export SLACK_TOKEN=xoxb-your-token"
fi

echo -e "\n🔐 OAuth Requirements"
echo "--------------------"

# Check if OAuth credentials are configured (we can't see the actual values)
check_info "Gmail OAuth Setup" "Requires Client ID, Client Secret, Refresh Token"
check_info "OAuth Playground" "https://developers.google.com/oauthplayground"

# Check if dependencies are available
echo -e "\n📦 Dependencies"
echo "---------------"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    check_status "Node.js Installed" 0 "Version: $NODE_VERSION"
else
    check_status "Node.js Installed" 1 "Required for local testing"
fi

if command -v npm &> /dev/null; then
    check_status "npm Available" 0
else
    check_status "npm Available" 1 "Required for package management"
fi

if command -v curl &> /dev/null; then
    check_status "curl Available" 0
else
    check_status "curl Available" 1 "Required for API testing"
fi

if command -v jq &> /dev/null; then
    check_status "jq Available" 0 "JSON processing available"
else
    check_warning "jq Available" "Install for better JSON handling: brew install jq"
fi

if command -v az &> /dev/null; then
    check_status "Azure CLI" 0 "Available for advanced management"
else
    check_warning "Azure CLI" "Install for advanced features: brew install azure-cli"
fi

echo -e "\n📁 Project Structure"
echo "-------------------"

# Check if we're in the right directory
if [ -f "package.json" ] && [ -f "src/functions/gmailMonitor.js" ]; then
    check_status "Project Structure" 0 "In azure-functions directory"
else
    check_warning "Project Structure" "Run from azure-functions directory"
fi

# Check key files
if [ -f ".env.template" ]; then
    check_status "Environment Template" 0 ".env.template found"
else
    check_status "Environment Template" 1 ".env.template missing"
fi

if [ -f "src/functions/gmailMonitor.js" ]; then
    check_status "Gmail Monitor Function" 0 "Core function file exists"
else
    check_status "Gmail Monitor Function" 1 "gmailMonitor.js missing"
fi

if [ -f "src/utils/slackNotifier.js" ]; then
    check_status "Slack Notifier" 0 "Slack integration file exists"
else
    check_status "Slack Notifier" 1 "slackNotifier.js missing"
fi

echo -e "\n🧪 Test Files"
echo "-------------"

if [ -f "test-slack-integration.js" ]; then
    check_status "Slack Test Script" 0 "Available for testing"
else
    check_status "Slack Test Script" 1 "test-slack-integration.js missing"
fi

if [ -f "test-azure-integration.sh" ]; then
    check_status "Azure Test Script" 0 "Available for testing"
else
    check_status "Azure Test Script" 1 "test-azure-integration.sh missing"
fi

if [ -f "EMAIL_TEST_GUIDE.md" ]; then
    check_status "Email Test Guide" 0 "Test scenarios documented"
else
    check_status "Email Test Guide" 1 "EMAIL_TEST_GUIDE.md missing"
fi

echo -e "\n📊 Summary"
echo "----------"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Perfect Setup! Everything looks good.${NC}"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Good Setup with $WARNINGS warning(s). You can proceed but consider fixing warnings.${NC}"
else
    echo -e "${RED}❌ Setup Issues: $ERRORS error(s) and $WARNINGS warning(s) found.${NC}"
fi

echo -e "\n🚀 Next Steps"
echo "-------------"

if [ $ERRORS -gt 0 ]; then
    echo "1. Fix the errors listed above"
    echo "2. Ensure Azure Functions are deployed"
    echo "3. Get Slack Bot Token (xoxb-...)"
    echo "4. Configure Gmail OAuth credentials"
else
    echo "1. Set Slack token: export SLACK_TOKEN=xoxb-your-token"
    echo "2. Run integration test: ./test-azure-integration.sh"
    echo "3. Test with real email: Send test email to mabu.mate@gmail.com"
    echo "4. Check Slack #gmail-inbox for notifications"
fi

echo -e "\n🔗 Useful Commands"
echo "-------------------"
echo "• Test Slack: node test-slack-integration.js"
echo "• Test Azure: ./test-azure-integration.sh" 
echo "• View logs: az functionapp logstream jasmin-gmail-functions"
echo "• Send test email to: mabu.mate@gmail.com"

echo -e "\n📚 Documentation"
echo "----------------"
echo "• Email tests: cat EMAIL_TEST_GUIDE.md"
echo "• OAuth setup: cat GET_TOKENS_INSTRUCTIONS.md"
echo "• Deployment: cat DEPLOYMENT_STATUS.md"

if [ $ERRORS -gt 0 ]; then
    exit 1
else
    exit 0
fi
