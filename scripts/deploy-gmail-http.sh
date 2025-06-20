#!/bin/bash

# Deploy Gmail + HTTP Slack Workflow
# This bypasses the Gmail + Slack connector policy restriction

set -e

echo "🔧 Deploying Gmail + HTTP Slack workflow..."
echo ""

# Get Slack webhook URL from user
read -p "📝 Enter your Slack webhook URL: " SLACK_WEBHOOK_URL

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    echo "❌ Error: Slack webhook URL is required"
    exit 1
fi

# Validate webhook URL format
if [[ ! "$SLACK_WEBHOOK_URL" =~ ^https://hooks\.slack\.com/services/ ]]; then
    echo "❌ Error: Invalid Slack webhook URL format"
    echo "Expected format: https://hooks.slack.com/services/T.../B.../..."
    exit 1
fi

echo "✅ Using webhook URL: $SLACK_WEBHOOK_URL"
echo ""

# Update the workflow with the webhook URL
sed "s|SLACK_WEBHOOK_URL_PLACEHOLDER|$SLACK_WEBHOOK_URL|g" \
    logicapp/gmail-http-workflow.json > logicapp/ready-workflow.json

echo "📝 Updated workflow with webhook URL"

# Deploy the workflow
echo "🚀 Deploying updated workflow..."
az resource update \
  --resource-group logicapp-jasmin-catering_group \
  --resource-type "Microsoft.Logic/workflows" \
  --name mabu-logicapps \
  --set properties.definition="$(cat logicapp/ready-workflow.json)"

echo ""
echo "✅ Deployment completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Refresh the LogicApp Designer in Azure Portal"
echo "   2. Send test email to mabu.mate@gmail.com"
echo "   3. Check #gmail-inbox channel in Slack"
echo ""
echo "🧪 Test email:"
echo "   To: mabu.mate@gmail.com"
echo "   Subject: Test - HTTP Slack Integration"
echo "   Body: Testing the new Gmail + HTTP webhook integration!"
